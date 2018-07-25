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

  final String _fileName = 'preferences.json';
  static File _jsonFile;
  
  
  static final Preferences _singleton = new Preferences._internal();

  factory Preferences() {
    return _singleton;
  }

  Preferences._internal(){
    getApplicationDocumentsDirectory().then((Directory directory) {
      Directory dir = directory;
      _jsonFile = new File(dir.path + "/" + _fileName);
      bool fileExists = _jsonFile.existsSync();
      if (fileExists){
        currentPreferences = JSON.decode(_jsonFile.readAsStringSync());
      } else {
        currentPreferences = initialPreferences;
        _createPreferencesFile(currentPreferences);
      }
    });
  }

  updatePreferences() async {
    currentPreferences = JSON.decode(_jsonFile.readAsStringSync());
  }

  void _createPreferencesFile(Map<String, dynamic> content) {
    _jsonFile.createSync();
    _jsonFile.writeAsStringSync(JSON.encode(content));
  }

  void updatePreference(String key, dynamic value) {
    Map<String, dynamic> content = {key: value};
    Map<String, dynamic> jsonFileContent = json.decode(_jsonFile.readAsStringSync());
    jsonFileContent.addAll(content);
    currentPreferences = jsonFileContent;
    _jsonFile.writeAsStringSync(JSON.encode(jsonFileContent));
  }


  bool isNotificationsEnabled(){
    return currentPreferences['notificationsEnabled'];
  }

  int getNotificationSliderValue(){
    return currentPreferences['notificationDelay'];
  }
}