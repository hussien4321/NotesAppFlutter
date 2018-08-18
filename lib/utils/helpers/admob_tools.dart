import 'package:firebase_admob/firebase_admob.dart';
import 'dart:io' show Platform;

class AdmobTools {
  
  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices: <String>['B2AA47A5B61A62208DFAF5C4CD83EB0A'],
    keywords: <String>['productivity', 'lifestyle', 'tasks', 'todo-lists', 'self improvement', 'goals', 'exercise', 'fitness', 'health', 'discipline', 'organisation'],
  );

  static final String testAppId = FirebaseAdMob.testAppId;

  static final String appId = Platform.isAndroid
      ? 'ca-app-pub-3787115292798141~9637684042'
      : 'ca-app-pub-3787115292798141~4567414097';

  static final String testAdUnitId = BannerAd.testAdUnitId;

  static final String homePageAdUnitId =
   Platform.isAndroid
      ? 'ca-app-pub-3787115292798141/5912285356'
      : 'ca-app-pub-3787115292798141/6618862362';

  static final String historyPageAdUnitId =
   Platform.isAndroid
      ? 'ca-app-pub-3787115292798141/6804085224'
      : 'ca-app-pub-3787115292798141/6066127749';
      
  static final String analyticsPageAdUnitId =
   Platform.isAndroid
      ? 'ca-app-pub-3787115292798141/7925595207'
      : 'ca-app-pub-3787115292798141/1580087822';

  static final String settingsPageAdUnitId =
   Platform.isAndroid
      ? 'ca-app-pub-3787115292798141/1691768461'
      : 'ca-app-pub-3787115292798141/8660092373';

}