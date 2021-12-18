import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'main.data.dart';
import 'models/task.dart';

void main() {
  runApp(
    ProviderScope(
      child: TasksApp(),
      overrides: [configureRepositoryLocalStorage()],
    ),
  );
}

class TasksApp extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ref.watch(repositoryInitializerProvider()).when(
                error: (error, _) => Text(error.toString()),
                loading: () => const CircularProgressIndicator(),
                data: (_) {
                  final state = ref.tasks.watchAll();
                  if (state.isLoading) {
                    return CircularProgressIndicator();
                  }
                  return TasksScreen();
                },
              ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TasksScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.tasks.watchAll(params: {'_limit': 5}, syncLocal: true);
    final _newTaskController = useTextEditingController();

    if (state.isLoading) {
      return CircularProgressIndicator();
    }
    return RefreshIndicator(
      onRefresh: () =>
          ref.tasks.findAll(params: {'_limit': 5}, syncLocal: true),
      child: ListView(
        children: [
          TextField(
            controller: _newTaskController,
            onSubmitted: (value) async {
              Task(title: value).init(ref.read).save();
              _newTaskController.clear();
            },
          ),
          for (final task in state.model)
            Dismissible(
              key: ValueKey(task),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => task.delete(),
              child: ListTile(
                leading: Checkbox(
                  value: task.completed,
                  onChanged: (value) => task.toggleCompleted().save(),
                ),
                title: Text('${task.title} [id: ${task.id}]'),
              ),
            ),
        ],
      ),
    );
  }
}
