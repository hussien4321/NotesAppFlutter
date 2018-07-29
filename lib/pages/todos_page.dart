import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import '../services/database.dart';
import '../model/todo.dart';
import '../utils/helpers/admob_snackbar.dart';
import '../utils/helpers/time_functions.dart';
import '../utils/views/loading_screen.dart';
import '../utils/views/progress_bar.dart';
import '../utils/views/countdown.dart';
import '../services/preferences.dart';
import '../services/notifications.dart';

class ToDosPage extends StatefulWidget {

  @override
  _ToDosPageState createState() => _ToDosPageState();
}

class _ToDosPageState extends State<ToDosPage> with TickerProviderStateMixin {
  DBHelper dbHelper;

  List<ToDo> todos = [];
  List<AnimationController> _countdownControllers = [];
  List<AnimationController> _colorControllers = [];

  bool loading;  

   GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Preferences preferences;
  NotificationService notificationService;

  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices: null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    birthday: new DateTime.now(),
    childDirected: true,
    gender: MobileAdGender.male,
  );
  BannerAd _bannerAd;

  @override
  void initState() {
      super.initState();
      
      // FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
      // _bannerAd = createBannerAd()..load()..show(
      //   anchorOffset: 56.0,
      //   anchorType: AnchorType.bottom,

      // );

      loading = true;
      dbHelper = new DBHelper();
      notificationService = new NotificationService();
      preferences = new Preferences();
      updatePage();
  }


  BannerAd createBannerAd() {
    return new BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }


  updatePage() async {

    List<ToDo> activeTodos = await dbHelper.getActiveToDos();
    if(mounted){
      if(todos != activeTodos){
        notificationService.cancelOpenNotifications(activeTodos, preferences.getNotificationSliderValue());
        initializeControllers(activeTodos);
        setState(() {
          todos = activeTodos;
          loading = false;
        });
      }
    }
  }
  
  initializeControllers(List<ToDo> todos){
    for(int i = 0; i < todos.length; i ++){
      AnimationController temp = new AnimationController(
        vsync: this,
        duration: todos[i].startDate.add(Duration(days: 1)).difference(TimeFunctions.nowToNearestSecond()),
      );
      _countdownControllers.add(temp);
      _countdownControllers[i].forward();
    }
    for(int i = 0; i < todos.length; i ++){
      AnimationController temp = new AnimationController(
        vsync: this,
        duration: todos[i].startDate.add(Duration(days: 1)).difference(TimeFunctions.nowToNearestSecond()),
      );
      _colorControllers.add(temp);
      _colorControllers[i].forward();
    }
  }

  @override
  void dispose() {
    for(int i = 0; i < _countdownControllers.length; i++){
      _countdownControllers[i].dispose();
    }
    for(int i = 0; i < _colorControllers.length; i++){
      _colorControllers[i].dispose();
    }
    // _bannerAd?.dispose();
    // _bannerAd = null;
    super.dispose();
  }

  
  
  @override
  Widget build(BuildContext context) {
    return loading ? LoadingScreen() : (todos.isEmpty ? noItemWidget() : notesListView(todos, dbHelper));
  }

  
  Widget noItemWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'You currently have no tasks to do 🤔',
            style: TextStyle(fontSize: 15.0),
          ),
          Padding(padding: EdgeInsets.only(top:10.0),),
          Text(
            'press + button below to add a new task',
            style: TextStyle(fontSize: 13.0, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget notesListView(List<ToDo> todos, DBHelper dbHelper){
    
    return Container(
      padding: EdgeInsets.only(bottom: 50.0),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text('Current tasks', 
              style: Theme.of(context).textTheme.headline
            ),
          ),
          Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int i) => taskDismassable(todos[i], dbHelper, i),
                itemCount: todos.length,
              ),
          ),
        ],
      ),
    );
  }


  Widget taskDismassable(ToDo todo, DBHelper dbHelper, int index){
    return Dismissible(
      key: Key(todo.id.toString()),
      dismissThresholds:  <DismissDirection, double>{DismissDirection.startToEnd: 0.6, DismissDirection.endToStart: 0.6, },
      onDismissed: (direction) {
        ToDo temp = todos[index];
        todos.removeAt(index);
        if(direction == DismissDirection.startToEnd){
          dbHelper.completeToDo(temp);
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Task completed 😁"),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => dbHelper.undoCompleteToDo(temp).then((res) => updatePage()),
            ),
          ));
        }else{
          dbHelper.giveUpToDo(temp);
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Task failed 😞"),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => dbHelper.undoGiveUpToDo(temp).then((res) => updatePage()),
            ),
          ));
        }
        _countdownControllers[index].dispose();
        _countdownControllers.removeAt(index);
        updatePage();      
        notificationService.cancelNotification(temp);
        notificationService.cancelOpenNotifications(todos, preferences.getNotificationSliderValue());
      },
      secondaryBackground: Container(
        padding: EdgeInsets.all(20.0),
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              'GIVE UP',
              style: TextStyle(fontSize: 20.0, letterSpacing: 2.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ), 
      background: Container(
        padding: EdgeInsets.all(20.0),
        color: Colors.green,
        child: Row(
          children: <Widget>[
            Text(
              'COMPLETE',
              style: TextStyle(fontSize: 20.0, letterSpacing: 2.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),

      child: todoBuilder(todo, dbHelper, index),
    );
  }

  Widget todoBuilder(ToDo todo, DBHelper dbHelper, int index){
    return Container(
      padding: EdgeInsets.all(3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Opacity(
              opacity: 0.8,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: Center(
                  child: Text(
                  '👉',
                  style: TextStyle(fontSize: 15.0,),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Image.asset(
                todo.task.icon,
                width: 50.0,
                height: 50.0,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    todo.task.name,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Column(
                      children: <Widget>[
                        ProgressBar(
                          animation: new StepTween(
                            begin: TimeFunctions.getRemainingTimeInSeconds(todo.startDate),
                            end: 0,
                          ).animate(_countdownControllers[index]),
                          colorAnimation: ColorTween(
                            begin: ColorTween (
                              begin: ColorTween (
                                begin:Colors.green[700],
                                end: Colors.yellow,  
                              ).lerp(_tweenPercentageGetter(TimeFunctions.getPercentageTimeRemaining(todo.startDate), true)),
                              end:Colors.red[700],
                            ).lerp(_tweenPercentageGetter(TimeFunctions.getPercentageTimeRemaining(todo.startDate), false)),
                            end: Colors.red[700],  
                          ).animate(_colorControllers[index]),
                        ),
                        Countdown(
                          animation: new StepTween(
                            begin: TimeFunctions.getRemainingTimeInSeconds(todo.startDate),
                            end: 0,
                          ).animate(_countdownControllers[index]),
                        ),
                      ],
                    ),
                  ),
                ],          
              )
            ),
            Padding(padding: EdgeInsets.only(right: 20.0),),
            Opacity(
              opacity: 0.8,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                ),
                child: Center(
                  child: Text(
                  '👈',
                  style: TextStyle(fontSize: 15.0, color: Colors.green),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  //this function helps me control a tween with a start, middle and end value. TODO: Make into 3-level Tween class 
  double _tweenPercentageGetter(double percentage, bool isBeginTween){

    if(percentage < 0.5){
      return isBeginTween ? percentage * 2 : 0.0;
    }else{
      return isBeginTween ? 1.0 : (percentage - 0.5)*2;
    }
  }
}