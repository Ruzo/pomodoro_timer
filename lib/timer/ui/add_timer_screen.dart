import 'package:flutter/material.dart';
import 'package:pomodoro_timer/constants.dart';

class AddTimerScreen extends StatefulWidget {
  const AddTimerScreen({super.key});

  @override
  State<AddTimerScreen> createState() => _AddTimerScreenState();
}

class _AddTimerScreenState extends State<AddTimerScreen> {
  int focusTime = 20;
  int shortBreak = 5;
  int longBreak = 15;
  int sections = 4;

  bool isSectionsExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () {
            // TODO: implement navigation back
          },
        ),
        title: const Text(
          'Add new timer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: kBackgroundLiteColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildSettingRow(
                    title: 'Focuse time',
                    value: '$focusTime min',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    title: 'Short break',
                    value: '$shortBreak min',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingRow(
                    title: 'Long break',
                    value: '$longBreak min',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSectionsRow(),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({required String title, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsRow() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isSectionsExpanded = !isSectionsExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sections',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Row(
                  children: [
                    Text(
                      '$sections intervals',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSectionsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isSectionsExpanded)
          SizedBox(
            height: 150,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  sections = index + 2; // Assuming range starts from 2
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final intervalValue = index + 2;
                  final isSelected = intervalValue == sections;
                  return Container(
                    alignment: Alignment.center,
                    color: isSelected ? kPrimaryColor.withValues(alpha: 0.4) : Colors.transparent,
                    child: Text(
                      '$intervalValue',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontSize: isSelected ? 18 : 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                },
                childCount: 10, // Let's say max 11 intervals (2 to 11)
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.05),
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}
