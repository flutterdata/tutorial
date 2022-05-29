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
          child: ref.watch(repositoryInitializerProvider).when(
                error: (error, _) => Text(error.toString()),
                loading: () => const CircularProgressIndicator(),
                data: (_) => TasksScreen(),
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
    // NOTE: here we could use `ref.tasks.watchAll()` but we
    // break it down in provider + watch in order to access the
    // notifier below (onRefresh)
    final provider =
        ref.tasks.watchAllProvider(params: {'_limit': 5}, syncLocal: true);
    final state = ref.watch(provider);

    if (state.isLoading) {
      return CircularProgressIndicator();
    }

    final _newTaskController = useTextEditingController();

    return RefreshIndicator(
      onRefresh: () => ref.read(provider.notifier).reload(),
      child: ListView(
        children: [
          TextField(
            controller: _newTaskController,
            onSubmitted: (value) async {
              Task(title: value).save();
              _newTaskController.clear();
            },
          ),
          for (final task in state.model!)
            Dismissible(
              key: ValueKey(task),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => task.delete(),
              child: ListTile(
                leading: Checkbox(
                  value: task.completed,
                  onChanged: (value) => task
                      .copyWith(completed: !task.completed)
                      .was(task)
                      .save(),
                ),
                title: Text('${task.title} [id: ${task.id}]'),
              ),
            ),
        ],
      ),
    );
  }
}
