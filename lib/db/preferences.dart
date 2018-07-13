import 'package:path_provider/path_provider.dart';


class Preferences {


  Preferences(){
    
  }

  bool isNotificationsEnabled(){
    return true;
  }

  int getNotificationSliderValue(){
    return 12;
  }
}