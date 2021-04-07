import 'package:flutter/material.dart';

class CurrentTask extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Theme.of(context).accentColor,
      ),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Task: Work on Pomodoro timer',
              style: TextStyle(
                color: Colors.white.withOpacity(.85),
                fontSize: 18,
                fontWeight: FontWeight.w100,
              ),
            ),
            Icon(Icons.edit_outlined),
          ],
        ),
      ),
    );
  }
}
