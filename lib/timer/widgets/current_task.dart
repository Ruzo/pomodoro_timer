import 'package:flutter/material.dart';

class CurrentTask extends StatelessWidget {
  final String title;

  const CurrentTask({Key? key, required this.title}) : super(key: key);

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
            Flexible(
              child: Text(
                'Task: $title',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(.85),
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
            Icon(Icons.edit_outlined),
          ],
        ),
      ),
    );
  }
}
