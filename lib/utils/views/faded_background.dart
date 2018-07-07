import 'package:flutter/material.dart';


Widget fadedBackground({Widget child}) {
  return Container(
    decoration: BoxDecoration(
      gradient: new LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey, Colors.white], 
        tileMode: TileMode.repeated,
      ),
    ),
    child: child, 
  );
}