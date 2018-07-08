import './task.dart';

class ToDo{

  int _id;
  Task _task;
  DateTime _startDate;
  bool _success;
  DateTime _completionDate;
  bool _forfeit;

  int get id => _id;
  Task get task => _task;
  DateTime get startDate => _startDate;
  bool get success => _success;
  DateTime get completionDate => _completionDate;
  bool get forfeit => _forfeit;

  ToDo(int id, Task task){
    _id = id;
    _task = task;
    _startDate = DateTime.now();
    _success = false;
    _completionDate = DateTime.now();
    _forfeit = false;
  }
  
  ToDo.fromJson(Map<String, dynamic> json)
      : _id = json['todo_id'],
        _task = Task.fromJson(json),
        _startDate = DateTime.parse(json['start_date']),
        _success = json['success'] == 'true',
        _completionDate = DateTime.parse(json['completion_date']),
        _forfeit = json['forfeit'] == 'true';


}

