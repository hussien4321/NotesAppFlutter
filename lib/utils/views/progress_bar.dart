import 'package:flutter/material.dart';

class ProgressBar extends AnimatedWidget{
  ProgressBar({ Key key, this.animation, this.colorAnimation}) : super(key: key, listenable: animation);
  final Animation<int> animation;
  final Animation<Color> colorAnimation;
  final int maxValue = Duration(days: 1).inSeconds;
  final int minus = Duration(hours: 0).inSeconds;

  
  @override
  build(BuildContext context){
    return         
      Container(
        decoration: new BoxDecoration(
          border: new Border.all(color: Colors.grey[700])
        ),
        child: LinearProgressIndicator(
          backgroundColor: Colors.grey[700],
          valueColor: colorAnimation,
          value: (animation.value-minus)/maxValue,
        ),
      );
  }
}

