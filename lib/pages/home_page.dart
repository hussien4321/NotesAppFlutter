import 'package:flutter/material.dart';
import './todos_page.dart';
import './analytics_page.dart';
import './tasks_page.dart';
import './history_page.dart';
import './emoji_selector_page.dart';
import './settings_page.dart';
import '../utils/views/faded_background.dart';
import '../utils/views/custom_bottom_bar.dart' as customBar;
import '../utils/helpers/custom_page_routes.dart';

class HomePage extends StatefulWidget {

  int _index;
  HomePage([this._index = 0]);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Color _iconColor = Colors.grey;
  final Color _textColor = Colors.black;

  int index = 0;


  @override
  initState(){
    index = widget._index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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