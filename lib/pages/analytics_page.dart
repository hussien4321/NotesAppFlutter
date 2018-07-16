import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../db/database.dart';
import '../utils/views/loading_screen.dart';
import '../utils/views/task_view.dart';
import '../model/task.dart';
import '../model/graph_data.dart';
import '../utils/views/line_graph.dart';
import '../utils/helpers/time_functions.dart';

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
  
  int avgTimeInSeconds;

  Task mostSuccessfulTask;
  Task leastSuccessfulTask;

  @override
  void initState() {
      super.initState();
      dbSetUp();
      loading = true;
      _numOfSuccesses = 0;
      _numOfFailures = 0;
      successPlotData = [];
      failurePlotData = [];
      avgTimeInSeconds = 0;
      mostSuccessfulTask = null;
      leastSuccessfulTask = null;
  }
  
  dbSetUp() {
    updateAnalytics();
  }


  updateAnalytics() async {
    _numOfSuccesses = await dbHelper.getNumberOfSuccesses();
    _numOfFailures = await dbHelper.getNumberOfFailures();
    successPlotData = await dbHelper.getNumberOfSuccessesPerDay();
    failurePlotData = await dbHelper.getNumberOfFailuresPerDay();
    avgTimeInSeconds = await dbHelper.getAverageTimeToComplete();
    mostSuccessfulTask = await dbHelper.getMostSuccessfulTask();
    leastSuccessfulTask = await dbHelper.getLeastSuccessfulTask();
    
    if(mounted){
      if(loading) {
        setState(() {
            loading = false;
        });
      }
    }

  }

  @override
    Widget build(BuildContext context) {
      return Center(
        child: loading ? LoadingScreen() : pageLayout(context),
      );
    }

    Widget pageLayout(BuildContext context){
      return Container(
        padding: EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            header('All time stats',true),
            Container(
              decoration: new BoxDecoration(
                border: new Border(bottom: BorderSide(color: Colors.grey[800], width: 0.5), top: BorderSide(color: Colors.grey[800], width: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: header('Total success/fails'),
                  ),   
                  Expanded(
                    child:showNumSuccessesAndFailures(),    
                  ),
                ],
              ),
            ),
            Container(
              decoration: new BoxDecoration(
                border: new Border(bottom: BorderSide(color: Colors.grey[800], width: 0.5)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: header('Most successful task'),
                  ),
                  Expanded( 
                    child: (mostSuccessfulTask != null) ? 
                      SimpleTaskView(mostSuccessfulTask, Colors.green[900]) : 
                      Text('Not enough data', style: TextStyle(fontSize: 18.0), textAlign: TextAlign.end,overflow: TextOverflow.clip,),    
                  ),
                ],
              ),
            ),
            Container(
              decoration: new BoxDecoration(
                border: new Border(bottom: BorderSide(color: Colors.grey[800], width: 0.5)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: header('Least successful task'),
                  ),
                  Expanded(
                    child: (leastSuccessfulTask != null) ? 
                      SimpleTaskView(leastSuccessfulTask, Colors.red[900]) : 
                      Text('Not enough data', style: TextStyle(fontSize: 18.0), textAlign: TextAlign.end,),    
                  ),
                ],
              ),
            ),
            Container(
              decoration: new BoxDecoration(
                border: new Border(bottom: BorderSide(color: Colors.grey[800], width: 0.5)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: header('Average time to complete'),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0, top: 10.0),
                      child: Text(
                      TimeFunctions.getTimeInHMSFormatNoTrailingZeros(avgTimeInSeconds),
                        style: TextStyle(fontSize: 16.0, color: Colors.grey[800], fontStyle: FontStyle.italic),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
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
      padding: bold ? EdgeInsets.all(15.0) : EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0, top: 10.0),
      child: Text(
        headerText,
        style: TextStyle(color: bold ? Colors.orange[900] : Colors.black,fontWeight: bold? FontWeight.bold: FontWeight.normal, fontSize: bold ? 20.0:16.0,),
      ),
    );
  }

  Widget showNumSuccessesAndFailures(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
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
            Text(
            '('+((_numOfFailures + _numOfSuccesses != 0) ? ((_numOfSuccesses/(_numOfFailures+_numOfSuccesses))*100).round().toString():'0')+'%)',
              style: TextStyle(fontSize: 13.0, color: Colors.grey[800], fontStyle: FontStyle.italic),
            )
          ],
        ),
      ], 
    );
  }

}