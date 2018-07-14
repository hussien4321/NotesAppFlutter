import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';


class Preferences {

  static final String LANGUAGE = 'notificationsEnabled';
  static final String NOTIFICATIONS_ENABLED = 'notificationsEnabled';
  static final String NOTIFICATIONS_DELAY = 'notificationDelay';
  static final String ADS_PAID_STATUS = 'adsPaidStatus';

  final Map<String, dynamic> initialPreferences = {
    'language' : 'GB',
    'notificationsEnabled' : false,
    'notificationDelay' : 12,
    'adsPaidStatus' : false,
  };

  Map<String, dynamic> currentPreferences = {};

  final String fileName = 'preferences.json';
  File jsonFile;
  
  initialize() async {

    await getApplicationDocumentsDirectory().then((Directory directory) {
      Directory dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      bool fileExists = jsonFile.existsSync();
      if (fileExists){
        currentPreferences = JSON.decode(jsonFile.readAsStringSync());
      } else {
        currentPreferences = initialPreferences;
        _createPreferencesFile(currentPreferences);
      }
    });
  }

  updatePreferences() async {
    currentPreferences = JSON.decode(jsonFile.readAsStringSync());
  }

  void _createPreferencesFile(Map<String, dynamic> content) {
    print("Creating file!");
    jsonFile.createSync();
    jsonFile.writeAsStringSync(JSON.encode(content));
  }

  void updatePreference(String key, dynamic value) {
    Map<String, dynamic> content = {key: value};
    Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
    jsonFileContent.addAll(content);
    print('updated preferences : '+jsonFileContent.toString());
    currentPreferences = jsonFileContent;
    jsonFile.writeAsStringSync(JSON.encode(jsonFileContent));
  }


  bool isNotificationsEnabled(){
    return currentPreferences['notificationsEnabled'];
  }

  int getNotificationSliderValue(){
    return currentPreferences['notificationDelay'];
  }
}