import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'TodoListState.dart';
import 'Todo.dart';

void main() {
  tz.initializeTimeZones();
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  static TodoApp instance;
  @override
  createState() {
    instance = new TodoApp();
    return instance;
  }
}

class TodoApp extends State<MyApp> {
  static List<Todo> todos = [];
  static Locale _selectedLanguage;
  static Color _appColor;
  static ThemeMode _theme = ThemeMode.system;
  static DateTime dateTime;
  static DateTime time;
  // ignore: avoid_init_to_null
  static bool _darkmode = null;
  static DateFormat dateFormat = new DateFormat('dd-MM-yyyy HH:mm');

  static bool getPriority(int index) {
    return todos[index].priority;
  }

  static void setPriority(int index, bool setPriority) {
    todos[index].priority = setPriority;
    saveData();
  }

  static bool getFinishedBool(int index) {
    return todos[index].finished;
  }

  static void setFinishedBool(int index, bool finishedBool) {
    todos[index].finished = finishedBool;
    saveData();
  }

  static Locale getSelectedLanguage() {
    return _selectedLanguage;
  }

  static void setSelectedLanguage(Locale language) {
    _selectedLanguage = language;
    saveData();
  }

  static Color getAppColor() {
    return _appColor;
  }

  static void setAppColor(Color color) {
    _appColor = color;
    saveData();
  }

  static ThemeMode getThemeMode() {
    return _theme;
  }

  static void setThemeMode(thememode) {
    _theme = thememode;
    saveData();
  }

  static bool getDarkmode() {
    return _darkmode;
  }

  static void setDarkmode(mode) {
    _darkmode = mode;
    saveData();
  }

  @override
  void initState() {
    super.initState();
    loadData().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedLanguage == null) {
      String localeOfSystem = Platform.localeName;
      var split = localeOfSystem.split('_');
      if (split.length > 1) {
        _selectedLanguage = Locale(split[0], split[1]);
      } else {
        _selectedLanguage = Locale('en', 'US');
      }
    }
    return new I18n(
        initialLocale: _selectedLanguage,
        child: new MaterialApp(localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ], supportedLocales: [
          const Locale('en', 'US'),
          const Locale('de', 'DE'),
        ], locale: _selectedLanguage, home: new TodoList()));
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    var stuff = jsonEncode(todos);
    prefs.setString('Object Todo', stuff);
    if (_appColor == null) {
      prefs.remove('color');
    } else {
      prefs.setInt('color', _appColor == null ? null : _appColor.value);
    }
    if (_darkmode == null) {
      prefs.remove('darkmode');
    } else {
      prefs.setBool('darkmode', _darkmode);
    }
  }

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    var storedTodosAsString = prefs.getString('Object Todo');
    if (storedTodosAsString != null) {
      List stuff = jsonDecode(storedTodosAsString);
      todos = [];
      for (int listIndex = 0; listIndex < stuff.length; listIndex++) {
        Map listItem = stuff[listIndex];
        Todo todo = Todo.fromJson(listItem);
        todos.add(todo);
      }
    }
    int color = prefs.getInt('color') ?? null;
    if (color == null) {
      _appColor = null;
    } else {
      _appColor = Color(color);
    }
    _darkmode = prefs.getBool('darkmode');
    if (_darkmode == true) {
      _theme = ThemeMode.dark;
    } else if (_darkmode == false) {
      _theme = ThemeMode.light;
    } else {
      _theme = ThemeMode.system;
    }
  }
}

class TodoList extends StatefulWidget {
  static TodoListState instance;
  @override
  // ignore: missing_return
  State<StatefulWidget> createState() {
    instance = new TodoListState();
    return instance;
  }
}
