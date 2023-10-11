import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tutorial/main.data.dart';
import 'package:tutorial/models/task.dart';
import 'package:tutorial/models/user.dart';

void main() {
  runApp(
    ProviderScope(
      child: TasksApp(),
      overrides: [
        configureRepositoryLocalStorage(clear: LocalStorageClearStrategy.never)
      ],
    ),
  );
}

class TasksApp extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ref.watch(repositoryInitializerProvider).when(
              error: (error, _) => Text(error.toString()),
              loading: () => const CircularProgressIndicator(),
              data: (_) {
                // enable verbose
                ref.tasks.logLevel = 2;
                ref.users.logLevel = 2;
                return TasksScreen();
              }),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TasksScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _newTaskController = useTextEditingController();
    final state = ref.users.watchOne(
      1, // user ID, an integer
      params: {'_embed': 'tasks'}, // HTTP param
      alsoWatch: (user) => [user.tasks], // watcher
    );

    if (state.isLoading) {
      return CircularProgressIndicator();
    }

    final user = state.model!;
    final tasks = user.tasks.toList()..sort();

    return RefreshIndicator(
      onRefresh: () => ref.tasks.findOne(1, params: {'_embed': 'tasks'}),
      child: ListView(
        children: [
          TextField(
            controller: _newTaskController,
            onSubmitted: (value) async {
              if (value.isNotEmpty) {
                final task = Task(title: value, user: BelongsTo(user));
                await task.save();
                _newTaskController.clear();
              }
            },
          ),
          for (final task in tasks)
            Dismissible(
              key: ValueKey(task),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => task.delete(),
              child: ListTile(
                leading: Checkbox(
                  value: task.completed,
                  onChanged: (value) async {
                    await task.toggleCompleted().save();
                  },
                ),
                title: Text(
                    '${task.title} [id: ${task.id} ${DataModel.keyFor(task).detypify()}]'),
              ),
            ),
        ],
      ),
    );
  }
}
