class TimeFunctions {
  
  static String getRemainingTime(DateTime startDate){
    Duration difference = startDate.add(Duration(days: 1)).difference(nowToNearestSecond());
    int hours = difference.inHours;
    int minutes = difference.inMinutes - hours * 60;
    int seconds = difference.inSeconds - difference.inMinutes * 60;
    return hours.toString() + "h " + minutes.toString() + "m " + seconds.toString() + "s remaining";
  }

  static String getTimeInHMSFormat(int timeInSeconds){

    int hours = ((timeInSeconds/60).floor()/60).floor();
    String hoursString = hours < 10 ? '0'+hours.toString() : hours.toString();

    int minutes = (timeInSeconds/60).floor() - hours * 60;
    String minutesString = minutes < 10 ? '0'+minutes.toString() : minutes.toString();

    int seconds = timeInSeconds -  minutes * 60 - hours * 60 * 60;
    String secondsString = seconds < 10 ? '0'+seconds.toString() : seconds.toString();

    return hoursString + "h " + minutesString + "m " + secondsString + "s remaining";
  }

  static DateTime nowToNearestSecond(){
    DateTime timeNow = DateTime.now();
    return timeNow.subtract(Duration(milliseconds: timeNow.millisecond, microseconds: timeNow.microsecond));
      }

}
