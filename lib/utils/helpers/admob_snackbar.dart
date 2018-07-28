import 'package:flutter/material.dart';

const double _kSnackBarPadding = 24.0;
const double _kSingleLineVerticalPadding = 14.0;
const Color _kSnackBackground = const Color(0xFF323232);

// TODO(ianh): We should check if the given text and actions are going to fit on
// one line or not, and if they are, use the single-line layout, and if not, use
// the multiline layout. See link above.

// TODO(ianh): Implement the Tablet version of snackbar if we're "on a tablet".

const Duration _kSnackBarTransitionDuration = const Duration(milliseconds: 250);
const Duration _kSnackBarDisplayDuration = const Duration(milliseconds: 1500);
const Curve _snackBarHeightCurve = Curves.fastOutSlowIn;
const Curve _snackBarFadeCurve = const Interval(0.72, 1.0, curve: Curves.fastOutSlowIn);

class AdmobSnackBar extends SnackBar {
  /// Creates a snack bar.
  ///
  /// The [content] argument must be non-null.
  const AdmobSnackBar({
    Key key,
    @required this.content,
    this.backgroundColor,
    this.action,
    this.duration: _kSnackBarDisplayDuration,
    this.animation,
  }) : assert(content != null),
       super(key: key,
    content: content,
    backgroundColor: backgroundColor,
    action: action,
    duration: duration,
    animation: animation,
);

  /// The primary content of the snack bar.
  ///
  /// Typically a [Text] widget.
  final Widget content;

  /// The Snackbar's background color. By default the color is dark grey.
  final Color backgroundColor;

  /// (optional) An action that the user can take based on the snack bar.
  ///
  /// For example, the snack bar might let the user undo the operation that
  /// prompted the snackbar. Snack bars can have at most one action.
  ///
  /// The action should not be "dismiss" or "cancel".
  final SnackBarAction action;

  /// The amount of time the snack bar should be displayed.
  ///
  /// Defaults to 1.5s.
  ///
  /// See also:
  ///
  ///  * [ScaffoldState.removeCurrentSnackBar], which abruptly hides the
  ///    currently displayed snack bar, if any, and allows the next to be
  ///    displayed.
  ///  * <https://material.google.com/components/snackbars-toasts.html>
  final Duration duration;

  /// The animation driving the entrance and exit of the snack bar.
  final Animation<double> animation;

  Widget originalBuild(BuildContext context){
        assert(animation != null);
    final ThemeData theme = Theme.of(context);
    final ThemeData darkTheme = new ThemeData(
      brightness: Brightness.dark,
      accentColor: theme.accentColor,
      accentColorBrightness: theme.accentColorBrightness,
    );
    final List<Widget> children = <Widget>[
      const SizedBox(width: _kSnackBarPadding),
      new Expanded(
        child: new Container(
          padding: const EdgeInsets.symmetric(vertical: _kSingleLineVerticalPadding),
          child: new DefaultTextStyle(
            style: darkTheme.textTheme.subhead,
            child: content,
          ),
        ),
      ),
    ];
    if (action != null) {
      children.add(new ButtonTheme.bar(
        padding: const EdgeInsets.symmetric(horizontal: _kSnackBarPadding),
        textTheme: ButtonTextTheme.accent,
        child: action,
      ));
    } else {
      children.add(const SizedBox(width: _kSnackBarPadding));
    }
    final CurvedAnimation heightAnimation = new CurvedAnimation(parent: animation, curve: _snackBarHeightCurve);
    final CurvedAnimation fadeAnimation = new CurvedAnimation(parent: animation, curve: _snackBarFadeCurve, reverseCurve: const Threshold(0.0));
    return new ClipRect(
      child: new AnimatedBuilder(
        animation: heightAnimation,
        builder: (BuildContext context, Widget child) {
          return new Align(
            alignment: AlignmentDirectional.topStart,
            heightFactor: heightAnimation.value,
            child: child,
          );
        },
        child: new Semantics(
          container: true,
          child: new Dismissible(
            key: const Key('dismissible'),
            direction: DismissDirection.down,
            resizeDuration: null,
            onDismissed: (DismissDirection direction) {
              Scaffold.of(context).removeCurrentSnackBar(reason: SnackBarClosedReason.swipe);
            },
            child: new Material(
              elevation: 6.0,
              color: backgroundColor ?? _kSnackBackground,
              child: new Theme(
                data: darkTheme,
                child: new FadeTransition(
                  opacity: fadeAnimation,
                  child: new SafeArea(
                    top: false,
                    child: new Row(
                      children: children,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        originalBuild(context),
        Padding(padding: EdgeInsets.only(top: 50.0),)
      ],
    );
  }

  

  /// Creates a copy of this snack bar but with the animation replaced with the given animation.
  ///
  /// If the original snack bar lacks a key, the newly created snack bar will
  /// use the given fallback key.
  SnackBar withAnimation(Animation<double> newAnimation, { Key fallbackKey }) {
    return new SnackBar(
      key: key ?? fallbackKey,
      content: content,
      backgroundColor: backgroundColor,
      action: action,
      duration: duration,
      animation: newAnimation,
    );
  }
}