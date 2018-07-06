import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../model/todo.dart';
import '../model/task.dart';


class DBHelper{

  static List<Task> _recommendedTasks = [
      new Task(1,'Exercise', '🏋️', true),
      new Task(2,'Finish homework', '📝', true),
      new Task(3,'Go Grocery shopping', '🛒', true),
      new Task(4,'Cook dinner', '🍽️', true),
    ];
  static Database _db;

  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // await deleteDatabase(documentsDirectory.path);
    String path = join(documentsDirectory.path, "test.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }


  String _generateRecommnendedTasksScript(){

    String result = '';
    for(int i = 0; i < _recommendedTasks.length; i++){
      Task temp = _recommendedTasks[i];
      result+='("'+temp.name+'","'+temp.icon+'",'+temp.recommended.toString()+',"'+temp.creationDate.toIso8601String()+'")';
      result+= i == (_recommendedTasks.length - 1) ? '' : ', ';
    }
    return result;
  }

  void _onCreate(Database db, int version) async {

    //creates our 2 tables
    await db.execute("CREATE TABLE todo( todo_id integer primary key, task_fid integer REFERENCES task(task_id) ON UPDATE CASCADE ON DELETE CASCADE, start_date text, status boolean, completion_date text, forfeit boolean)");
    await db.execute("CREATE TABLE task (task_id integer primary key, name text, icon text, recommend boolean, creation_date text)");

    //adds in recommended tasks for people getting started
    await db.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO task(name, icon, recomended, creation_date) VALUES '+_generateRecommnendedTasksScript());
    });

    print("Created tables");
  }


  createToDo(ToDo todo) async {
  var database = await db;
  
    await database.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO todo(task_fid, start_date, status, completion_date, forfeit) VALUES('+todo.task.id.toString()+', "'+todo.startDate.toIso8601String()+'", "'+todo.status.toString()+'", "'+todo.completionDate.toIso8601String()+'", '+todo.forfeit.toString()+')');
    });
  }


  createTask(Task task) async {
  var database = await db;
  
    await database.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO task(name, icon, recomended, creation_date) VALUES("'+task.name+'","'+task.icon+'",'+task.recommended.toString()+',"'+task.creationDate.toIso8601String()+'")');
    });
  }

  deleteTask(Task task) async {
    var database = await db;

    await database
      .rawDelete('DELETE FROM Task WHERE task_id = '+task.id.toString());
  }

  
  
  deleteTodo(ToDo todo) async {
    var database = await db;

    await database
      .rawDelete('DELETE FROM Todo WHERE todo_id = '+todo.id.toString());
  }

  completeToDo(ToDo todo) async {
    var database = await db;

    await database.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ToDo SET status = "true", completion_date= "'+DateTime.now().toIso8601String()+'" WHERE todo_id = '+todo.id.toString());
    });
  }
  
  giveUpToDo(ToDo todo) async {
    var database = await db;

    await database.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ToDo SET completion_date= "'+DateTime.now().toIso8601String()+'", forfeit = "true" WHERE todo_id = '+todo.id.toString());
    });
  }
  

  Future<List<ToDo>> getActiveToDos() async {
    var dbClient = await db;

    String dateRange = DateTime.now().subtract(Duration(days: 1)).toIso8601String();

    List<Map> list = await dbClient.rawQuery('SELECT * FROM todo, task WHERE task.task_id = todo.task_fid AND forfeit = "false" AND status = "false" AND start_date > date("'+dateRange+'")');
    List<ToDo> todos = new List();
    for (int i = 0; i < list.length; i++) {
      todos.add(new ToDo.fromJson(list[i]));
    }
    return todos;
  }

  Future<List<Task>> getRecentTasks() async {
    var dbClient = await db;

    List<Map> list = await dbClient.rawQuery('SELECT * FROM task WHERE recommended = "false" ORDER BY date(creation_date) DESC');
    List<Task> tasks = new List();
    for (int i = 0; i < list.length; i++) {
      tasks.add(new Task.fromJson(list[i]));
    }
    return tasks; 
  }

  Future<List<Task>> getRecommendedTasks() async {
    var dbClient = await db;

    List<Map> list = await dbClient.rawQuery('SELECT * FROM task WHERE recommended = "true"');
    List<Task> tasks = new List();
    for (int i = 0; i < list.length; i++) {
      tasks.add(new Task.fromJson(list[i]));
    }
    return tasks; 
  }

  Future<List<ToDo>> getToDos() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM todo');
    List<ToDo> todos = new List();
    for (int i = 0; i < list.length; i++) {
      todos.add(new ToDo.fromJson(list[i]));
    }
    return todos;
  }


  // createNewTask(Task task);        DONEZO
  // createNewToDo(ToDo todo);        DONEZO


  // deleteTask(Task task);           DONEZO
  // deleteToDo(ToDo todo);           DONEZO 
  // completeToDo(ToDo todo);         DONEZO
  // giveUpToDo(ToDo todo);           DONEZO

  // getActiveToDos();                DONEZO  

  // getRecentTasks();                DONEZO
  // getRecommendedTasks();           DONEZO

  // //analytics
  // getNumberOfSuccess();
  // getNumberOfFailures();
  // getNumberOfSuccessPerDay();
  // getNumberOfFailuresPerDay();

  // getMostSuccessfulTasks();
  // getLeastSuccessfulTasks();

  // getAverageTaskTime();
  

}

//TEST QUERIES
// CREATE TABLE task( task_id integer primary key, name text);

// CREATE TABLE todo( todo_id integer primary key, task_fid integer REFERENCES task(task_id) ON UPDATE CASCADE, info text);

// INSERT INTO task(name) 
// VALUES ('go running'), ('buy dinner'), ('make dinner'), ('read chapter of book');

// INSERT INTO todo(task_fid, info)
// VALUES (4, 'PASSED'), (3, 'FAILED'), (2, 'WORKING ON IT');  

// select * from task, todo where task.task_id = todo.task_fid;