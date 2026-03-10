import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:pomodoro_timer/tasks/_manager/tasks_manager.dart';

class CurrentTask extends StatelessWidget {
  const CurrentTask({super.key});

  @override
  Widget build(BuildContext context) {
    var currentTask = GetIt.I<TasksManager>().getCurrentTask.watch(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary, // Replaced kBackgroundColor with existing color scheme
        borderRadius: BorderRadius.circular(15),
      ),
      width: double.infinity, // Kept original width
      child: Padding( // Kept original padding
        padding: const EdgeInsets.all(18.0),
        child: Row( // Kept original Row structure
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column( // Changed to Column to display title and description
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentTask.title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white), 
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: Colors.white), // Added color for visibility
          ],
        ),
      ),
    );
  }
}
