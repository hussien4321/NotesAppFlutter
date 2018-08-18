import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import '../services/database.dart';
import '../services/preferences.dart';
import '../utils/views/loading_screen.dart';
import '../utils/views/task_view.dart';
import '../model/task.dart';
import '../model/graph_data.dart';
import '../utils/views/line_graph.dart';
import '../utils/helpers/time_functions.dart';
import '../utils/helpers/admob_tools.dart';
import 'dart:io' show Platform;

class AnalyticsPage extends StatefulWidget {
  @override
  State createState() => new AnalyticsPageState();
}

class AnalyticsPageState extends State<AnalyticsPage> { 
  DBHelper dbHelper = new DBHelper();
  bool loading;
  bool showStats = true;

  int graphRange = 7;

  int _numOfSuccesses;
  int _numOfFailures;

  List<GraphData> successPlotData = [];
  List<GraphData> failurePlotData = [];
  
  int avgTimeInSeconds;

  Task mostSuccessfulTask;
  Task leastSuccessfulTask;

  Preferences preferences;

  BannerAd _bannerAd;

  @override
  void initState() {
      super.initState();

      loading = true;
      preferences = new Preferences();
      _numOfSuccesses = 0;
      _numOfFailures = 0;
      successPlotData = [];
      failurePlotData = [];
      avgTimeInSeconds = 0;
      mostSuccessfulTask = null;
      leastSuccessfulTask = null;
      initAds();
      updateAnalytics();
      
  }

  
  initAds() async {
    bool adsPaidStatus = await preferences.getAdsPaidStatus();
    if(!adsPaidStatus){
      _bannerAd = createBannerAd()..load();    
    }
  }

  BannerAd createBannerAd() {
    return new BannerAd(
      adUnitId: AdmobTools.analyticsPageAdUnitId,
      size: AdSize.banner,
      targetingInfo: AdmobTools.targetingInfo,
      listener: (MobileAdEvent event) {
        if(mounted){
          _bannerAd..show(
            anchorOffset: 56.0,
            anchorType: AnchorType.bottom, 
          );
        }
      },
    );
  }


  updateAnalytics() async {
    showStats = !(await preferences.isGraphExapnded());
    graphRange = await preferences.getGraphRange();
    _numOfSuccesses = await dbHelper.getNumberOfSuccesses();
    _numOfFailures = await dbHelper.getNumberOfFailures();
    successPlotData = await dbHelper.getNumberOfSuccessesPerDay(graphRange);
    failurePlotData = await dbHelper.getNumberOfFailuresPerDay(graphRange);
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
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }


  updateGraph() async {
    List<GraphData> newSuccessPlotData = await dbHelper.getNumberOfSuccessesPerDay(graphRange);
    List<GraphData> newFailurePlotData = await dbHelper.getNumberOfFailuresPerDay(graphRange);

    setState(() {
       successPlotData = newSuccessPlotData;
       failurePlotData = newFailurePlotData;   
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
        padding: EdgeInsets.only(bottom: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: header('All time stats',true),
                ),
                RaisedButton(
                  color: Colors.orange,
                  onPressed: (){
                    preferences.updatePreference(Preferences.GRAPH_EXPANDED, showStats);
                    setState(() {
                      showStats = !showStats;
                    });
                  },                  
                  child: Text(showStats ? 'Hide data' : 'Show data',),
                ),
                Padding(padding: EdgeInsets.only(right: 5.0),),
              ],
            ),
            showStats ? Container(
              child: Column(
                children: <Widget>[
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
                        flex: 2,
                        child: header('Average completion time'),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.only(right: 5.0),
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
                ],
              ),
            ) : Container(),
            Row(
              children: <Widget>[
                Expanded(
                  child: header(((graphRange == 7) ? 'Last week' : (graphRange == 30 ? 'Last month': 'Last Year')),true),
                ),
                RaisedButton(
                  color: Colors.orange,
                  onPressed: (){
                    graphRange = (graphRange == 7) ? 30 : (graphRange == 30 ? 365 : 7);
                    preferences.updatePreference(Preferences.GRAPH_RANGE, graphRange);
                    updateGraph();
                  },                  
                  child: Text('Change time',),
                ),
                Padding(padding: EdgeInsets.only(right: 5.0),),
              ],
            ),
            Expanded(
              child: successPlotData.isNotEmpty ? new LineGraph(successPlotData, failurePlotData, animate: false) : Center( child: Text('not enough data')),
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
        style: TextStyle(color: bold ? Colors.orange[900] : Colors.black,fontWeight: bold? FontWeight.bold: FontWeight.w300, fontSize: bold ? 20.0:16.0,),
      ),
    );
  }

  Widget showNumSuccessesAndFailures(){
    return Container(
      padding: EdgeInsets.only(right: 5.0),
      child: Row(
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
            ' ('+((_numOfFailures + _numOfSuccesses != 0) ? ((_numOfSuccesses/(_numOfFailures+_numOfSuccesses))*100).round().toString():'0')+'%)',
              style: TextStyle(fontSize: 13.0, color: Colors.grey[800]),
            )
          ],
        ),
    );
  }

}