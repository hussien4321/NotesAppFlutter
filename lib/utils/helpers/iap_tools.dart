import 'dart:io' show Platform;

class IAPTOOLS {
  
  static final List<String> productLists = Platform.isAndroid
      ? [
    // 'todo_today_no_more_ads',
    'android.test.purchased',
    // 'android.test.canceled',
  ] : ['todo.today.remove.ads'];

}