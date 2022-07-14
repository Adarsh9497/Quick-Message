import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class MySharedPref {
  static late SharedPreferences _preferences;
  static const _keyMode = "lightmodedarkmode";

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future deleteAll() async {
    await _preferences.clear();
  }

  //0 means light mode and 1 means dark mode
  static Future setMode(int mode) async =>
      await _preferences.setInt(_keyMode, mode);

  static bool isModeNull() {
    int? val = _preferences.getInt(_keyMode);
    if (val == null)
      return true;
    else
      return false;
  }

  static Mode getMode() {
    int val = _preferences.getInt(_keyMode) ?? 0;
    if (val == 0) {
      return Mode.light_mode;
    } else {
      return Mode.dark_mode;
    }
  }
}
