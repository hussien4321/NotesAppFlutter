import 'package:firebase_admob/firebase_admob.dart';
import 'dart:io' show Platform;

class AdmobTools {
  
  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices: <String>[],
    keywords: <String>['productivity', 'lifestyle', 'tasks', 'todo-lists', 'self improvement', 'goals', 'exercise', 'fitness', 'health'],
  );

  static final String appId = FirebaseAdMob.testAppId;
  // Platform.isAndroid
  //     ? 'ca-app-pub-3787115292798141~9637684042'
  //     : 'ca-app-pub-3787115292798141~4567414097';

  static final String adUnitId = BannerAd.testAdUnitId;
  //  Platform.isAndroid
  //     ? 'ca-app-pub-3787115292798141/5912285356'
  //     : 'ca-app-pub-3787115292798141/6618862362';



}