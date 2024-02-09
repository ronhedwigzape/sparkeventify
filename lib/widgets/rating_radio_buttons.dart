import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';

class RatingRadioButtons extends StatefulWidget {
  final String groupValue;
  final Function(String) onChanged;

  const RatingRadioButtons({super.key, required this.groupValue, required this.onChanged});

  @override
  State<RatingRadioButtons> createState() => _RatingRadioButtonsState();
}

class _RatingRadioButtonsState extends State<RatingRadioButtons> {
  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Column(
      children: <String>['Excellent', 'Good', 'Neutral', 'Poor', 'Worst']
          .map((String value) {
        return ListTile(
          title: Text(
            value,
            style: TextStyle(
              color: widget.groupValue == value 
                  ? (darkModeOn ? Colors.white : Theme.of(context).primaryColor)
                  : null,
            ),
          ),
          leading: Radio<String>(
            value: value,
            groupValue: widget.groupValue,
            onChanged: (String? newValue) {
              setState(() {
                widget.onChanged(newValue!);
              });
            },
            activeColor: darkModeOn ? Colors.white : Theme.of(context).primaryColor,
          ),
        );
      }).toList(),
    );
  }
}
