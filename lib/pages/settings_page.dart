import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';
import '../db/preferences.dart';
import '../utils/views/loading_screen.dart';
import '../db/notification_service.dart';
import '../db/database.dart';
import '../model/todo.dart';
import '../utils/views/yes_no_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    loading = true;
    preferences.initService().then((res){
      _updateValues();
    });
    notificationService.initService();
    dbHelper.getActiveToDos().then((todos){
      existingTodos = todos;
      notificationService.cancelOpenNotifications(todos, preferences.getNotificationSliderValue());
      setState(() {
        loading = false;
      }); 
    });
  }

  _updateValues(){
    setState(() {
      isNotificationsEnabled = preferences.isNotificationsEnabled();
      notificationSliderValue = preferences.getNotificationSliderValue();
      savedNotificationSliderValue = notificationSliderValue;
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return  loading ? LoadingScreen() : SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10.0),
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
                    'RESET',
                    style: TextStyle(color: Colors.white), 
                  ),
                  color: Colors.orangeAccent,
                ),
              ),
              settingsOption('Change language', IconButton(
                  icon: Icon(FontAwesomeIcons.globe),
                  iconSize: 20.0,
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
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Notifications enabled 🔔'),
                    ));
                    notificationService.updateNotifications(existingTodos, savedNotificationSliderValue);
                  }
                  else{
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Notifications disabled 🔕'),
                    ));
                    notificationService.cancelAllNotifications();
                  }
                },
                ),
              ),
              settingsOptionWithNull('Notify '+notificationSliderValue.round().toString()+' hours before each deadline', 
                 Opacity(
                   opacity: (savedNotificationSliderValue != notificationSliderValue) ? 1.0 : 0.0,
                   child: RaisedButton(
                    onPressed: (savedNotificationSliderValue != notificationSliderValue) ? () {
                      savedNotificationSliderValue = notificationSliderValue;
                      preferences.updatePreference(Preferences.NOTIFICATIONS_DELAY, savedNotificationSliderValue);
                      _updateValues();
                      notificationService.updateNotifications(existingTodos, savedNotificationSliderValue);
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Timer updated ⏰'),
                      ));
                    } : null,
                    child: Text(
                      'Update',
                      style: TextStyle(color: Colors.white), 
                    ),
                    color: Colors.orangeAccent,
                  ),
                ),
                isNotificationsEnabled
              ),
              
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
              settingsHeader('In-app purchases'),
              settingsOption('Disable ads', RaisedButton(
                  onPressed: () {
                    //LINK TO DISABLING ADS
                  },
                  child: Text(
                    '£0.99',
                    style: TextStyle(color: Colors.white), 
                  ),
                  color: Colors.orangeAccent,
                ),
              ),
              settingsHeader('Social media'),
              settingsOption('Follow us on twitter  @24h_tasks', IconButton(
                icon: Icon(FontAwesomeIcons.twitter),
                iconSize: 20.0,
                onPressed: () {
                  //LINK TO TWITTER
                },
              )),
              settingsOption('Share this to friends', IconButton(
                icon: Icon(Icons.share),
                iconSize: 20.0,
                onPressed: () {
                    final RenderBox box = context.findRenderObject();
                    Share.share('Check out this great app that helps get your daily tasks done! WWW.WEBSITELINK.COM',
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
      padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0, top: 10.0),
      child: Text(
        headerText,
        style: TextStyle(color: Colors.orange[900],fontWeight: FontWeight.bold, fontSize: 20.0,),
      ),
    );
  }

    Widget settingsOptionWithNull(String optionText, Widget button, [bool enabled = true]){
    return (button==null) ? Row(
      children: <Widget>[
        Expanded(
          child: Text(
            optionText,
            style: TextStyle(fontSize: 17.0, color: enabled ? Colors.black : Colors.grey),
          ),
        ),
      ],
    ) : settingsOption(optionText, button, enabled);
  }


  Widget settingsOption(String optionText, Widget button, [bool enabled = true]){
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            optionText,
            style: TextStyle(fontSize: 17.0, color: enabled ? Colors.black : Colors.grey),
          ),
        ),
        button,
      ],
    );
  }
}
