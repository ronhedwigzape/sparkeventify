import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/utils/colors.dart';

import '../providers/darkmode_provider.dart';

class TextFieldInput extends StatefulWidget {
  final TextEditingController? textEditingController;
  final TextEditingController? startTextEditingController;
  final TextEditingController? endTextEditingController;
  final bool isDateRange;
  final bool isTimeRange;
  final bool isPass;
  final String labelText;
  final TextInputType textInputType;
  final bool enabled;
  final double height;
  final double width;
  final Widget? prefixIcon;
  final FormFieldValidator<String>? validator;

  const TextFieldInput({
    Key? key,
    this.height = 50.0,
    this.width = double.infinity,
    this.textEditingController,
    this.startTextEditingController,
    this.endTextEditingController,
    this.isDateRange = false,
    this.isTimeRange = false,
    this.isPass = false,
    required this.labelText,
    required this.textInputType,
    this.enabled = true,
    this.prefixIcon,
    this.validator,
  }) : super(key: key);

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;

    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(
        context,
        color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,
      ),
    );

    return Column(
      children: [
        if (widget.isDateRange || widget.isTimeRange)
          Row(
            children: [
              _buildTextField(
                controller: widget.startTextEditingController!,
                labelText: 'Start ${widget.isDateRange ? 'Date*' : 'Time*'}',
                onTap: () async {
                  if (widget.isDateRange) {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      widget.startTextEditingController!.text =
                          DateFormat('yyyy-MM-dd').format(date);
                    }
                  } else if (widget.isTimeRange) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      widget.startTextEditingController!.text =
                          time.format(context);
                    }
                  }
                },
              ),
              const SizedBox(
                width: 10,
              ),
              _buildTextField(
                controller: widget.endTextEditingController!,
                labelText: 'End ${widget.isDateRange ? 'Date*' : 'Time*'}',
                onTap: () async {
                  if (widget.isDateRange) {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      widget.endTextEditingController!.text =
                          DateFormat('yyyy-MM-dd').format(date);
                    }
                  } else if (widget.isTimeRange) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      widget.endTextEditingController!.text =
                          time.format(context);
                    }
                  }
                },
              ),
            ],
          ),
        if (!widget.isDateRange && !widget.isTimeRange)
          SizedBox(
            height: widget.height,
            width: widget.width,
            child: TextFormField(
              style: TextStyle(color: darkModeOn ? lightColor : darkColor),
              controller: widget.textEditingController,
              decoration: InputDecoration(
                labelText: widget.labelText,
                border: inputBorder,
                focusedBorder: inputBorder,
                enabledBorder: inputBorder,
                contentPadding: const EdgeInsets.all(8),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.isPass
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )
                    : null,
              ),
              validator: widget.validator,
              keyboardType: widget.textInputType,
              obscureText: widget.isPass && !_isPasswordVisible,
              enabled: widget.enabled,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required VoidCallback onTap,
  }) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;

    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(
        context,
        color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,
      ),
    );
    return Expanded(
      child: TextFormField(
        style: TextStyle(color: darkModeOn ? lightColor : darkColor),
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: inputBorder,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
          contentPadding: const EdgeInsets.all(8),
        ),
        onTap: onTap,
        readOnly: true,
      ),
    );
  }
}
