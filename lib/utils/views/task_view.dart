import 'package:flutter/material.dart';
import '../../model/task.dart';
import '../../model/todo.dart';
import '../../db/database.dart';

class TaskView extends StatelessWidget{
  
  final Task _task;
  bool _isEditMode;
  DBHelper _dbHelper;

  TaskView(this._task, this._isEditMode, this._dbHelper);

  
  @override
  Widget build(BuildContext context){
    return Container(
          padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    _task.icon,
                    style: TextStyle(fontSize: 30.0, ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                  padding: EdgeInsets.all(5.0),
                    child: Text(
                    _task.name,
                    style: TextStyle(fontSize: 20.0,),
                    textAlign: TextAlign.start,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: RaisedButton(
                    onPressed: () {
                      if(!_isEditMode){
                        _dbHelper.createToDo(new ToDo(0, _task));
                        Navigator.of(context).pop();
                      }
                      else{
                        //TODO: EDIT ACTIVITY
                      }
                    },
                    child: Text(_isEditMode  ? 'Edit' : 'Start'),
                    color: _isEditMode  ? Colors.greenAccent : Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
        );
    }
}