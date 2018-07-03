import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../model/todo.dart';

class DBHelper{

  static Database _db;

  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // await deleteDatabase(documentsDirectory.path);
    String path = join(documentsDirectory.path, "test.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  // Creating a table name Employee with fields
  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute("CREATE TABLE todo ( id integer primary key, name text, start_date text, status boolean)");
    // await db.execute("CREATE TABLE habit ( id integer primary key, name text, icon text, start_date text, start_allowance integer, goal_allowance integer, type integer)");
    // await db.execute("CREATE TABLE history ( id integer primary key, decrement integer date_of_action text, habit_id integer REFERENCES habit(id) ON UPDATE CASCADE )");
    // await db.execute("CREATE TABLE Milestone ( id integer primary key, habit_id integer REFERENCES habit(id) ON UPDATE CASCADE, allowance integer, start_date text, end_date text, achieved boolean );");
    print("Created tables");
  }


  addToDoItem(ToDo todo) async {
  var database = await db;
  
  await database.transaction((txn) async {
    await txn.rawInsert(
        'INSERT INTO ToDo(name, start_date, status) VALUES("'+todo.name+'", "'+todo.startDate.toIso8601String()+'", "'+todo.status.toString()+'")');
  });
  }


  completeToDo(ToDo todo) async {
    var database = await db;

    await database.transaction((txn) async {
      int id1 = await txn.rawUpdate(
          'UPDATE ToDo SET status = "true" WHERE name = "'+todo.name+'" AND start_date = "'+todo.startDate.toIso8601String()+'"');
    });
  }
  // Retrieving employees from Employee Tables
  Future<List<ToDo>> getToDos() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM todo');
    List<ToDo> todos = new List();
    for (int i = 0; i < list.length; i++) {
      todos.add(new ToDo.fromJson(list[i]));
    }
    return todos;
  }


}