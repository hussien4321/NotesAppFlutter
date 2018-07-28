import 'package:flutter/material.dart';
import '../utils/views/loading_screen.dart';
import '../services/database.dart';
import '../model/todo.dart';
import '../services/notifications.dart';
import './home_page.dart';
import '../services/preferences.dart';
import '../utils/helpers/time_functions.dart';
import '../utils/helpers/custom_page_routes.dart';

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

  @override  
  void initState() {
    super.initState();
    loading = true;
    dbHelper = new DBHelper();
    notificationService = new NotificationService();
    preferences = new Preferences();
    updatePage();
  }

  updatePage() async {

    todos = await dbHelper.getHistoryToDos();
    notificationsDelayValue = preferences.getNotificationSliderValue();
    notificationsEnabled = preferences.isNotificationsEnabled();
    setState(() {
      loading = false;
    });
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
          padding: EdgeInsets.only(top: 10.0),
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
                  child: Text((todo.success ? 'Passed':'Failed') +' on '+TimeFunctions.getDateAsShortString(todo.completionDate), style: TextStyle(fontSize: 10.0, color: Colors.grey[800]),),
                ),        
              ],
            ),
          ),
          RaisedButton(
            child: Text('Restart'),
            color: Colors.orange,
            onPressed: (){
              //TODO: Add snackbar when new task is created
              dbHelper.createToDo(ToDo(0, todo.task)).then((taskId) {
                if(taskId != null){
                  if(notificationsEnabled){
                    notificationService.createNotification(ToDo(taskId, todo.task), notificationsDelayValue);
                  }
                  Navigator.of(context).pushAndRemoveUntil(new NoAnimationPageRoute(builder: (BuildContext context) => HomePage()),
                    (Route route) => route == null
                  );
                }            
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Task is already active'),
                ));
              });                      
            },
          )
        ],
      ),
    );
  }
  

}