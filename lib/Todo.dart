class Todo {
  String todo;
  DateTime dateTime;
  bool finished;
  bool selected;
  bool priority;

  Todo({this.todo, this.dateTime, this.finished, this.selected, this.priority});

  Todo.fromJson(Map<String, dynamic> json)
      : todo = json['todo'],
        dateTime = DateTime.parse(json['dateTime']),
        finished = json['finished'],
        selected = json['selected'],
        priority = json['priority'];

  Map<String, dynamic> toJson() => {
        'todo': todo,
        'dateTime': dateTime.toIso8601String(),
        'finished': finished,
        'selected': selected,
        'priority': priority,
      };
}
