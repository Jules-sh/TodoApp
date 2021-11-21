import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo/CustomDateTimePicker.dart';
import 'package:todo/Settings.dart';
import 'CustomDateTimePicker.dart';
import 'NewScreen.dart';
import 'main.dart';
import 'Search.dart';
import 'Translations.i18n.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'Todo.dart';
import 'package:local_auth/local_auth.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class TodoListState extends State<TodoList> {
  bool canCheckBiometrics;
  bool didAuthentificate;

  void localAuthInit() async {
    canCheckBiometrics = await LocalAuthentication().canCheckBiometrics;

    List<BiometricType> availableBiometrics =
        await LocalAuthentication().getAvailableBiometrics();
    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {}
    }
  }

  void authentificate() async {
    didAuthentificate = await LocalAuthentication()
        .authenticate(localizedReason: 'Authentificate to continue');
  }

  bool _darkModeOn = false;
  bool _getDarkModeOn() {
    var brightness = MediaQuery.of(context).platformBrightness;
    _darkModeOn = brightness == Brightness.dark;
    return _darkModeOn;
  }

  bool _dark;
  bool _boolDark() {
    if (TodoApp.getThemeMode() == ThemeMode.dark) {
      _dark = true;
    } else if (TodoApp.getThemeMode() == ThemeMode.light) {
      _dark = false;
    } else {
      if (_darkModeOn == true) {
        _dark = true;
      } else {
        _dark = false;
      }
    }
    return _dark;
  }

  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  AppBar getAppbar() {
    bool appbarSelect = false;
    for (int selectedindex = 0;
        selectedindex < TodoApp.todos.length;
        selectedindex++) {
      if (TodoApp.todos[selectedindex].selected) {
        appbarSelect = true;
        break;
      }
    }
    if (appbarSelect == false) {
      return AppBar(
        backgroundColor: TodoApp.getAppColor(),
        title: new Text('Todo List'.i18n),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () => _searchAction(),
                child: Icon(
                  Icons.search,
                  size: 26.0,
                ),
              )),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () => _settings(), child: Icon(Icons.settings)))
        ],
      );
    } else {
      return AppBar(
        title: new Text('Todo List'.i18n),
        backgroundColor: TodoApp.getAppColor(),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  child: Icon(Icons.delete),
                  onTap: () {
                    for (int selectedindex = 0;
                        selectedindex < TodoApp.todos.length;
                        selectedindex++) {
                      if (TodoApp.todos[selectedindex].selected) {
                        _removeTodoItem(selectedindex);
                      } else {}
                    }
                  })),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  child: Icon(Icons.done),
                  onTap: () {
                    for (int selectedindex = 0;
                        selectedindex < TodoApp.todos.length;
                        selectedindex++) {
                      if (TodoApp.todos[selectedindex].selected) {
                        if (TodoApp.todos[selectedindex].finished) {
                          _setMarkAsUndone(selectedindex);
                        } else {
                          _setMarkAsDone(selectedindex);
                        }
                      }
                    }
                  })),
        ],
      );
    }
  }

  Center _getEmptyTodoList() {
    if (_dark == true) {
      return Center(
        child: Container(
            child: RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: 17,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w200),
            children: <TextSpan>[
              TextSpan(
                  text: 'You don\'t have Todo\s yet'.i18n + '\n',
                  style: TextStyle(color: Colors.white)),
              TextSpan(
                  text: 'Click '.i18n, style: TextStyle(color: Colors.white)),
              TextSpan(
                  text: 'here'.i18n,
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _pushAddTodoScreen()),
              TextSpan(
                  text: ' to add a Todo'.i18n,
                  style: TextStyle(color: Colors.white))
            ],
          ),
        )),
      );
    } else {
      return Center(
        child: Container(
            child: RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: 17,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w200),
            children: <TextSpan>[
              TextSpan(
                  text: 'You don\'t have Todo\s yet'.i18n + '\n',
                  style: TextStyle(color: Colors.black)),
              TextSpan(
                  text: 'Click '.i18n, style: TextStyle(color: Colors.black)),
              TextSpan(
                  text: 'here'.i18n,
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _pushAddTodoScreen()),
              TextSpan(
                  text: ' to add a Todo'.i18n,
                  style: TextStyle(color: Colors.black))
            ],
          ),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    localAuthInit();
    authentificate();
    _getDarkModeOn();
    _boolDark();
    _sortTodoItems();
    return new MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: TodoApp.getThemeMode(),
        home: new Scaffold(
          appBar: getAppbar(),
          body: _buildTodoList(),
          floatingActionButton: new FloatingActionButton(
              backgroundColor: TodoApp.getAppColor(),
              onPressed: _pushAddTodoScreen,
              tooltip: 'Add task'.i18n,
              child: new Icon(Icons.add)),
        ));
  }

  Widget _buildTodoList() {
    if (TodoApp.todos.isEmpty) {
      return _getEmptyTodoList();
    } else {
      return new Container(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: new DataTable(
                  columnSpacing: MediaQuery.of(context).size.width / 3,
                  columns: <DataColumn>[
                    DataColumn(
                        label: Text.rich(TextSpan(text: 'Select All'.i18n),
                            style: TextStyle(
                                fontSize: 21, fontStyle: FontStyle.normal))),
                    DataColumn(label: Icon(Icons.star_outline)),
                  ],
                  rows: List<DataRow>.generate(
                      TodoApp.todos.length, (int index) => _getRow(index)))));
    }
  }

  DataRow _getRow(int index) {
    Todo todo = TodoApp.todos[index];
    if (!todo.finished) {
      if (new DateTime.now().isAfter(todo.dateTime)) {
        return new DataRow(
            color: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected))
                return Theme.of(context).colorScheme.primary.withOpacity(0.2);
              if (index.isEven) {
                return Theme.of(context).colorScheme.primary.withOpacity(0.1);
              }
              return null;
            }),
            cells: <DataCell>[
              DataCell(
                Text.rich(TextSpan(
                    text: TodoApp.todos[index].todo + '\n',
                    style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.normal,
                        color: Colors.red),
                    children: <TextSpan>[
                      TextSpan(
                          text: TodoApp.dateFormat.format(todo.dateTime),
                          style: TextStyle(
                              fontSize: 13, fontStyle: FontStyle.normal))
                    ])),
              ),
              DataCell(
                TodoApp.todos[index].priority == true
                    ? Icon(Icons.star)
                    : Icon(Icons.star_border),
                onTap: () => _togglePriority(index),
              )
            ],
            selected: TodoApp.todos[index].selected,
            onSelectChanged: (bool value) {
              setState(() {
                TodoApp.todos[index].selected = value;
              });
            });
      }
      return new DataRow(
          color: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected))
              return Theme.of(context).colorScheme.primary.withOpacity(0.2);
            if (index.isEven) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.1);
            }
            return null;
          }),
          cells: <DataCell>[
            DataCell(Text.rich(TextSpan(
                text: TodoApp.todos[index].todo + '\n',
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.normal),
                children: <TextSpan>[
                  TextSpan(
                      text: TodoApp.dateFormat.format(todo.dateTime),
                      style:
                          TextStyle(fontSize: 13, fontStyle: FontStyle.normal))
                ]))),
            DataCell(
              TodoApp.todos[index].priority == true
                  ? Icon(Icons.star)
                  : Icon(Icons.star_border),
              onTap: () => _togglePriority(index),
            ),
          ],
          selected: TodoApp.todos[index].selected,
          onSelectChanged: (bool value) {
            setState(() {
              TodoApp.todos[index].selected = value;
            });
          });
    } else {
      return new DataRow(
          color: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected))
              return Theme.of(context).colorScheme.primary.withOpacity(0.2);
            if (index.isEven) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.1);
            }
            return null;
          }),
          cells: <DataCell>[
            DataCell(Text.rich(TextSpan(
                text: TodoApp.todos[index].todo + '\n',
                style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough),
                children: <TextSpan>[
                  TextSpan(
                      text: TodoApp.dateFormat.format(todo.dateTime),
                      style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey)),
                ]))),
            DataCell(
              TodoApp.todos[index].priority == true
                  ? Icon(Icons.star)
                  : Icon(Icons.star_border),
              onTap: () => _togglePriority(index),
            ),
          ],
          selected: TodoApp.todos[index].selected,
          onSelectChanged: (bool value) {
            setState(() {
              TodoApp.todos[index].selected = value;
            });
          });
    }
  }

  void _togglePriority(index) {
    setState(() {
      if (TodoApp.todos[index].priority) {
        TodoApp.setPriority(index, false);
      } else {
        TodoApp.setPriority(index, true);
      }
    });
  }

  void _sortTodoItems() {
    TodoApp.todos.sort((a, b) {
      if (a.priority != b.priority) {
        if (a.priority) {
          return -1;
        } else {
          return 1;
        }
      }
      return a.dateTime.compareTo(b.dateTime);
    });
    TodoApp.saveData();
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
          ),
          themeMode: TodoApp.getThemeMode(),
          home: new Scaffold(
              appBar: AppBar(
                backgroundColor: TodoApp.getAppColor(),
                leading: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.arrow_back,
                          size: 23.0,
                        ))),
                title: new Text('Add a new task'.i18n),
              ),
              body: new TextField(
                autofocus: true,
                onSubmitted: (val) async {
                  TodoApp.dateTime = (await DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(2020, 1, 1),
                      maxTime: DateTime(3000, 1, 1)));
                  TodoApp.time = (await DatePicker.showPicker(context,
                      pickerModel: CustomDateTimePicker()));
                  if (TodoApp.dateTime != null && TodoApp.time != null) {
                    TodoApp.dateTime = new DateTime(
                        TodoApp.dateTime.year,
                        TodoApp.dateTime.month,
                        TodoApp.dateTime.day,
                        TodoApp.time.hour,
                        TodoApp.time.minute);
                    _addTodoItem(val, TodoApp.dateTime);
                  }
                  Navigator.of(context).pop();
                },
                decoration: new InputDecoration(
                    hintText: 'Enter something to do...'.i18n,
                    contentPadding: const EdgeInsets.all(16.0)),
              )));
    }));
  }

  void _removeTodoItem(int index) {
    setState(() {
      TodoApp.todos.removeAt(index);
      TodoApp.saveData();
    });
  }

  void _addTodoItem(String task, DateTime dateTime) {
    if (task.length > 0) {
      setState(() {
        TodoApp.todos.add(Todo(
          todo: task,
          dateTime: dateTime,
          finished: false,
          selected: false,
          priority: false,
        ));
        TodoApp.saveData();
        scheduleNotification(dateTime);
      });
    }
  }

  void _setMarkAsDone(int index) {
    setState(() {
      TodoApp.todos[index].finished = true;
      TodoApp.saveData();
    });
  }

  void _setMarkAsUndone(int index) {
    setState(() {
      TodoApp.todos[index].finished = false;
      TodoApp.saveData();
    });
  }

  Future onSelectNotification(String payload) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NewScreen(
        payload: payload,
      );
    }));
  }

  showNotification() async {
    var android = AndroidNotificationDetails(
        '1', 'TodoApp ', 'Todo App Notification Channel',
        priority: Priority.defaultPriority,
        importance: Importance.defaultImportance);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, '@mipmap/ic_launcher', 'Flutter Local Notification Demo', platform,
        payload: 'Welcome to the Local Notification demo');
  }

  Future<void> scheduleNotification(DateTime dateTime) async {
    String element = 'test';
    element.hashCode;
    var encode =
        utf8.encode(TodoApp.todos[0].todo + dateTime.toIso8601String());
    var convert = sha256.convert(encode);
    var bytes = convert.bytes;
    var int8List = Int8List(4);
    int8List[0] = bytes[0];
    int8List[1] = bytes[1];
    int8List[2] = bytes[2];
    int8List[3] = bytes[3];
    var hashedInt = int8List.buffer.asInt32List()[0];
    var scheduledNotificationDateTime = dateTime;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '1', //channel ID
      'TodoApp', //channel name
      'Todo App Notification Channel', //channel description
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        hashedInt,
        'Due Todo'.i18n,
        TodoApp.todos[0].todo + ' is due'.i18n,
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  Future<void> _searchAction() async {
    SearchState.searchItems.clear();
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return SearchWidget();
    }));
    setState(() {
      SearchState.searchController.clear();
    });
  }

  Future<void> _settings() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return SettingsWidget();
    }));
    setState(() {});
  }
}
