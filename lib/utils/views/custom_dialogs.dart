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
  

  String title, description, yesText, noText;
  VoidCallback onYes, onNo;

  InfoDialog({this.title, this.description, this.yesText, this.noText, this.onYes, this.onNo});

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