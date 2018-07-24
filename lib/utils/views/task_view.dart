import 'package:flutter/material.dart';
import '../../model/task.dart';
import '../../model/todo.dart';
import '../../db/database.dart';
import 'dart:async';

class TaskView extends StatelessWidget{
  
  final Task _task;
  bool _isEditMode;
  final VoidCallback onPressed;
  

  TaskView(this._task, this._isEditMode, this.onPressed);

  
  @override
  Widget build(BuildContext context){
    return Container(
          padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Image.asset(
                    _task.icon,
                    width: 32.0,
                    height: 32.0,
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
                onPressed == null ? Container() : Padding(
                  padding: EdgeInsets.all(5.0),
                  child: RaisedButton(
                    onPressed: onPressed,
                    child: Text(_isEditMode  ? 'Edit' : 'Start'),
                    color: _isEditMode  ? Colors.greenAccent : Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
        );
    }
}

class SimpleTaskView extends StatelessWidget{
  
  final Task _task;
  final Color color;

  SimpleTaskView(this._task, this.color);

  
  @override
  Widget build(BuildContext context){
    return Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right:5.0),
                  child: Image.asset(
                    _task.icon,
                    width: 32.0,
                    height: 32.0,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Text(
                      _task.name,
                      style: TextStyle(fontSize: 17.0, color: color),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
        );
    }
}