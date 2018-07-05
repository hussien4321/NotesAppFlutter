import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../model/todo.dart';
import '../model/task.dart';


class DBHelper{

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


  void _onCreate(Database db, int version) async {

    await db.execute("CREATE TABLE todo ( id integer primary key, name text, start_date text, status boolean)");
    print("Created tables");
  }


  addToDoItem(Task task) async {
  var database = await db;
  
  await database.transaction((txn) async {
    await txn.rawInsert(
        'INSERT INTO ToDo(name, start_date, status) VALUES("'+'todo.name'+'", "'+'todo.startDate.toIso8601String()'+'", "'+'todo.status.toString()'+'")');
  });
  }


  completeToDo(ToDo todo) async {
    var database = await db;

    await database.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ToDo SET status = "true" WHERE name = "'+'todo.name'+'" AND start_date = "'+'todo.startDate.toIso8601String()'+'"');
    });
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


  // createNewTask(Task task);
  // createNewToDo(ToDo todo);
  // completeToDo(ToDo todo);
  // restartToDo(ToDo todo);

  // getActiveToDos();

  // getRecentTasks();
  // getRecommendedTasks();

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