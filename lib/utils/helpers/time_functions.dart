class TimeFunctions {
  
  static String getRemainingTime(DateTime startDate){
    Duration difference = startDate.add(Duration(days: 1)).difference(DateTime.now());

    print(difference.toString().substring(0,8)+' remianing');

    int hours = difference.inHours;
    int minutes = difference.inMinutes - hours * 60;
    int seconds = difference.inSeconds - difference.inMinutes * 60;
    return hours.toString() + "h " + minutes.toString() + "m " + seconds.toString() + "s remaining";
  }
}
