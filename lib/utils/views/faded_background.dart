import 'package:flutter/material.dart';


Widget fadedBackground({Widget child}) {

  final Color _topColor = Colors.white;
  final Color _bottomColor = Colors.orange[200]; 
  
  return Container(
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