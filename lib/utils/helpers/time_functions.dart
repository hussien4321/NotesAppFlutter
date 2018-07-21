class TimeFunctions {
  
  static String getRemainingTimeAsStirng(DateTime startDate){
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

    return hoursString + "h " + minutesString + "m " + secondsString + "s";
  }

  static String getTimeInHMSFormatNoTrailingZeros(int timeInSeconds){

    int hours = ((timeInSeconds/60).floor()/60).floor();
    String hoursString = hours.toString();

    int minutes = (timeInSeconds/60).floor() - hours * 60;
    String minutesString = minutes.toString();

    int seconds = timeInSeconds -  minutes * 60 - hours * 60 * 60;
    String secondsString = seconds.toString();

    return hoursString + "h " + minutesString + "m " + secondsString + "s";
  }

  static String getDayOfWeek(DateTime date){
    switch (date.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    };
  }

  static String getDateAsShortString(DateTime date){

    String dayOfWeek = getDayOfWeek(date);
    
    int months = date.month;
    String monthsAsString = ((months < 10) ? '0' : '') + months.toString();

    int days = date.day;
    String daysAsString = ((days < 10) ? '0' : '') + days.toString();

    int hours = date.hour;
    String hoursAsString = hours < 10 ? '0'+hours.toString() : hours.toString();

    int minutes = date.minute;
    String minutesAsString = minutes < 10 ? '0'+minutes.toString() : minutes.toString();


    return dayOfWeek +' '+ monthsAsString + '/' + daysAsString + ' (' +hoursAsString+':' +minutesAsString+ ')';
  }

  static DateTime nowToNearestSecond(){
    DateTime timeNow = DateTime.now();
    return timeNow.subtract(Duration(milliseconds: timeNow.millisecond, microseconds: timeNow.microsecond));
      }

  static int getRemainingTimeInSeconds(DateTime startDate){
    return startDate.add(Duration(days: 1)).difference(nowToNearestSecond()).inSeconds;
  }

  static double getPercentageTimeRemaining(DateTime startDate){
    int max = Duration(days: 1).inSeconds;
    int current = getRemainingTimeInSeconds(startDate);
    double percentage = (max - current) /max;
    return percentage;
  }
}
