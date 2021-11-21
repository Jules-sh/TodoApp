import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'Translations.i18n.dart';
import 'main.dart';
import 'Todo.dart';

class SearchWidget extends StatefulWidget {
  @override
  createState() => new SearchState();
}

class SearchState extends State<SearchWidget> {
  static var searchController = TextEditingController();
  static List<Todo> searchItems = [];
  DateFormat dateFormat = new DateFormat('dd-MM-yyyy HH:mm');

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
              title: new TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                    hintText: 'Search something...'.i18n,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                          searchItems.clear();
                        });
                      },
                      icon: Icon(Icons.clear),
                    ),
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70)),
                onSubmitted: (val) {
                  _showResults(val);
                },
              )),
          body: _buildTodoList(),
        ));
  }

  void _showResults(String result) {
    setState(() {
      for (int i = 0; i < TodoApp.todos.length; i++) {
        Todo itemI = TodoApp.todos[i];
        if (itemI.todo.contains(result)) {
          searchItems.insert(0, itemI);
        }
      }
      if (searchItems.isEmpty) {
        _showNoItemDialog();
      } else {}
    });
  }

  void _showNoItemDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text.rich(
                TextSpan(text: 'No Todo with that name'.i18n),
                style: TextStyle(),
              ),
              content: Text('There\s no Todo with that name'.i18n),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Ok'.i18n))
              ],
            ));
  }

  // ignore: missing_return
  Widget _buildTodoList() {
    if (searchItems.length > 0) {
      return new DataTable(
          columnSpacing: MediaQuery.of(context).size.width / 3,
          columns: <DataColumn>[
            DataColumn(
                label: Text.rich(TextSpan(text: 'Select All'.i18n),
                    style:
                        TextStyle(fontSize: 21, fontStyle: FontStyle.normal))),
            DataColumn(label: Icon(Icons.star_outline))
          ],
          rows: List<DataRow>.generate(searchItems.length,
              (int index) => _getRow(searchItems[index], index)));
    } else {}
  }

  DataRow _getRow(Todo todo, int index) {
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
                onTap: () => _togglePrioritySearch(index),
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
              onTap: () => _togglePrioritySearch(index),
            ),
          ],
          selected: TodoApp.todos[index].selected,
          onSelectChanged: (bool value) {
            setState(() {
              TodoApp.todos[index].selected = value;
              new AppBar(backgroundColor: TodoApp.getAppColor(), actions: [
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                        child: Icon(Icons.delete),
                        onTap: () => _deleteTodoItem(index))),
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      child: Icon(Icons.done),
                      onTap: () => _setMarkAsDoneSearch(index),
                    ))
              ]);
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
              onTap: () => _togglePrioritySearch(index),
            ),
          ],
          selected: TodoApp.todos[index].selected,
          onSelectChanged: (bool value) {
            setState(() {
              TodoApp.todos[index].selected = value;
              new AppBar(backgroundColor: TodoApp.getAppColor(), actions: [
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                        child: Icon(Icons.delete),
                        onTap: () => _deleteTodoItem(index))),
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                        child: Icon(Icons.undo),
                        onTap: () => _setMarkAsUndoneSearch(index)))
              ]);
            });
          });
    }
  }

  _deleteTodoItem(index) {
    TodoApp.todos.removeAt(index);
    TodoApp.saveData();
  }

  void _togglePrioritySearch(index) {
    setState(() {
      if (TodoApp.todos[index].priority) {
        TodoApp.todos[index].priority = false;
      } else {
        TodoApp.todos[index].priority = true;
      }
      TodoApp.saveData();
    });
  }

  void _setMarkAsDoneSearch(index) {
    TodoApp.todos[index].finished = true;
    TodoApp.saveData();
  }

  void _setMarkAsUndoneSearch(index) {
    TodoApp.todos[index].finished = false;
  }
}
