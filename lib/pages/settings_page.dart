import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_iap/flutter_iap.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:share/share.dart';
import 'package:flutter/services.dart';
import '../services/preferences.dart';
import '../utils/views/loading_screen.dart';
import '../services/notifications.dart';
import '../services/database.dart';
import '../model/todo.dart';
import '../utils/views/yes_no_dialog.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool isNotificationsEnabled = false;
  int notificationSliderValue = 12;
  int savedNotificationSliderValue = 12;

  bool loading = true;

  Preferences preferences = new Preferences();
  NotificationService notificationService = new NotificationService();
  List<ToDo> existingTodos = [];
  DBHelper dbHelper = new DBHelper();

  final String _twitterURL = 'https://twitter.com/TodoToday2';


  
  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices: null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    birthday: new DateTime.now(),
    childDirected: true,
    gender: MobileAdGender.male,
  );
  BannerAd _bannerAd;

  List<String> _productIds = [];
  List<String> _alreadyPurchased = [];

  @override
  void initState() {
    super.initState();
    loading = true;
    initAds();
    // initPaymentOption();
    initPage();
  }

  
  // initPaymentOption() async {
  //   List<String> productIds = [""];
  //   IAPResponse response = await FlutterIap.fetchProducts(productIds);
  //   productIds = response.products
  //       .map((IAPProduct product) => product.productIdentifier)
  //       .toList();
  //   if (!mounted)
  //     return;
  //   setState(() {
  //     _productIds = productIds;
  //   });
  // }


  initAds() async {
    FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
    _bannerAd = createBannerAd()..load();    
  }

  BannerAd createBannerAd() {
    return new BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        if(mounted){
          _bannerAd..show(
            anchorOffset: 56.0,
            anchorType: AnchorType.bottom, 
          );
        }
      },
    );
  }

  initPage() async {
    isNotificationsEnabled = await preferences.isNotificationsEnabled();
    notificationSliderValue = await preferences.getNotificationSliderValue();
    savedNotificationSliderValue = notificationSliderValue;
    List<ToDo> todos = await dbHelper.getActiveToDos();
    existingTodos = todos;
    notificationService.cancelOpenNotifications(todos, notificationSliderValue);
    setState(() {
      loading = false;
    }); 

  }

  _updateValues() async {
    bool newIsNotificationsEnabled  = await preferences.isNotificationsEnabled();
    int newNotificationSliderValue = await preferences.getNotificationSliderValue();
    setState(() {
      isNotificationsEnabled = newIsNotificationsEnabled;
      notificationSliderValue = newNotificationSliderValue;
    }); 
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  loading ? LoadingScreen() : SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(5.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              settingsHeader('App settings'),
              settingsOption('Reset data', RaisedButton(
                  onPressed: () {
                    loading = true;
                    showDialog(
                        context: context,
                        builder: (newContext) => YesNoDialog(
                          title: 'Reset data',
                          description: 'WARNING: This will delete all task data saved on the app so far.\n\nAre you sure you would like to delete it?',
                          yesText: 'Yes',
                          noText: 'No',
                          onYes: () {
                            dbHelper.resetDb().then((res) {
                              notificationService.cancelAllNotifications();
                              loading = false;
                              Scaffold.of(context).hideCurrentSnackBar();
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Data reset successfully ✨'),
                              ));
                            });
                            Navigator.pop(context);
                          },
                          onNo: () {
                            Navigator.pop(context);
                          },
                        ),
                    );
                  },
                  child: Text(
                    'Reset',
                  ),
                  color: Colors.orange,
                ),
              ),
              // settingsOption('Change language', IconButton(
              //     icon: Icon(FontAwesomeIcons.globe),
              //     iconSize: 20.0,
              //   ),
              // ),
              settingsHeader('Notifications'),
              settingsOption('Enable notifications', Switch(
                value: isNotificationsEnabled,
                onChanged: (status) {
                  isNotificationsEnabled = status;
                  preferences.updatePreference(Preferences.NOTIFICATIONS_ENABLED, status);
                  _updateValues();
                  if(isNotificationsEnabled){                    
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Notifications enabled 🔔'),
                    ));
                    notificationService.updateNotifications(existingTodos, notificationSliderValue);
                  }
                  else{
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Notifications disabled 🔕'),
                    ));
                    notificationService.cancelAllNotifications();
                  }
                },
                ),
              ),
              settingsOption('Notify '+notificationSliderValue.round().toString()+' hours before each deadline', 
                Opacity(
                  opacity: (savedNotificationSliderValue != notificationSliderValue) ? 1.0 : 0.0,
                  child: RaisedButton(
                  onPressed: (savedNotificationSliderValue != notificationSliderValue) ? () {
                    savedNotificationSliderValue = notificationSliderValue;
                    preferences.updatePreference(Preferences.NOTIFICATIONS_DELAY, savedNotificationSliderValue);
                    _updateValues();
                    notificationService.updateNotifications(existingTodos, savedNotificationSliderValue);
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Timer updated ⏰'),
                    ));
                  } : null,
                  child: Text(
                    'Update',
                  ),
                  color: Colors.orangeAccent,
                ),
              ),
              isNotificationsEnabled),
              Slider(
                value: notificationSliderValue.toDouble(),
                activeColor: isNotificationsEnabled ? SliderTheme.of(context).activeTrackColor : Colors.grey,
                inactiveColor: isNotificationsEnabled ? SliderTheme.of(context).inactiveTrackColor : Colors.grey,
                min: 1.0,
                max: 23.0,
                divisions: 22,
                onChanged: (newValue) {
                  if(isNotificationsEnabled){
                    setState(() => notificationSliderValue = newValue.round());
                  }
                },
                
              ),
              // settingsHeader('In-app purchases'),
              // settingsOption('Disable ads', RaisedButton(
              //     onPressed: () async {
              //       IAPResponse response = await FlutterIap.buy(_productIds.first);
              //       print('RESPONSE : ');
              //       print(response);
              //     },
              //     child: Text(
              //       'Buy',
              //     ),
              //     color: Colors.orange,
              //   ),
              // ),
              settingsHeader('Social media'),
              settingsOption('Follow us on twitter  @TodoToday2', IconButton(
                icon: Icon(FontAwesomeIcons.twitter),
                iconSize: 20.0,
                onPressed: () {
                  Clipboard.setData(new ClipboardData(text: _twitterURL));
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Copied to Clipboard 📋'),
                  ));
                },
              )),
              settingsOption('Share this app with friends', IconButton(
                icon: Icon(Icons.share),
                iconSize: 20.0,
                onPressed: () {
                    final RenderBox box = context.findRenderObject();
                    Share.share('Check out this great app for completing daily tasks! Available now on the play store and coming soon to iOS. Look up app name \"Todo-Today\"',
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) &
                                box.size);
                  },
              )),
            ],
          ),
      ),
    );
  }

  Widget settingsHeader(String headerText){
    return Container(
      padding: EdgeInsets.only(left: 0.0, right: 0.0, bottom: 5.0, top: 10.0),
      child: Text(
        headerText,
        style: TextStyle(color: Colors.orange[900],fontWeight: FontWeight.bold, fontSize: 20.0,),
      ),
    );
  }

    Widget settingsOptionNoItem(String optionText, [bool enabled = true]){
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            optionText,
            style: TextStyle(fontSize: 17.0, color: enabled ? Colors.black : Colors.grey),
          ),
        ),
      ],
    );
  }


  Widget settingsOption(String optionText, Widget button, [bool enabled = true]){
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            optionText,
            style: TextStyle(fontSize: 17.0, color: enabled ? Colors.black : Colors.grey[700]),
          ),
        ),
        button,
      ],
    );
  }
}
