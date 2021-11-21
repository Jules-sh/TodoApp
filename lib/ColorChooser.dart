import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'Translations.i18n.dart';
import 'main.dart';

class ColorChooser extends StatefulWidget {
  createState() => new ColorChooserState();
}

class ColorChooserState extends State<ColorChooser> {
  static List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.yellow,
    Colors.cyan,
    Colors.purple,
  ];
  static List<String> namesOfColors = [
    'Red'.i18n,
    'Green'.i18n,
    'Blue'.i18n,
    'Orange'.i18n,
    'Teal'.i18n,
    'Indigo'.i18n,
    'Yellow'.i18n,
    'Cyan'.i18n,
    'Purple'.i18n,
  ];

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: ThemeData(brightness: Brightness.light),
        darkTheme: ThemeData(brightness: Brightness.dark),
        themeMode: TodoApp.getThemeMode(),
        home: new Scaffold(
            appBar: new AppBar(
              backgroundColor: TodoApp.getAppColor(),
              leading: Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back,
                        size: 23.0,
                      ))),
              title: new Text('Select your App-Color'.i18n),
            ),
            body: new Column(children: getColorChildren())));
  }

  List<Widget> getColorChildren() {
    List<Widget> result = List.empty(growable: true);
    // This will get us 0 in first iteration and 3 in second
    // Which would be red and orange ...
    for (var row = 0; row * 3 < colors.length; row++) {
      List<Widget> columnsOfRow = List.empty(growable: true);
      // this will get us
      for (var column = 0;
          ((row * 3) + column < colors.length) && column < 3;
          column++) {
        columnsOfRow.add(InkWell(
          child: Container(
              height: MediaQuery.of(context).size.width / 3,
              width: MediaQuery.of(context).size.width / 3,
              color: colors[row * 3 + column]),
          onTap: () {
            TodoApp.setAppColor(colors[row * 3 + column]);
            Navigator.of(context).pop();
          },
        ));
      }
      result.add(Row(
        children: columnsOfRow,
      ));
    }
    result.add(Container(
      height: MediaQuery.of(context).size.height / 3,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(primary: TodoApp.getAppColor()),
          onPressed: () {
            TodoApp.setAppColor(null);
            Navigator.of(context).pop();
          },
          child: Text('Reset'.i18n)),
      alignment: Alignment.bottomCenter,
    ));
    return result;
  }
}
