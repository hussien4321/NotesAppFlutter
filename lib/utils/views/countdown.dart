import 'package:flutter/material.dart';
import '../helpers/time_functions.dart';

class Countdown extends AnimatedWidget {
  Countdown({ Key key, this.animation }) : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  build(BuildContext context){
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: Center(
        child: Text(
          TimeFunctions.getTimeInHMSFormat(animation.value),
          style: TextStyle(fontSize: 10.0, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
