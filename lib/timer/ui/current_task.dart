import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:pomodoro_timer/tasks/_manager/tasks_manager.dart';

class CurrentTask extends StatelessWidget with GetItMixin {
  CurrentTask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _currentTask = watchX((TasksManager tm) => tm.getCurrentTask);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Theme.of(context).colorScheme.secondary,
      ),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Task: ${_currentTask.title}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(.85),
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
            const Icon(Icons.edit_outlined),
          ],
        ),
      ),
    );
  }
}
