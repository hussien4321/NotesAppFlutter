import 'package:flutter/material.dart';
import '../db/database.dart';
import '../utils/views/loading_screen.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  State createState() => new AnalyticsPageState();
}

class AnalyticsPageState extends State<AnalyticsPage> { 
  DBHelper dbHelper = new DBHelper();
  bool loading;

  int _numOfSuccesses;
  int _numOfFailures;

  @override
  void initState() {
      super.initState();
      dbSetUp();
      loading = true;
      _numOfSuccesses = 0;
      _numOfFailures = 0;
  }
  
  dbSetUp() async {
    await dbHelper.initDb();  
    updateAnalytics();
  }
  updateAnalytics(){
    dbHelper.getNumberOfSuccesses().then((res) {
      if(mounted){
        this.setState(() {
        if(_numOfSuccesses != res || loading) {
          setState(() {
              loading = false;
              _numOfSuccesses = res;
          });
        }
        });
      }
    }
    );
    dbHelper.getNumberOfFailures().then((res) {
      if(mounted){
          this.setState(() {
            if(_numOfFailures != res || loading) {
            setState(() {
                loading = false;
                _numOfFailures = res;
            });
            }
          });
      }
    });

  }

  @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return Center(
        child: loading ? LoadingScreen() : pageLayout(context),
      );
    }

    Widget pageLayout(BuildContext context){
      return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 5.0),
              child: Center(
                child: Text(
                  'All time stats',
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              )
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Success',
                    style: TextStyle(fontSize: 17.0,color: Colors.green[900]), 
                  ),
                ),
                Text(
                  _numOfSuccesses.toString(),
                  style: TextStyle(fontSize: 25.0, color: Colors.green[900], fontWeight: FontWeight.bold),
                ),
                Text(
                  '/',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  _numOfFailures.toString(),
                  style: TextStyle(fontSize: 25.0, color: Colors.red[900], fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    'Failures',
                    style: TextStyle(fontSize: 17.0,color: Colors.red[900]),
                    
                    textAlign: TextAlign.end, 
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(bottom: 5.0),
              child: Center(
                child: Text(
                  ((_numOfFailures + _numOfSuccesses != 0) ? ((_numOfSuccesses/(_numOfFailures+_numOfSuccesses))*100).round().toString():'0')+'% success rate',
                  style: TextStyle(fontSize: 13.0, color: Colors.grey[800], fontStyle: FontStyle.italic),
                ),
              )
            ),
          ],
        ),
      );
    }
}