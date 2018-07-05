import './task.dart';

class ToDo{

  int _id;
  Task _task;
  DateTime _startDate;
  bool _status;
  int _timeToCompletion;
  
  int get id => _id;
  Task get task => _task;
  DateTime get startDate => _startDate;
  bool get status => _status;
  int get timeToCompletion => _timeToCompletion;

  ToDo(int id, Task task){
    _id = id;
    _task = task;
    _startDate = DateTime.now();
    _status = false;
    _timeToCompletion = 0;
  }
  
  ToDo.fromJson(Map<String, dynamic> json)
      : _id = json['todo_id'],
        _task = Task.fromJson(json),
        _startDate = DateTime.parse(json['start_date']),
        _status = json['status'] == 'true',
        _timeToCompletion = json['time_to_completion'];


}
