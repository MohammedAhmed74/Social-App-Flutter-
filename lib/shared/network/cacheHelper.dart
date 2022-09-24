import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPre;
  static init() async{
    sharedPre = await SharedPreferences.getInstance();
  }

  static setValue({required String key, required dynamic value}){
    if (value is bool) {
      sharedPre.setBool(key, value).then((value) {
        print('$key = $value');
      }).catchError((error) {
        print('error ::');
        print(error);
      });
    } else if (value is String) {
      sharedPre.setString(key, value).then((value) {
        print('$key = $value');
      }).catchError((error) {
        print('error ::');
        print(error);
      });
    } else if (value is double) {
      sharedPre.setDouble(key, value).then((value) {
        print('$key = $value');
      }).catchError((error) {
        print('error ::');
        print(error);
      });
    } else {
      sharedPre.setInt(key, value).then((value) {
        print('$key = $value');
      }).catchError((error) {
        print('error ::');
        print(error);
      });
    }
  }

  static getValue({required String key}) {
    return sharedPre.get(key);
  }

  static Future<bool> removeValue({required String key}) {
    return sharedPre.remove(key);
  }
}
