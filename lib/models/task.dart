import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
@DataRepository([JSONServerAdapter])
class Task with DataModel<Task> {
  @override
  final int? id;
  final String title;
  final bool completed;

  Task({this.id, required this.title, this.completed = false});

  Task toggleCompleted() {
    return Task(id: this.id, title: this.title, completed: !this.completed)
        .was(this);
  }
}

mixin JSONServerAdapter on RemoteAdapter<Task> {
  @override
  String get baseUrl => 'https://my-json-server.typicode.com/flutterdata/demo';

  @override
  String get identifierSuffix => 'Id';
}
