import 'package:flutter/material.dart';


Widget fadedBackground({Widget child}) {

  final Color _bottomColor = Colors.orange[100]; 
  final Color _topColor = Colors.white;
  
  return Container(
    decoration: BoxDecoration(
      color: Colors.orange[100],
      // gradient: new LinearGradient(
      //   begin: Alignment.topCenter,
      //   end: Alignment.bottomCenter,
      //   colors: [_bottomColor, _topColor], 
      //   tileMode: TileMode.repeated,
      // ),
    ),
    child: child, 
  );
}