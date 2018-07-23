import 'package:flutter/material.dart';
import '../utils/views/loading_screen.dart';
import '../db/database.dart';
import '../model/todo.dart';
import '../db/notification_service.dart';
import './new_tabs_page.dart';
import '../db/preferences.dart';
import '../utils/helpers/time_functions.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  
  bool loading = true;
  DBHelper dbHelper = new DBHelper();
  List<ToDo> todos = [];

  NotificationService notificationService = new NotificationService();
  Preferences preferencesService = new Preferences();
  bool notificationsEnabled;
  int notificationsDelayValue;

  @override  
  void initState() {
    super.initState();
    initialiseServices();
  }

  initialiseServices() async {
    loading = true;
    todos = await dbHelper.getHistoryToDos();
    await notificationService.initService();
    await preferencesService.initService();
    notificationsDelayValue = preferencesService.getNotificationSliderValue();
    notificationsEnabled = preferencesService.isNotificationsEnabled();
    loading = false;
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
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          child: Text('History', 
            style: TextStyle(
              fontWeight: FontWeight.w300, fontSize: 30.0,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int i) => taskHistoryView(todos[i]),
            itemCount: todos.length,
          ),
        ),
      ],
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
                      fontSize: 20.0,
                      color: todo.success ? Colors.green[800] : Colors.red[800]
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Text('Completed: '+TimeFunctions.getDateAsShortString(todo.completionDate), style: TextStyle(fontSize: 10.0, color: Colors.grey[800]),),
                ),        
              ],
            ),
          ),
          RaisedButton(
            child: Text('Redo'),
            color: Colors.orange,
            onPressed: (){
              dbHelper.createToDo(ToDo(0, todo.task)).then((taskId) {
                if(notificationsEnabled){
                  notificationService.createNotification(ToDo(taskId, todo.task), notificationsDelayValue);
                }
              });                      
              Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => NewTabsPage()),
                (Route route) => route == null
              );            
            },
          )
        ],
      ),
    );
  }
  

}