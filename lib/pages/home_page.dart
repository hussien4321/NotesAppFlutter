import 'package:flutter/material.dart';
import './todos_page.dart';
import './analytics_page.dart';
import './tasks_page.dart';
import './history_page.dart';
import '../services/preferences.dart';
import './settings_page.dart';
import '../utils/views/faded_background.dart';
import '../utils/views/custom_bottom_bar.dart' as customBar;
import '../utils/helpers/custom_page_routes.dart';
import '../utils/views/custom_dialogs.dart';

class HomePage extends StatefulWidget {

  int _index;
  HomePage([this._index = 0]);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Color _iconColor = Colors.grey;
  final Color _textColor = Colors.black;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int index = 0;

  bool adsPaidStatus = false;
  Preferences preferences;

  @override
  initState(){
    index = widget._index;
    preferences = new Preferences();
    initPage();
    super.initState();
  }

  initPage() async{
    bool newAdsPaidStatus = await preferences.getAdsPaidStatus();
    setState(() {
      adsPaidStatus =  newAdsPaidStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 35.0),
        color: Colors.orange[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Opacity(
                  opacity: 0.0,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.info, size: 30.0,),
                  ),
                ),Expanded(
                  child: Text(
                    _generateHeaderText(), 
                    style: Theme.of(context).textTheme.headline,
                    textAlign: TextAlign.center,
                  ),
                ),
                Opacity(
                  opacity: index == 0 ? 1.0 : 0.0,
                  child: IconButton(
                    onPressed: () {
                      if(index ==0 ){
                        showDialog(
                          context: context,
                          builder: (newContext) {
                            return InfoDialog(onConfirm: () => Navigator.of(newContext).pop(),);
                          },
                        );
                      }
                    },
                    icon: Icon(Icons.info, size: 30.0,),
                  ),
                ),
              ], 
            ),
            Expanded(
              child: buildScaffold(),
            ),
            (index !=2 && !adsPaidStatus) ? Material(
              color: Colors.orange[100],
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 1.5),
                  ),
                ),
                child: SizedBox(
                height: 50.0,
                child: 
                Center(
                      child: Text(
                      'We hope you are enjoying our app.\nIf you have a minute, please leave us a review!',
                      style: TextStyle(fontSize: 10.0, color: Colors.orange[800], fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    )
                  ),
                )
              ), 
            ) : Container(),
          ],
        ),
      ),
      
      bottomNavigationBar: new customBar.CustomBottomNavigationBar(
        currentIndex: index,
        onTap: (int ind) async { 
            if(ind==2){
              int temp = index;
              setState(() {              
                this.index = 2;
              });
              await Navigator.push(context, CustomPageRoute(
                builder: (BuildContext context) => TasksPage()),
              );  
              Navigator.of(context).pushAndRemoveUntil(new NoAnimationPageRoute(builder: (BuildContext context) => HomePage(temp)),
                (Route route) => route == null
              );
            }else{
              _scaffoldKey.currentState.removeCurrentSnackBar();
              setState(() {              
                this.index = ind;
              });
            }

        },
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          navigationBarItem(Icons.check, "Tasks", 0),
          navigationBarItem(Icons.storage, "History", 1),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Icon(Icons.add_circle, color: Colors.orangeAccent, size: 40.0,)
            ),
            title: Text("", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),),
          ),
          navigationBarItem(Icons.timeline, "Analytics", 3),
          navigationBarItem(Icons.settings, "Settings", 4),
        ],
      ),
    );
  }

  String _generateHeaderText(){
    return (index == 0 ? 'TASKS' : (index == 1 ? 'HISTORY' : (index == 3 ? 'ANALYTICS' : (index == 4 ? 'SETTINGS' : ''))));
  }

  Widget buildScaffold(){
    return Scaffold(
      key: _scaffoldKey,
      body: fadedBackground(
        child: Stack(
          children: <Widget>[
            index == 0 ? ToDosPage() : Container(),
            index == 1 ? HistoryPage() : Container(),
            index == 3 ? AnalyticsPage() : Container(),
            index == 4 ? SettingsPage() : Container(),
          ],
        ),
      ),
    );
  }

  Widget offSetPage(Widget page, int i){
    return Offstage(
      offstage: index != i,
      child: TickerMode(
        enabled: index == i,
        child: page,
      ),
    );
  }

  BottomNavigationBarItem navigationBarItem(IconData icon, String text, int i){
    return BottomNavigationBarItem(
      icon: Icon(icon, color: (index==i)?_textColor: _iconColor,),
      title: Text(text, style: TextStyle(color: (index==i)?_textColor: _iconColor),),
    );
  }
}