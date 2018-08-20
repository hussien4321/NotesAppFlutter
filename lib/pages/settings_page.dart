import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:share/share.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import '../services/preferences.dart';
import '../utils/helpers/admob_tools.dart';
import '../utils/helpers/iap_tools.dart';
import '../utils/views/loading_screen.dart';
import '../services/notifications.dart';
import '../services/database.dart';
import '../model/todo.dart';
import '../utils/views/custom_dialogs.dart';
import '../utils/helpers/custom_page_routes.dart';
import '../utils/helpers/check_connection.dart';
import '../pages/home_page.dart';
import 'dart:async';
import 'dart:io' show Platform;

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
  final String _emailLink = 'mailto:progrs.software@outlook.com?subject=User%20Feedback&body=Hi%20there,%0D%0A%0D%0AI wanted to give some feedback on the app Todo-Today:%0D%0A%0D%0A';

  BannerAd _bannerAd;

  bool adsPaidStatus;
  bool loadingPurchases;
  bool hasConnection;
  IAPItem iapItem;

  final List<String>_productLists = Platform.isAndroid
      ? [
    'android.test.purchased',
    'point_1000',
    '5000_point',
    'android.test.canceled',
  ]
      : ['com.cooni.point1000','com.cooni.point5000', 'todo.today.remove.ads'];

  @override
  void initState() {
    super.initState();
    loading = true;
    initPurchases();
    initAds();
  }


  initPurchases() async {
    loadingPurchases = true;
    hasConnection = false;
    hasConnection = await CheckConnection.checkConnection();
    if(hasConnection){
      adsPaidStatus = await preferences.getAdsPaidStatus();
      if(Platform.isAndroid){
        await FlutterInappPurchase.prepare;
      }
      if (!mounted) return;

      List<IAPItem> purchasedItems = await FlutterInappPurchase.getAvailablePurchases();
      List<String> purchasedIds = purchasedItems.map((purchased) => purchased.productId.toString()).toList();
      List<IAPItem> items = await FlutterInappPurchase.getProducts(IAPTOOLS.productLists);
      print('NUMBER OF ITEMS = ${items.length} / PURCHASES = ${purchasedIds.toString()} / LIST = ${IAPTOOLS.productLists}');
      for (var item in items) {
        if(purchasedIds.contains(item.productId))
        {
          if(!adsPaidStatus){
            adsPaidStatus = true;
            preferences.updatePreference(Preferences.ADS_PAID_STATUS, true);
            _resetPage();
          }
          print('ALREADY PURCHASED: ${item.productId}');
        }else{
          if(adsPaidStatus){
            adsPaidStatus = false;
            preferences.updatePreference(Preferences.ADS_PAID_STATUS, false);
            _resetPage();
          }
          print('DIDNT PURCHASE: ${item.productId}');
          setState(() {
            iapItem = item;
          });
        }
      }
    }
    if (mounted){
      setState(() {
        loadingPurchases = false;
        hasConnection = hasConnection;
      });
    }
  }

  _resetPage(){
    Navigator.of(context).pushAndRemoveUntil(
      Platform.isAndroid ?
      new NoAnimationPageRoute(builder: (BuildContext context) => HomePage(4)) :
      new NoAnimationPageRouteIOS(builder: (BuildContext context) => HomePage(4)),
      (Route route) => route == null
    );
  }

  initAds() async {
    adsPaidStatus = await preferences.getAdsPaidStatus();
    if(!adsPaidStatus){
      _bannerAd = createBannerAd()..load();    
    }
    initPage();
  }

  BannerAd createBannerAd() {
    return new BannerAd(
      adUnitId: AdmobTools.settingsPageAdUnitId,
      size: AdSize.banner,
      targetingInfo: AdmobTools.targetingInfo,
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
    bool newAdsPaidStatus = await preferences.getAdsPaidStatus();
    bool newIsNotificationsEnabled  = await preferences.isNotificationsEnabled();
    int newNotificationSliderValue = await preferences.getNotificationSliderValue();
    setState(() {
      adsPaidStatus = newAdsPaidStatus;
      isNotificationsEnabled = newIsNotificationsEnabled;
      notificationSliderValue = newNotificationSliderValue;
    }); 
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    closePurchases();
    super.dispose();
  }

  closePurchases() async {
    try{
      await FlutterInappPurchase?.endConnection;
    }
    catch (error){
      print(error);
    }
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
                            showDialog(
                              context: context,
                              builder: (secondContext) => YesNoDialog(
                                title: 'Confirmation',
                                description: 'Are you sure?\nThis can not be undone.',
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
                                  Navigator.pop(context);
                                },
                                onNo: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                              ),
                            );
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
              settingsOption('Send us feedback', IconButton(
                  icon: Icon(Icons.email),
                  iconSize: 20.0,
                  onPressed: _launchEmail,
                ),
              ),
              settingsHeader('In-app purchases'),
              settingsOption('Remove ads', RaisedButton(
                  onPressed: adsPaidStatus || !hasConnection || loadingPurchases || iapItem == null ? null : () async {
                    _buyProduct(iapItem);
                  },
                  child: Text(
                    loadingPurchases ? 'Connecting...' : (!hasConnection ? 'No connection' : (adsPaidStatus ? 'Purchased' : (iapItem == null ? 'Not found' : 'Buy'))),
                  ),
                  color: Colors.orange,
                ),
              ),
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
              settingsHeader('Social media'),
              settingsOption('Follow us on twitter  @TodoToday2', IconButton(
                icon: Icon(FontAwesomeIcons.twitter),
                iconSize: 20.0,
                onPressed:_launchURL,
              )),
              settingsOption('Share this app with friends', IconButton(
                icon: Icon(Icons.share),
                iconSize: 20.0,
                onPressed: () {
                    final RenderBox box = context.findRenderObject();
                    Share.share('Check out this great app for completing daily tasks without anymore delays! Available now for android. Link: http://bit.ly/to-do_today',
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

  removeAds(){
    adsPaidStatus = true;
    preferences.updatePreference(Preferences.ADS_PAID_STATUS, true);
    _bannerAd?.dispose();
    _bannerAd = null;
    _resetPage();
  }

  Future<Null> _buyProduct(IAPItem item) async {
    try {
      if(Platform.isAndroid){
        await FlutterInappPurchase.buyProduct(item.productId);
        // print('completed with p id = ${purchasedItem.productId}');
        removeAds();      
      }
      else{
        await FlutterInappPurchase.buyProduct(item.productId);
        // print('completed with p id = ${purchasedItem.productId}');
        removeAds();      
      }
    } catch (error) {
      print('failed with error = $error');
    }
  }

    
  _launchURL() async {
    if (await canLaunch(_twitterURL)) {
      await launch(_twitterURL);
    } else {
      Clipboard.setData(new ClipboardData(text: _twitterURL));
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Link copied to clipboard 📋'),
      ));
    }
  }
  _launchEmail() async {
      await launch(_emailLink);
    if (await canLaunch(_emailLink)) {
      await launch(_emailLink);
    } else {
      Clipboard.setData(new ClipboardData(text: 'progrs.software@outlook.com'));
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Email copied to clipboard 📋'),
      ));
    }
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
