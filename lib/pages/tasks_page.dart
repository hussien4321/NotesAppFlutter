import 'package:flutter/material.dart';
import '../db/database.dart';
import '../model/task.dart';
import '../model/todo.dart';
import '../utils/views/loading_screen.dart';
import '../utils/views/faded_background.dart';
import '../utils/views/task_view.dart';
import './home_page.dart';
import '../db/notification_service.dart';
import '../db/preferences.dart';
import '../utils/views/yes_no_dialog.dart';

class TasksPage extends StatefulWidget {
    @override
    State createState() => new TasksPageState();

}

class TasksPageState extends State<TasksPage> {

  bool _isEditMode = false;
  DBHelper _dbHelper = new DBHelper();

  bool _loadingPage = true;
  List<Task> _tasks = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String previousIcon = "";
  final taskNameController = TextEditingController();
  final taskIconController = TextEditingController();

  NotificationService notificationService = new NotificationService();
  Preferences preferencesService = new Preferences();
  bool notificationsEnabled;
  int notificationsDelayValue;

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    taskIconController.removeListener(_iconRealtimeValidation);
    taskNameController.dispose();
    taskIconController.dispose();
    super.dispose();
  }

  _iconRealtimeValidation(){
    RegExp exp = new RegExp(r"(\w+|\s)");
    if(exp.hasMatch(taskIconController.text)){
      taskIconController.clear();
      taskIconController.text = "";
    }
    previousIcon = taskIconController.text;
  }


  @override
  void initState() {
      super.initState();
      notificationService.initService();
      preferencesService.initService().then((res){
        notificationsDelayValue = preferencesService.getNotificationSliderValue();
        notificationsEnabled = preferencesService.isNotificationsEnabled();
      });

      _isEditMode = false;

      previousIcon = "";
      taskIconController.addListener(_iconRealtimeValidation);
      updateTasks();
  }


  updateTasks(){
    _dbHelper.getAllTasks().then((res) => this.setState(() {
      _tasks = res; 
      _loadingPage = false;
    }));
    _dbHelper.getActiveToDos().then((todos) => notificationService.cancelOpenNotifications(todos, preferencesService.getNotificationSliderValue()));
  }

  @override
  void didUpdateWidget(TasksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateTasks();
  }


  @override
    Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Select a task 💭"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
               _isEditMode = _isEditMode == false;               
              });
            },
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
          )
        ],
      ),
      body: fadedBackground(
        child: _loadingPage ? LoadingScreen() : _recommendedTasksView(),
      ), 
    );
  }  

  Widget _recommendedTasksView(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        createTaskWidget(context),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: new BoxDecoration(
                  border: new Border(bottom: BorderSide(color: Colors.grey)),
                ),
                padding: EdgeInsets.only(top: 15.0, left: 5.0, bottom: 5.0),
                child: Text('Saved tasks', style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold), textAlign: TextAlign.start,),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int i) { 
                return TaskView(_tasks[i], _isEditMode, 
                  () {
                    if(!_isEditMode){
                      _dbHelper.createToDo(ToDo(0, _tasks[i])).then((taskId) {
                        if(notificationsEnabled){
                          notificationService.createNotification(ToDo(taskId, _tasks[i]),notificationsDelayValue);
                        }
                      });                      
                      Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => HomePage()),
                        (Route route) => route == null
                      );
                    }
                    else{
                      _newTaskDialog(_tasks[i]);
                    }
                  }
                );
              },
            itemCount: _tasks.length,
          ),
        ),
      ],
    );
  }

  
  Widget createTaskWidget(BuildContext context){
    return Container(
          padding: EdgeInsets.all(15.0),
          decoration: new BoxDecoration(
            border: new Border(bottom: BorderSide(color: Colors.grey[800], width: 2.0)),
          ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '💡',
                    style: TextStyle(fontSize: 30.0, ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                  padding: EdgeInsets.all(5.0),
                    child: Text(
                    'New task',
                    style: TextStyle(fontSize: 20.0,),
                    textAlign: TextAlign.start,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: RaisedButton(
                    onPressed: () => _newTaskDialog(),
                    child: Text('Create'),
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
        );
    }

  _newTaskDialog([Task dialogTask]) async {
    if(dialogTask == null){
      taskNameController.clear();
      taskIconController.clear();
      previousIcon = "";
    }
    else{
      taskNameController.text= dialogTask.name;
      taskIconController.text = dialogTask.icon;
      previousIcon = dialogTask.icon;
    }
    await showDialog(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(dialogTask == null ? 'Create task 🌟' : 'Edit task ✏️',textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0),),
        content: Form(
          key: _formKey,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top :30.0),),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    validator: (value) {
                      if (previousIcon.isEmpty) {
                        return 'Invalid\nemoji';
                      }
                    },
                    controller: taskIconController,
                    style: TextStyle(fontSize: 17.0,),
                    textAlign: TextAlign.center,
                    autofocus: false,
                    decoration: InputDecoration(
                        labelText: 'Emoji', hintText: 'eg. 😀', contentPadding: EdgeInsets.only(bottom: 5.0),),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 10.0),),
                Expanded(
                  flex: 7,
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a task name';
                      }
                    },
                    controller: taskNameController,
                    style: TextStyle(fontSize: 17.0,color: Colors.black),
                    autofocus: dialogTask == null,
                    decoration: InputDecoration(
                        labelText: 'Task name', hintText: 'eg. Do 10 push ups', contentPadding: EdgeInsets.only(bottom: 5.0),),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(10.0),),
            Container(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Colors.redAccent,
                      child: Text(dialogTask == null ? 'CANCEL' : 'DELETE', style: TextStyle(color: Colors.black),),
                      onPressed: () {
                        //TODO: ADD YES/NO DIALOG TO CONFIRM 
                        if(dialogTask != null){
                          // Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (newContext) {
                              return YesNoDialog(
                                title: 'Delete task',
                                description: 'Are you sure you want to delete this task?',
                                yesText: 'Yes',
                                noText: 'No',
                                onYes: (){
                                  _dbHelper.deleteTask(dialogTask);
                                  updateTasks();
                                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content: new Text('Task deleted ☠️️'),
                                  ));
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                onNo: (){
                                  Navigator.pop(context);
                                },
                              );
                            }
                          );
                        }else{
                          taskNameController.clear();
                          taskIconController.clear();
                          previousIcon = '';
                        }
                      }
                    ),
                  ),
                  Padding( padding: EdgeInsets.all(5.0)),
                  Expanded(
                    child: RaisedButton(
                      elevation: 2.0,
                      color: Colors.greenAccent,
                      child: Text(dialogTask == null ? 'ADD' : 'SAVE', style: TextStyle(color: Colors.black),),
                      onPressed: () async {
                        if(_formKey.currentState.validate()){
                          if(dialogTask == null){
                            Task newTask = new Task(0, taskNameController.text, taskIconController.text);

                            int newId = await _dbHelper.createTask(newTask);
                            newTask.setId(newId);
                            _dbHelper.createToDo(new ToDo(0, newTask)).then((todoId){
                              if(notificationsEnabled){
                                notificationService.createNotification(new ToDo(todoId, newTask), notificationsDelayValue);
                              }
                              Navigator.pop(context);
                              Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => 
                                HomePage()),
                                (Route route) => route == null
                              );
                            });
                          }
                          else{
                            if(taskNameController.text != dialogTask.name || taskIconController.text != dialogTask.icon){
                              dialogTask.update(taskNameController.text, taskIconController.text);
                              _dbHelper.updateTask(dialogTask).then((res){
                                updateTasks();
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text('Task updated 👌'),
                                ));
                              });
                            }
                            taskNameController.clear();
                            taskIconController.clear();
                            previousIcon = '';
                            Navigator.pop(context);
                          }
                        }
                      }),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
        actions:null,
      ),
    );
  }

}