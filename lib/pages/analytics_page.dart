import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../db/database.dart';
import '../utils/views/loading_screen.dart';
import '../utils/views/task_view.dart';
import '../model/task.dart';
import '../model/graph_data.dart';
import '../utils/views/line_graph.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  State createState() => new AnalyticsPageState();
}

class AnalyticsPageState extends State<AnalyticsPage> { 
  DBHelper dbHelper = new DBHelper();
  bool loading;

  int _numOfSuccesses;
  int _numOfFailures;

  List<GraphData> successPlotData = [];
  List<GraphData> failurePlotData = [];

  @override
  void initState() {
      super.initState();
      dbSetUp();
      loading = true;
      _numOfSuccesses = 0;
      _numOfFailures = 0;
  }
  
  dbSetUp() async {
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
                _numOfFailures = res;
            });
            }
          });
      }
    });
    dbHelper.getNumberOfSuccessesPerDay().then((listOfPoints){
      setState(() {
        successPlotData = listOfPoints;
        loading = false;
      });
    });
    dbHelper.getNumberOfFailuresPerDay().then((listOfPoints){
      setState(() {
        failurePlotData = listOfPoints;
        loading = false;
      });
    });

  }

  @override
    Widget build(BuildContext context) {
      return Center(
        child: loading ? LoadingScreen() : pageLayout(context),
      );
    }

    Widget pageLayout(BuildContext context){
      return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            header('All time stats',true),
            showNumSuccessesAndFailures(),
            Container(
              padding: EdgeInsets.only(bottom: 5.0),
              child: Center(
                child: Text(
                  ((_numOfFailures + _numOfSuccesses != 0) ? ((_numOfSuccesses/(_numOfFailures+_numOfSuccesses))*100).round().toString():'0')+'% success rate',
                  style: TextStyle(fontSize: 13.0, color: Colors.grey[800], fontStyle: FontStyle.italic),
                ),
              )
            ),
            Row(
              children: <Widget>[
                header('Most successful'),
                Expanded(
                  child:SimpleTaskView(Task(1,'aaaa','🤔'), Colors.green[900]),    
                ),
              ],
            ),
            Row(
              children: <Widget>[
                header('Least successful'),
                Expanded(
                  child:SimpleTaskView(Task(1,'nooo','🙈'), Colors.red[900]),    
                ),
              ],
            ),
            Row(
              children: <Widget>[
                header('Average time to finish tasks'),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0, top: 10.0),
                    child: Text(
                      '2h 30m 21s',
                      style: TextStyle(fontSize: 16.0,),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
            header('Last 7 days',true),
            Expanded(
              child: successPlotData.isNotEmpty ? new LineGraph(successPlotData, failurePlotData, animate: true) : Center( child: Text('not enough data')),
            ),
          ],
        ),
      );
    }

    
  Widget header(String headerText, [bool bold = false]){
    return Container(
      padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0, top: 10.0),
      child: Text(
        headerText,
        style: TextStyle(color: Colors.black,fontWeight: bold? FontWeight.bold: FontWeight.normal, fontSize: bold ? 20.0:16.0,),
      ),
    );
  }

  Widget showNumSuccessesAndFailures(){
    return Row(
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
    );
  }

}