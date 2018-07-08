class TimeFunctions {
  
  static String getRemainingTime(DateTime startDate){
    Duration difference = startDate.add(Duration(days: 1)).difference(DateTime.now());
    int hours = difference.inHours;
    int minutes = difference.inMinutes - hours * 60;
    int seconds = difference.inSeconds - difference.inMinutes * 60;
    return hours.toString() + "h " + minutes.toString() + "m " + seconds.toString() + "s remaining";
  }

  static String getTimeInHMSFormat(int timeInSeconds){
    int hours = ((timeInSeconds/60).floor()/60).floor();
    int minutes = (timeInSeconds/60).floor() - hours * 60;
    int seconds = timeInSeconds -  minutes * 60 - hours * 60 * 60;
    return hours.toString() + "h " + minutes.toString() + "m " + seconds.toString() + "s remaining";
  }

}
