import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {

  String headerText;
  VoidCallback onClose, onInfo;

  PageHeader({this.headerText, this.onClose, this.onInfo});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5.0),
      child: Row(
        children: <Widget>[
          onClose == null ? Container() : IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close),
          ),
          Expanded(
            child: Center(
              child: Text(
                headerText, 
                style: TextStyle(
                  fontWeight: FontWeight.w300, fontSize: 30.0,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onInfo,
            icon: Icon(Icons.info_outline),
          ),
        ],
      )
    );
  }
}