import 'package:flutter/material.dart';
import './todos_page.dart';
import './analytics_page.dart';
import './tasks_page.dart';
import './history_page.dart';
import './emoji_selector_page.dart';
import './settings_page.dart';
import '../utils/views/faded_background.dart';
import '../utils/views/custom_bottom_bar.dart' as customBar;
import '../utils/helpers/custom_page_route.dart';

class NewTabsPage extends StatefulWidget {


  @override
  _NewTabsPageState createState() => _NewTabsPageState();
}

class _NewTabsPageState extends State<NewTabsPage> {

  final Color _iconColor = Colors.grey;
  final Color _textColor = Colors.black;

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: fadedBackground(
        child: Stack(
          children: <Widget>[
            offSetPage(ToDosPage(),0),
            offSetPage(EmojiSelectorPage(),1),
            offSetPage(AnalyticsPage(),3),
            offSetPage(SettingsPage(),4),
          ],
        ),
      ),
      bottomNavigationBar: new customBar.CustomBottomNavigationBar(
        currentIndex: index,
        onTap: (int index) { setState((){ 
            if(index==2){
              Navigator.push(context, CustomPageRoute(
                builder: (BuildContext context) => TasksPage()),
              );
            }else{
              this.index = index;
            }
          }); 
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