import 'package:capo/utils/storage_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DarkMode { auto, dark, light }

class ThemeViewModel with ChangeNotifier {
  static const kThemeUserDarkMode = 'kThemeUserDarkMode';

  static MaterialColor _themeColor = const MaterialColor(
    0xFFFFFFFF,
    const <int, Color>{
      50: const Color(0xFF3376b8),
      100: const Color(0xFF3376b8),
      200: const Color(0xFF3376b8),
      300: const Color(0xFF3376b8),
      400: const Color(0xFF3376b8),
      500: const Color(0xFF3376b8),
      600: const Color(0xFF3376b8),
      700: const Color(0xFF3376b8),
      800: const Color(0xFF3376b8),
      900: const Color(0xFF3376b8),
    },
  );

  /// 用户选择的明暗模式
  DarkMode userDarkMode;

  ThemeViewModel() {
    /// 用户选择的明暗模式
    String darkmodeStr =
        StorageManager.sharedPreferences.getString(kThemeUserDarkMode);
    if (darkmodeStr == "auto" || darkmodeStr == null) {
      userDarkMode = DarkMode.auto;
    } else if (darkmodeStr == "dark") {
      userDarkMode = DarkMode.dark;
    } else if (darkmodeStr == "light") {
      userDarkMode = DarkMode.light;
    }
  }

  /// 切换指定色彩
  ///
  /// 没有传[brightness]就不改变brightness,color同理
  void switchTheme({DarkMode userChangeDarkMode}) {
    userDarkMode = userChangeDarkMode;
    notifyListeners();
    saveTheme2Storage(userDarkMode);
  }

  /// 根据主题 明暗 和 颜色 生成对应的主题
  /// [dark]系统的Dark Mode
  themeData({bool platformDarkMode: false}) {
    bool isDark;
    if (userDarkMode == DarkMode.light) {
      isDark = false;
    } else if (userDarkMode == DarkMode.dark) {
      isDark = true;
    } else {
      isDark = platformDarkMode;
    }

    Brightness brightness = isDark ? Brightness.dark : Brightness.light;

    var accentColor = isDark ? _themeColor : _themeColor;

    var themeData = ThemeData(
      brightness: brightness,
      primaryColorBrightness: brightness,
      accentColorBrightness: brightness,
      primarySwatch: _themeColor,
      accentColor: Colors.blueAccent,
    );

    themeData = themeData.copyWith(
      brightness: brightness,
      accentColor: accentColor,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: _themeColor,
        brightness: brightness,
      ),
      appBarTheme: themeData.appBarTheme.copyWith(elevation: 2),
      splashColor: Colors.transparent,
      hintColor: themeData.hintColor.withAlpha(90),
      cursorColor: accentColor,
      textTheme: themeData.textTheme.copyWith(
          button: themeData.textTheme.button.copyWith(color: Colors.white)),
    );

//    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
//        statusBarColor: Colors.red, statusBarIconBrightness: Brightness.dark);
//    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    return themeData;
  }

  /// 数据持久化到shared preferences
  saveTheme2Storage(DarkMode userDarkMode) async {
    await Future.wait([
      StorageManager.sharedPreferences.setString(
          kThemeUserDarkMode, userDarkMode.toString().split(".").last),
    ]);
  }
}
