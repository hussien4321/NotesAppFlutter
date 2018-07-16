import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../model/todo.dart';
import '../model/task.dart';
import '../model/graph_data.dart';
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
      new Task(9, 'Cook dinner', '🍽️', true),
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
    String path = join(documentsDirectory.path, "test.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  resetDb() async {
    var database = await db;
    
    await database
      .rawDelete('DELETE FROM Task');
    await database
      .rawDelete('DELETE FROM Todo');
    await database.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO task(name, icon, recommended, creation_date, deleted) VALUES '+_generateRecommnendedTasksScript());
    });

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
  Future<int> createToDo(ToDo todo) async {
  var database = await db;

    return await database.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO todo(task_fid, start_date, success, completion_date, forfeit) VALUES('+todo.task.id.toString()+', "'+todo.startDate.toIso8601String()+'", "'+todo.success.toString()+'", "'+todo.completionDate.toIso8601String()+'", "'+todo.forfeit.toString()+'")');
    });
  }


  //TODO: Check if todo exists and is active
  undoCreateToDo(ToDo todo) async {
  var database = await db;

    return await database.transaction((txn) async {
      return await txn.rawInsert(
          'DELETE FROM todo WHERE todo_id = "'+todo.id.toString()+'"');
    });
  }


  //TODO: Check if task exists with same name and icon
  createTask(Task task) async {
  var database = await db;
  
  return await database.transaction((txn) async {
      return await txn.rawInsert(
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

  
  undoCompleteToDo(ToDo todo) async {
    var database = await db;

    await database.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE Todo SET success = "false" WHERE todo_id = '+todo.id.toString());
    });
  }
  
  giveUpToDo(ToDo todo) async {
    var database = await db;

    await database.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ToDo SET completion_date= "'+TimeFunctions.nowToNearestSecond().toIso8601String()+'", forfeit = "true" WHERE todo_id = '+todo.id.toString());
    });
  }

  
  undoGiveUpToDo(ToDo todo) async {
    var database = await db;

    await database.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ToDo SET forfeit = "false", completion_date= "'+todo.startDate.add(Duration(days: 1)).toIso8601String()+'" WHERE todo_id = '+todo.id.toString());
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

    List<Map> list = await dbClient.rawQuery('SELECT * FROM todo, task WHERE task.task_id = todo.task_fid AND forfeit = "false" AND success = "false" AND datetime(start_date) > datetime("'+dateRange+'")');
    List<ToDo> todos = new List();
    for (int i = 0; i < list.length; i++) {
      todos.add(new ToDo.fromJson(list[i]));
    }
    return todos;
  }

  Future<List<Task>> getAllTasks() async {
    var dbClient = await db;

    List<Map> usedTasksList = await dbClient.rawQuery('SELECT task_id, name, icon, recommended, creation_date FROM task, todo WHERE task.task_id = todo.task_fid AND deleted = "false" GROUP BY task_id ORDER BY datetime(start_date) DESC');
    
    List<Map> unusedDefaultTasksList= await dbClient.rawQuery('SELECT * FROM task WHERE (SELECT COUNT(todo.task_fid) FROM todo WHERE todo.task_fid == task.task_id) = 0 AND deleted = "false" AND recommended = "true" ORDER BY task_id DESC;');
    
    List<Task> tasks = new List();

    for (int i = 0; i < usedTasksList.length; i++) {
      tasks.add(new Task.fromJson(usedTasksList[i]));
    }
    for (int i = 0; i < unusedDefaultTasksList.length; i++) {
      tasks.add(new Task.fromJson(unusedDefaultTasksList[i]));
    }
    
    return tasks; 
  }


  Future<int> getNumberOfSuccesses() async {
    var dbClient = await db;

    List<Map> list = await dbClient.rawQuery('SELECT COUNT(*) AS "successes" FROM todo WHERE success = "true"');
    Map answer = list[0];
    
    return answer['successes']; 
  }

  Future<int> getNumberOfFailures() async {
    var dbClient = await db;

    String yesterdayTime = TimeFunctions.nowToNearestSecond().subtract(Duration(days: 1)).toIso8601String();
    //TODO : (date < yesterday AND success = "false") OR forfeit = "true"
    List<Map> list = await dbClient.rawQuery('SELECT COUNT(*) AS "failures" FROM todo WHERE forfeit = "true" OR (datetime(start_date) < datetime("'+yesterdayTime+'") AND success = "false")');
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

  Future<Task> getMostSuccessfulTask() async {
    var dbClient = await db;
    String yesterdayTime = TimeFunctions.nowToNearestSecond().subtract(Duration(days: 1)).toIso8601String();
    
    List<Map> successes = await dbClient.rawQuery('SELECT COUNT(*) AS "count", task_id, name, icon, recommended, creation_date FROM task, todo WHERE task_fid = task_id AND success = "true" GROUP BY task_id ORDER BY COUNT(*) DESC, start_date ASC LIMIT 1');

    if(successes.isNotEmpty){
      Task task = new Task.fromJson(successes[0]);
      return task;
    }
    else{
      return null;
    }
  }

  Future<Task> getLeastSuccessfulTask() async {
    var dbClient = await db;
    String yesterdayTime = TimeFunctions.nowToNearestSecond().subtract(Duration(days: 1)).toIso8601String();
    
    List<Map> failures = await dbClient.rawQuery('SELECT COUNT(*) AS "count", task_id, name, icon, recommended, creation_date FROM task, todo WHERE task_fid = task_id AND (forfeit = "true" OR ((datetime(start_date) < datetime("'+yesterdayTime+'")) AND success = "false")) GROUP BY task_id ORDER BY COUNT(*) DESC, start_date ASC LIMIT 1');
    
    if(failures.isNotEmpty){
      Task task = new Task.fromJson(failures[0]);
      return task;
    }
    else{
      return null;
    }
  }


  Future<List<GraphData>> getNumberOfSuccessesPerDay([int numberOfDays = 7]) async {
    var dbClient = await db;
    
    List<GraphData> plot = [];
    DateTime todaysDate = TimeFunctions.nowToNearestSecond();
    DateTime endDate = todaysDate;
    for(int i = 0; i < numberOfDays; i++){
      plot.add(new GraphData(endDate, 0));
      endDate = endDate.subtract(Duration(days: 1));
    }

    List<Map> successes = await dbClient.rawQuery('SELECT COUNT(*) AS "successPerDay", completion_date FROM task, todo t2 WHERE t2.task_fid = task.task_id AND t2.success = "true" AND date(completion_date) > date("'+endDate.toIso8601String()+'") GROUP BY date(completion_date)');

    for (int i = 0; i < successes.length; i++) {
      Map answer = successes[i];
      DateTime tempDate = DateTime.parse(answer['completion_date']);
      
      if(tempDate.isBefore(todaysDate) && tempDate.isAfter(endDate)){
        plot.forEach((innerList) {
          if(innerList.startDate.day == tempDate.day){
            innerList.setValue(answer['successPerDay']);
          }
        });
      }
    }
    return plot;
  }

  Future<List<GraphData>> getNumberOfFailuresPerDay([int numberOfDays = 7]) async {
    var dbClient = await db;
    
    List<GraphData> plot = [];
    DateTime todaysDate = TimeFunctions.nowToNearestSecond();
    DateTime endDate = todaysDate;
    for(int i = 0; i < numberOfDays; i++){
      plot.add(new GraphData(endDate, 0));
      endDate = endDate.subtract(Duration(days: 1));
    }

    String yesterdayTime = todaysDate.subtract(Duration(days: 1)).toIso8601String();
    List<Map> failures = await dbClient.rawQuery('SELECT COUNT(*) AS "failuresPerDay", completion_date FROM task, todo t3 WHERE t3.task_fid = task.task_id AND date(completion_date) > date("'+endDate.toIso8601String()+'") AND (t3.forfeit = "true" OR ((datetime(t3.start_date) < datetime("'+yesterdayTime+'")) AND t3.success = "false")) GROUP BY date(completion_date)');

    for (int i = 0; i < failures.length; i++) {
      Map answer = failures[i];
      DateTime tempDate = DateTime.parse(answer['completion_date']);
      
      if(tempDate.isBefore(todaysDate) && tempDate.isAfter(endDate)){
        plot.forEach((innerList) {
          if(innerList.startDate.day == tempDate.day){
            innerList.setValue(answer['failuresPerDay']);
          }
        });
      }
    }
    
    return plot;
  }


  Future<int> getAverageTimeToComplete() async {
    var dbClient = await db;
    int seconds = 0;

    List<Map> list = await dbClient.rawQuery('SELECT AVG(julianday(completion_date) - julianday(start_date)) AS "difference" FROM todo WHERE success = "true"');

    if(list.isNotEmpty){
      double difference = list[0]['difference'];
      seconds = (difference * 86400).round();
    }
    return seconds;
  }

  // getNumberOfFailuresPerDay();



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
  // getNumberOfSuccess();            DONEZO
  // getNumberOfFailures();           DONEZO
  // getNumberOfSuccessPerDay();
  // getNumberOfFailuresPerDay();

  // getMostSuccessfulTasks();
  // getLeastSuccessfulTasks();

  // getAverageTaskTime();
  

}