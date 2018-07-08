import 'package:flutter/material.dart';

// incomplete
class CustomPageRoute<T> extends MaterialPageRoute<T> {
  CustomPageRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => Duration(seconds: 1);


  //TODO: Update to get desired transition circle expanding to show behind layer
  @override
  Widget buildTransitions(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (settings.isInitialRoute)
      return child;

    return Opacity(
      opacity: animation.value, 
      child: child,
    );
  }
}
