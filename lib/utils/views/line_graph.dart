import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/behaviors/chart_behavior.dart' show ChartBehavior;
import 'package:charts_flutter/src/behaviors/line_point_highlighter.dart' show LinePointHighlighter;

import 'package:flutter/material.dart';
import '../../model/graph_data.dart';

class LineGraph extends StatelessWidget {
  final bool animate;
  List<charts.Series<GraphData, DateTime>> seriesList;

  LineGraph(List<GraphData> successDataPoints, List<GraphData> failureDataPoints, {this.animate = false}){
    seriesList= [];
    if(failureDataPoints.isNotEmpty){
      seriesList.add(
        new charts.Series<GraphData, DateTime>(
          id: 'Failures',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          dashPattern: [8,4],
          domainFn: (GraphData data, _) => data.startDate,
          measureFn: (GraphData data, _) => data.value,
          data: failureDataPoints,
        )
      );
    }
    if(successDataPoints.isNotEmpty){
      seriesList.add(
        new charts.Series<GraphData, DateTime>(
          id: 'Succcesses',
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          domainFn: (GraphData data, _) => data.startDate,
          measureFn: (GraphData data, _) => data.value,
          data: successDataPoints,
        )
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      animationDuration: Duration(milliseconds: 500),
      behaviors: [new LinePointHighlighter(defaultRadiusPx: 0.0, radiusPaddingPx: 0.0, showHorizontalFollowLine: false, showVerticalFollowLine: false)],
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

}