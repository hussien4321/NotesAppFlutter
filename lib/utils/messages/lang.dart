
//TODO: CREATE AS SINGLETON THAT CAN EXIST IN ONE THROUGHOUT THE ENTIRE APPLICATION TO AVOID PASSING IT THROUGH EVERYWHERE AND INITIALIZING IT MULTIPLE TIMES;
//TODO: Lookup locale
class Lang {
  
  String language;
  String path;

  Lang({String lang = "EN"}){
    language = lang;
    path = 'jsonDirectory'+language+'.json';
  }

  static String getMessageText(String key){
    //access path and pull string with that key or return key if not existing. 
    return null;
  }


}