import 'package:flutter/material.dart';
import '../../model/task.dart';

class TaskView extends StatelessWidget{
  
  final Task _task;
  bool _isEditMode;

  TaskView(this._task, this._isEditMode);

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
                      print('task with id '+_task.id.toString()+' is '+(_isEditMode ? 'edited!' : 'started!')); 
                      if(!_isEditMode)
                        Navigator.of(context).pop();
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