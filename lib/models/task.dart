import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
@CopyWith()
@DataRepository([JSONServerAdapter])
class Task extends DataModel<Task> {
  @override
  final int? id;
  final String title;
  final bool completed;

  Task({this.id, required this.title, this.completed = false});
}

mixin JSONServerAdapter on RemoteAdapter<Task> {
  @override
  String get baseUrl => 'https://my-json-server.typicode.com/flutterdata/demo';
}
