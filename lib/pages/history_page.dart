import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import '../utils/views/loading_screen.dart';
import '../services/database.dart';
import '../model/todo.dart';
import '../services/notifications.dart';
import './home_page.dart';
import '../services/preferences.dart';
import '../utils/helpers/admob_tools.dart';
import '../utils/helpers/time_functions.dart';
import '../utils/helpers/custom_page_routes.dart';
import '../utils/views/custom_dialogs.dart';
import 'dart:io' show Platform;

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  
  bool loading = true;
  DBHelper dbHelper;
  NotificationService notificationService;
  Preferences preferences;
  
  List<ToDo> todos = [];

  bool notificationsEnabled;
  int notificationsDelayValue;


  BannerAd _bannerAd;

  @override  
  void initState() {
    super.initState();
    

    loading = true;
    dbHelper = new DBHelper();
    notificationService = new NotificationService();
    preferences = new Preferences();
    initAds();
    updatePage();
  }

  
  initAds() async {
    bool adsPaidStatus = await preferences.getAdsPaidStatus();
    if(!adsPaidStatus){
      _bannerAd = createBannerAd()..load();   
    } 
  }

  BannerAd createBannerAd() {
    return new BannerAd(
      adUnitId: AdmobTools.historyPageAdUnitId,
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


  updatePage() async {

    todos = await dbHelper.getHistoryToDos();
    notificationsDelayValue = await preferences.getNotificationSliderValue();
    notificationsEnabled = await preferences.isNotificationsEnabled();
    setState(() {
      loading = false;
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
    return loading ? LoadingScreen() : (todos.isEmpty ? noHistoryView() : historyTodosView());
  }

  Widget noHistoryView(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'You currently have no history 😞',
            style: TextStyle(fontSize: 15.0),
          ),
          Padding(padding: EdgeInsets.only(top:10.0),),
          Text(
            'Complete some tasks to view history',
            style: TextStyle(fontSize: 13.0, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget historyTodosView(){
    return ListView.builder(
      itemBuilder: (BuildContext context, int i) => taskHistoryView(todos[i]),
      itemCount: todos.length,
    );
  }

  Widget taskHistoryView(ToDo todo){
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[800], width: 0.5),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 5.0),
            child:  Image.asset(
              todo.task.icon,
              width: 32.0,
              height: 32.0,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(todo.task.name, style: TextStyle(
                      fontSize: 16.0,
                      color: todo.success ? Colors.green[800] : Colors.red[800]
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Text((todo.success ? 'Passed':'Failed') +' on '+TimeFunctions.getDateAsShortString(todo.completionDate), style: TextStyle(fontSize: 10.0, color: Colors.grey[800]),),
                ),        
              ],
            ),
          ),
          RaisedButton(
            child: Text('Restart'),
            color: Colors.orange,
            onPressed: (){
            showDialog(
              context: context,
              builder: (newContext) => YesNoDialog(
                title: 'Confirm',
                description: "Once started, you can not cancel this task.\n\nAre you ready to "+todo.task.name+"?",
                yesText: 'Start',
                noText: 'Cancel',
                icon: todo.task.icon,
                onYes: () {
                    dbHelper.createToDo(ToDo(0, todo.task)).then((taskId) {
                      if(taskId != null){
                        if(notificationsEnabled){
                          notificationService.createNotification(ToDo(taskId, todo.task), notificationsDelayValue);
                        }
                        _bannerAd?.dispose();
                        _bannerAd = null;
                        Navigator.of(context).pushAndRemoveUntil(
                          Platform.isAndroid ? 
                          new NoAnimationPageRoute(builder: (BuildContext context) => HomePage()) :
                          new NoAnimationPageRouteIOS(builder: (BuildContext context) => HomePage()),
                          (Route route) => route == null
                        );
                      }else{            
                        Navigator.pop(context);
                        Scaffold.of(context).hideCurrentSnackBar();
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Task is already active'),
                        ));
                      }
                    });                      
                },
                onNo: (){
                  Navigator.pop(context);
                },
              ),                        
            );
            },
          )
        ],
      ),
    );
  }
  

}