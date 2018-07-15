import 'package:flutter/material.dart';
import '../db/database.dart';
import '../model/todo.dart';
import '../model/task.dart';
import './analytics_page.dart';
import './settings_page.dart';
import './todos_page.dart';
import '../utils/helpers/time_functions.dart';
import '../utils/views/countdown.dart';
import '../utils/views/progress_bar.dart';
import '../utils/helpers/custom_page_route.dart';
import '../utils/views/faded_background.dart';
import '../utils/views/loading_screen.dart';
import './tasks_page.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    //TODO: Separate tab controller to a file 
    return DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => TasksPage()),
                  );
                },
                icon: Icon(Icons.add),
              )
            ],
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.check)),
                Tab(icon: Icon(Icons.assessment)),
                Tab(icon: Icon(Icons.settings)),
              ],
            ),
            title: Text('24h Tasks ⏳'),
          ),
          body: fadedBackground(
            //TODO: Override TabBarView to remove the scrolling animation on page change
            child: TabBarView(
              physics: new NeverScrollableScrollPhysics(),
              children: [
                ToDosPage(),
                AnalyticsPage(),
                SettingsPage(),
              ],
            ),
          ),
        ),
      );
  }  


}