import 'package:flutter/material.dart';
import '../db/database.dart';
import '../model/task.dart';
import '../model/todo.dart';
import '../utils/views/loading_screen.dart';
import '../utils/views/faded_background.dart';
import '../utils/views/task_view.dart';
import './new_tabs_page.dart';
import '../db/notification_service.dart';
import '../db/preferences.dart';
import '../utils/views/yes_no_dialog.dart';
import '../utils/helpers/custom_page_route.dart';
import './emoji_selector_page.dart';

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

  String iconText = "";
  bool iconError = false;
  final taskNameController = TextEditingController();
  

  NotificationService notificationService = new NotificationService();
  Preferences preferencesService = new Preferences();
  bool notificationsEnabled;
  int notificationsDelayValue;

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    taskNameController.dispose();
    super.dispose();
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

      iconText = "";
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
        Container(
          decoration: new BoxDecoration(
            border: new Border(bottom: BorderSide(color: Colors.grey)),
          ),
          padding: EdgeInsets.only(top: 5.0, left: 10.0, bottom: 5.0),
          child: Row(
            children: <Widget>[  
              Expanded(
                child: Text('Saved tasks', style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold), textAlign: TextAlign.start,),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                  _isEditMode = _isEditMode == false;               
                  });
                },
                icon: Icon(_isEditMode ? Icons.check : Icons.edit),
              ),
            ],
          ),
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
                      Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => NewTabsPage()),
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
                  child: Image.asset(
                    'assets/icons/objects/1f4a1.png',
                    width: 32.0,
                    height: 32.0,
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

  _newTaskDialog([Task dialogTask, bool update = true]) async {
    iconError = false;
    if(update){
      if(dialogTask == null){
        taskNameController.clear();
        iconText = "";
      }
      else{
        taskNameController.text= dialogTask.name;
        iconText = dialogTask.icon;
      }
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
            
            Container(
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Icon:',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        FormField(
                          validator: (value) {
                            setState((){
                              iconError = true;
                            });
                            return 'selct emoji';
                          },
                          builder: (state) {
                            return Expanded(
                              child: iconText == '' ? 
                                Center(child:Text("?", style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: iconError ? Colors.red: Colors.black),)) : 
                                Image.asset(
                                  iconText,
                                  width: 32.0,
                                  height: 32.0,
                                ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  Padding( padding: EdgeInsets.all(5.0)),
                  Expanded(
                    child: RaisedButton(
                      onPressed: () async {
                        final result = await Navigator.push(context, CustomPageRoute(
                          builder: (BuildContext context) => EmojiSelectorPage()),
                        );
                        if(result != null){
                          setState(() {
                            iconText = result.toString();
                          });                        
                          Navigator.pop(context);
                          _newTaskDialog(dialogTask, false);
                        }
                      },
                      child: Text(iconText == '' ? 'SELECT' : 'CHANGE'),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            TextFormField(
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
                          iconText = '';
                          Navigator.pop(context);
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
                        if(_formKey.currentState.validate() && iconText != ''){
                          if(dialogTask == null){
                            Task newTask = new Task(0, taskNameController.text, iconText);

                            int newId = await _dbHelper.createTask(newTask);
                            newTask.setId(newId);
                            _dbHelper.createToDo(new ToDo(0, newTask)).then((todoId){
                              if(notificationsEnabled){
                                notificationService.createNotification(new ToDo(todoId, newTask), notificationsDelayValue);
                              }
                              Navigator.pop(context);
                              Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => 
                                NewTabsPage()),
                                (Route route) => route == null
                              );
                            });
                          }
                          else{
                            if(taskNameController.text != dialogTask.name || iconText != dialogTask.icon){
                              dialogTask.update(taskNameController.text, iconText);
                              _dbHelper.updateTask(dialogTask).then((res){
                                updateTasks();
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text('Task updated 👌'),
                                ));
                              });
                            }
                            taskNameController.clear();
                            iconText = '';
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