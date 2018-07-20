import 'package:flutter/material.dart';


Widget fadedBackground({Widget child}) {

  final Color _topColor = Colors.white;
  final Color _bottomColor = Colors.grey; 
  
  return Container(
    padding: EdgeInsets.only(top: 25.0),
    decoration: BoxDecoration(
      gradient: new LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_bottomColor, _topColor], 
        tileMode: TileMode.repeated,
      ),
    ),
    child: child, 
  );
}