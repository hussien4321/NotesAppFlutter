import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../model/todo.dart';
import '../model/task.dart';
import '../utils/helpers/time_functions.dart';

class DBHelper{

  static List<Task> _recommendedTasks = [
      new Task(1, 'Read 1 chapter of a book', '📕', true),
      new Task(2, 'Pay bills', '💰', true),
      new Task(3, 'Go to the bank', '🏦', true),
      new Task(4, 'Take a walk', '🏞️', true),
      new Task(5, 'Check email', '📧', true),
      new Task(6, 'Make reservation', '📞', true),
      new Task(7, 'Take medicine', '💊', true),
      new Task(8, 'Get Haircut', '💇🏻', true),
      new Task(9,'Cook dinner', '🍽️', true),
      new Task(10,'Go grocery shopping', '🛒', true),
      new Task(11,'Finish homework', '📝', true),
      new Task(12,'Exercise', '🏋️', true),
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
      result+='("'+temp.name+'","'+temp.icon+'","'+temp.recommended.toString()+'","'+temp.creationDate.toIso8601String()+'", "false")';
      result+= i == (_recommendedTasks.length - 1) ? '' : ', ';
    }

    return result;
  }

  void _onCreate(Database db, int version) async {

    await db.execute("CREATE TABLE todo( todo_id integer primary key, task_fid integer REFERENCES task(task_id) ON UPDATE CASCADE ON DELETE CASCADE, start_date text, success boolean, completion_date text, forfeit boolean)");


    await db.execute("CREATE TABLE task (task_id integer primary key, name text, icon text, recommended boolean, creation_date text, deleted boolean)");

    //adds in recommended tasks for people getting started
    await db.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO task(name, icon, recommended, creation_date, deleted) VALUES '+_generateRecommnendedTasksScript());
    });

    print("Created tables");
  }


  //TODO: Check if todo exists and is active
  createToDo(ToDo todo) async {
  var database = await db;
  
    await database.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO todo(task_fid, start_date, success, completion_date, forfeit) VALUES('+todo.task.id.toString()+', "'+todo.startDate.toIso8601String()+'", "'+todo.success.toString()+'", "'+todo.completionDate.toIso8601String()+'", "'+todo.forfeit.toString()+'")');
    });
  }


  //TODO: Check if task exists with same name and icon
  createTask(Task task) async {
  var database = await db;
  
    await database.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO task(name, icon, recommended, creation_date, deleted) VALUES("'+task.name+'","'+task.icon+'","'+task.recommended.toString()+'","'+task.creationDate.toIso8601String()+'", "false")');
    });
  }

  deleteTask(Task task) async {
    var database = await db;

    await database
      .rawDelete('UPDATE Task SET deleted = "true" WHERE task_id = '+task.id.toString());
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
          'UPDATE Todo SET success = "true", completion_date= "'+TimeFunctions.nowToNearestSecond().toIso8601String()+'" WHERE todo_id = '+todo.id.toString());
    });
  }
  
  giveUpToDo(ToDo todo) async {
    var database = await db;

    await database.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ToDo SET completion_date= "'+TimeFunctions.nowToNearestSecond().toIso8601String()+'", forfeit = "true" WHERE todo_id = '+todo.id.toString());
    });
  }

  updateTask(Task task) async {
    var database = await db;

    await database.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE task SET name = "'+task.name+'", icon= "'+task.icon+'" WHERE task_id = '+task.id.toString());
    });
  }
  

  Future<List<ToDo>> getActiveToDos() async {
    var dbClient = await db;

    String dateRange = TimeFunctions.nowToNearestSecond().subtract(Duration(days: 1)).toIso8601String();

    List<Map> list = await dbClient.rawQuery('SELECT * FROM todo, task WHERE task.task_id = todo.task_fid AND forfeit = "false" AND success = "false" AND start_date > datetime("'+dateRange+'")');
    List<ToDo> todos = new List();
    for (int i = 0; i < list.length; i++) {
      todos.add(new ToDo.fromJson(list[i]));
    }
    return todos;
  }

  //TODO: the first 2 lists need to joined based on the creation_date from list 1 and the start_date from list 2
  Future<List<Task>> getAllTasks() async {
    var dbClient = await db;

    List<Map> unusedNewTasksList= await dbClient.rawQuery('SELECT * FROM task WHERE (SELECT COUNT(todo.task_fid) FROM todo WHERE todo.task_fid == task.task_id) = 0 AND deleted = "false" AND recommended = "false" ORDER BY datetime(creation_date) DESC;');

    List<Map> usedTasksList = await dbClient.rawQuery('SELECT task_id, name, icon, recommended, creation_date FROM task, todo WHERE task.task_id = todo.task_fid AND deleted = "false" GROUP BY task_id ORDER BY datetime(start_date) DESC');
    
    //could be updated to sort by creation date instead of id
    List<Map> unusedDefaultTasksList= await dbClient.rawQuery('SELECT * FROM task WHERE (SELECT COUNT(todo.task_fid) FROM todo WHERE todo.task_fid == task.task_id) = 0 AND deleted = "false" AND recommended = "true" ORDER BY task_id DESC;');
    
    List<Task> tasks = new List();
    
    for (int i = 0; i < unusedNewTasksList.length; i++) {
      tasks.add(new Task.fromJson(unusedNewTasksList[i]));
    }
    for (int i = 0; i < usedTasksList.length; i++) {
      tasks.add(new Task.fromJson(usedTasksList[i]));
    }
    for (int i = 0; i < unusedDefaultTasksList.length; i++) {
      tasks.add(new Task.fromJson(unusedDefaultTasksList[i]));
    }
    
    return tasks; 
  }


  Future<List<Task>> getNumberOfSuccess() async {
    var dbClient = await db;

    List<Map> list = await dbClient.rawQuery('SELECT COUNT(*) AS "successes" FROM todo WHERE success = "true"');
    Map answer = list[0];
    
    return answer['successes']; 
  }

  Future<List<Task>> getNumberOfFailures() async {
    var dbClient = await db;

    //TODO : (date < yesterday AND success = "false") OR forfeit = "true"
    List<Map> list = await dbClient.rawQuery('SELECT COUNT(*) AS "failures" FROM todo WHERE forfeit = "true"');
    Map answer = list[0];
    
    return answer['failures']; 
  }

  Future<List<ToDo>> getToDos() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM todo, task WHERE todo.task_fid = task.task_id');
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

  // getActiveToDos();                DONEZO? 

  // getRecentTasks();                DONEZO
  // getRecommendedTasks();           DONEZO

  // //analytics
  // getNumberOfSuccess();            DONEZO
  // getNumberOfFailures();           DONEZO
  // getNumberOfSuccessPerDay();
  // getNumberOfFailuresPerDay();

  // getMostSuccessfulTasks();
  // getLeastSuccessfulTasks();

  // getAverageTaskTime();
  

}