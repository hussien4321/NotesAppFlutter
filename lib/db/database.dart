import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

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
    String path = join(documentsDirectory.path, "test.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  // Creating a table name Employee with fields
  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
    "CREATE TABLE habit ( id integer primary key, name text, icon text, start_date text, start_allowance integer, goal_allowance integer, type integer)");
    await db.execute("CREATE TABLE history ( id integer primary key, decrement integer date_of_action text, habit_id integer REFERENCES habit(id) ON UPDATE CASCADE )");
    await db.execute("CREATE TABLE Milestone ( id integer primary key, habit_id integer REFERENCES habit(id) ON UPDATE CASCADE, allowance integer, start_date text, end_date text, achieved boolean );");
    print("Created tables");
  }
  
  // Retrieving employees from Employee Tables
  // Future<List<Employee>> getEmployees() async {
  //   var dbClient = await db;
  //   List<Map> list = await dbClient.rawQuery('SELECT * FROM Employee');
  //   List<Employee> employees = new List();
  //   for (int i = 0; i < list.length; i++) {
  //     employees.add(new Employee(list[i]["firstname"], list[i]["lastname"], list[i]["mobileno"], list[i]["emailid"]));
  //   }
  //   print(employees.length);
  //   return employees;
  // }


}