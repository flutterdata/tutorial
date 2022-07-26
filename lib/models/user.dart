import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

import 'task.dart';

part 'user.g.dart';

@JsonSerializable()
@DataRepository([JsonServerAdapter])
class User extends DataModel<User> {
  @override
  final int? id;
  final String name;
  final HasMany<Task> tasks;

  User({this.id, required this.name, required this.tasks});
}
