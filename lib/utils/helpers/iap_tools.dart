import 'dart:io' show Platform;

class IAPTOOLS {
  
  static final List<String> productLists = Platform.isAndroid ? ['todo_today_no_more_ads'] 
  : ['todo.today.remove.ads' ];
  // : ['com.cooni.point1000','com.cooni.point5000'];

}