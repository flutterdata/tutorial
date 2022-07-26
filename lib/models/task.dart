import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tutorial/models/user.dart';

part 'task.g.dart';

@JsonSerializable()
@DataRepository([JsonServerAdapter])
class Task extends DataModel<Task> {
  @override
  final int? id;
  final String title;
  final bool completed;
  final BelongsTo<User> user;

  Task(
      {this.id,
      required this.title,
      this.completed = false,
      required this.user});

  Task toggleCompleted() {
    return Task(
            id: this.id,
            title: this.title,
            user: user,
            completed: !this.completed)
        .withKeyOf(this);
  }
}

mixin JsonServerAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
  @override
  String get baseUrl => 'https://my-json-server.typicode.com/flutterdata/demo/';
}
