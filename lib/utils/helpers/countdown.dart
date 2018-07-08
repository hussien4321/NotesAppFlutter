import 'package:flutter/material.dart';
import './time_functions.dart';
class Countdown extends AnimatedWidget {
  Countdown({ Key key, this.animation }) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context){
    return new Text(
      TimeFunctions.getTimeInHMSFormat(animation.value),
      style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
    );
  }
}

