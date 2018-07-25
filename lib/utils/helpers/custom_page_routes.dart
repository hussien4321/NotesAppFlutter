import 'package:flutter/material.dart';

class CustomPageRoute<T> extends MaterialPageRoute<T> {
  CustomPageRoute({ WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);


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
      child: SlideTransition(
        position: new Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation),
        child: new SlideTransition(
          position: new Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0.0, 1.0),
          ).animate(secondaryAnimation),
        child: child,
        ),
      ),
    );

  }
}


class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);


  @override
  Widget buildTransitions(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (settings.isInitialRoute)
      return child;

    return child;

  }
}
