import 'package:flutter/material.dart';

class YesNoDialog extends StatelessWidget {
  

  String title, description, yesText, noText;
  VoidCallback onYes, onNo;

  YesNoDialog({this.title, this.description, this.yesText, this.noText, this.onYes, this.onNo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0),),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text(description),
            Container(
              padding: EdgeInsets.only(left: 5.0, right:5.0, bottom: 5.0, top: 10.0),
              child : Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Colors.redAccent,
                      elevation: 2.0,
                      child: Text(noText, style: TextStyle(color: Colors.black),),
                      onPressed: onNo
                    ),
                  ),
                  Padding( padding: EdgeInsets.all(5.0)),
                  Expanded(
                    child: RaisedButton(
                      color: Colors.greenAccent,
                      elevation: 2.0,
                      child: Text(yesText, style: TextStyle(color: Colors.black),),
                      onPressed: onYes
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: null,
    );
  }
}

class InfoDialog extends StatelessWidget {
  
  VoidCallback onConfirm;

  InfoDialog({this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('How to complete tasks', textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0),),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text('All tasks have a 24 hour time limit, if the time limit expires then it becomes a failed task.',style: TextStyle(fontSize: 11.0),),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            new Image.asset(
              'assets/guidance/task.png',
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            new Text('To finish a task, you can:',style: TextStyle(fontSize: 11.0),),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            new Image.asset(
              'assets/guidance/task_pass.png',
            ),
            Padding(padding: EdgeInsets.only(bottom: 5.0)),
            new Text('SWIPE RIGHT to submit it as successful', style: TextStyle(fontSize: 11.0),),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            new Image.asset(
              'assets/guidance/task_fail.png',
            ),
            Padding(padding: EdgeInsets.only(bottom: 5.0)),
            new Text('SWIPE LEFT to submit it as a failure',style: TextStyle(fontSize: 11.0),),
            Container(
              padding: EdgeInsets.only(left: 5.0, right:5.0, bottom: 5.0, top: 20.0),
              child : Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Colors.orange,
                      elevation: 2.0,
                      child: Text('I understand', style: TextStyle(color: Colors.black),),
                      onPressed: onConfirm
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: null,
    );
  }
}