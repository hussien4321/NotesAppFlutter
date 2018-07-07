import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {

    @override
    State createState() => new LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {


  Animation<double> _animation;
  AnimationController _animationController;


  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(duration: new Duration(seconds: 3), vsync: this);
    _animation = new CurvedAnimation(parent: _animationController, curve: Curves.easeInOut,);
    _animation.addListener(() => this.setState(() {}));
    _animationController.repeat();
  }

  @override
  void dispose(){
    _animationController.dispose();
    super.dispose();
  }


  @override
    Widget build(BuildContext context) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              backgroundColor: Colors.grey,
              value: 1.0 * _animation.value,
            ),
            Padding(padding: EdgeInsets.only(bottom: 15.0)),
            Text('Loading...'),
          ],
        ),
      );
    }
}