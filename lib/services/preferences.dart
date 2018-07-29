import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';


class Preferences {


  static final String GRAPH_EXPANDED = 'graphExpanded';
  static final String GRAPH_RANGE = 'graphRange';
  static final String LANGUAGE = 'notificationsEnabled';
  static final String NOTIFICATIONS_ENABLED = 'notificationsEnabled';
  static final String NOTIFICATIONS_DELAY = 'notificationDelay';
  static final String ADS_PAID_STATUS = 'adsPaidStatus';

  final Map<String, dynamic> _initialPreferences = {
    'graphExpanded' : false,
    'graphRange' : 7,
    'language' : 'GB',
    'notificationsEnabled' : false,
    'notificationDelay' : 12,
    'adsPaidStatus' : false,
  };

  Map<String, dynamic> _currentPreferences = {};

  Future<Map<String, dynamic>> get currentPreferences async {
    if(_currentPreferences.length != 0){
      return _currentPreferences;
    }
    await reInitiliaze();
    return _currentPreferences;
  }
  final String _fileName = 'preferences.json';
  static File _jsonFile;
  
  static final Preferences _singleton = new Preferences._internal();

  factory Preferences() {
    return _singleton;
  }

  Preferences._internal() {
    reInitiliaze();
  }

  reInitiliaze() async {
    Directory directory = await getApplicationDocumentsDirectory();
    Directory dir = directory;
    _jsonFile = new File(dir.path + "/" + _fileName);
    bool fileExists = _jsonFile.existsSync();
    if (fileExists){
      _currentPreferences = JSON.decode(_jsonFile.readAsStringSync());
    } else {
      _currentPreferences = _initialPreferences;
      _createPreferencesFile(_currentPreferences);
    }
  }

  void _createPreferencesFile(Map<String, dynamic> content) {
    _jsonFile.createSync();
    _jsonFile.writeAsStringSync(JSON.encode(content));
  }

  void updatePreference(String key, dynamic value) {
    Map<String, dynamic> content = {key: value};
    Map<String, dynamic> jsonFileContent = json.decode(_jsonFile.readAsStringSync());
    jsonFileContent.addAll(content);
    _currentPreferences = jsonFileContent;
    _jsonFile.writeAsStringSync(JSON.encode(jsonFileContent));
  }

//make async

  Future<bool> isGraphExapnded() async {
    var preferences = await currentPreferences;

    return preferences['graphExpanded'];
  }

  Future<int> getGraphRange() async {
    var preferences = await currentPreferences;

    return preferences['graphRange'];
  }

  Future<bool> isNotificationsEnabled() async {
    var preferences = await currentPreferences;

    return preferences['notificationsEnabled'];
  }

  Future<bool> getAdsPaidStatus() async {
    var preferences = await currentPreferences;

    return preferences['adsPaidStatus'];
  }

  Future<int> getNotificationSliderValue() async {
    var preferences = await currentPreferences;

    return preferences['notificationDelay'];
  }
}