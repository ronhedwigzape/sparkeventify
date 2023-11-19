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
  final bool isRegistration;

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
    this.isRegistration = true,
  }) : super(key: key);

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  bool _isPasswordVisible = false;
  bool _showPhoneNumberWarning = false;
  bool _showPasswordWarning = false;

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
                onTap: () => _handleDateTimeInput(context, widget.startTextEditingController!, widget.isDateRange),
              ),
              const SizedBox(width: 10),
              _buildTextField(
                controller: widget.endTextEditingController!,
                labelText: 'End ${widget.isDateRange ? 'Date*' : 'Time*'}',
                onTap: () => _handleDateTimeInput(context, widget.endTextEditingController!, widget.isDateRange),
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
              onChanged: (value) {
                if (widget.labelText.contains('Phone')) {
                  bool isValidPhoneNumber = value.startsWith('639') && value.length == 10;
                  setState(() {
                    _showPhoneNumberWarning = !isValidPhoneNumber;
                  });
                } else {
                  setState(() {
                    _showPhoneNumberWarning = false;
                  });
                }
                if (widget.isPass && widget.isRegistration) {
                  setState(() {
                    _showPasswordWarning = !_isStrongPassword(value);
                  });
                }
              },
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
        if (_showPhoneNumberWarning && widget.labelText.contains('Phone'))
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Please enter a 10-digit phone number starting with 639.',
            style: TextStyle(color: Colors.red),
          ),
        ),
        if (_showPasswordWarning && widget.isRegistration && widget.isPass)
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'The password must be at least 6 characters long and include uppercase, lowercase letters, numbers, and symbols.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  bool _isStrongPassword(String password) {
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'\d'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[\W_]'));
    return password.length >= 6 && hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  Future<void> _handleDateTimeInput(BuildContext context, TextEditingController controller, bool isDate) async {
    if (isDate) {
      DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (date != null) {
        controller.text = DateFormat('yyyy-MM-dd').format(date);
      }
    } else {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        controller.text = time.format(context);
      }
    }
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
