import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo/main.dart';
import 'Translations.i18n.dart';

class NewScreen extends StatefulWidget {
  final String payload;
  NewScreen({
    @required this.payload,
  });

  @override
  createState() => NotificationState();
}

class NotificationState extends State<NewScreen> {
  String payload = TodoApp.todos[0].todo;
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: ThemeData(brightness: Brightness.light),
        darkTheme: ThemeData(brightness: Brightness.dark),
        themeMode: TodoApp.getThemeMode(),
        home: new Scaffold(
            appBar: AppBar(
                backgroundColor: TodoApp.getAppColor(),
                title: new Text.rich(TextSpan(
                    text: 'Your Todo is due'.i18n,
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontSize: 19,
                        fontWeight: FontWeight.w500)))),
            body: Center(
                child: Container(
                    height: MediaQuery.of(context).size.height / 9,
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Center(
                        child: new Text.rich(TextSpan(
                            text: 'Your Todo '.i18n +
                                '\"' +
                                payload +
                                '\"' +
                                ' is due'.i18n,
                            style: new TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w300)))))),
            floatingActionButton: new FloatingActionButton(
                tooltip: 'Mark this Todo as Done'.i18n,
                backgroundColor: TodoApp.getAppColor(),
                child: Icon(Icons.done),
                onPressed: () => _notificationDone())));
  }

  void _notificationDone() {
    setState(() {
      for (int todoIndex = 0; todoIndex < TodoApp.todos.length; todoIndex++) {
        if (TodoApp.todos[todoIndex].todo == payload) {
          TodoApp.todos[todoIndex].finished = true;
          Navigator.of(context).pop();
        }
      }
    });
  }
}
