import 'package:flutter/material.dart';
import '../db/database.dart';
import '../model/task.dart';
import '../utils/views/loading_screen.dart';
import '../utils/views/faded_background.dart';
import '../utils/views/task_view.dart';

class TasksPage extends StatefulWidget {
    @override
    State createState() => new TasksPageState();

}

class TasksPageState extends State<TasksPage> {

  bool _isEditMode = false;
  DBHelper _dbHelper = new DBHelper();

  bool _loadingPage = true;
  List<Task> _tasks = [];

  final _formKey = GlobalKey<FormState>();

  final taskNameController = TextEditingController();
  final taskIconController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    taskNameController.dispose();
    taskIconController.dispose();
    super.dispose();
  }

  @override
  void initState() {
      super.initState();
      _isEditMode = false;
      dbSetUp();
  }

  dbSetUp() async {
    await _dbHelper.initDb();  
    updateTodos();
  }

  updateTodos(){
    _dbHelper.getAllTasks().then((res) => this.setState(() {
      _tasks = res; 
      _loadingPage = false;
    }));
  }

  @override
  void didUpdateWidget(TasksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateTodos();
  }


  @override
    Widget build(BuildContext context) {
    return Scaffold(
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
                child: Text('Suggested tasks', style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold), textAlign: TextAlign.start,),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int i) { 
                return TaskView(_tasks[i], _isEditMode, _dbHelper);
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

  _newTaskDialog() async {
    await showDialog(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text('New Task 🌟',textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0),),
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
                      if (value.isEmpty) {
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
                    autofocus: true,
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
                      child: Text('CANCEL', style: TextStyle(color: Colors.black),),
                      onPressed: () {
                        taskNameController.clear();
                        taskIconController.clear();
                        Navigator.pop(context);
                      }),
                  ),
                  Padding( padding: EdgeInsets.all(5.0)),
                  Expanded(
                    child: RaisedButton(
                      elevation: 2.0,
                      color: Colors.greenAccent,
                      child: Text('ADD', style: TextStyle(color: Colors.black),),
                      onPressed: () {
                        if(_formKey.currentState.validate()){
                          _dbHelper.createTask(new Task(0, taskNameController.text, taskIconController.text));
                          taskNameController.clear();
                          taskIconController.clear();
                          //TODO: Fix snackbar
                          // Scaffold
                          //     .of(context)
                          //     .showSnackBar(SnackBar(content: Text('Task created!')));
                          Navigator.pop(context);
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