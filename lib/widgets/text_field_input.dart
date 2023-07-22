import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Define a StatefulWidget as it has mutable state
class TextFieldInput extends StatefulWidget {
  // Define the properties of the widget
  final TextEditingController textEditingController; // Controller for the TextField
  final bool isPass; // Determines if the TextField is a password field
  final String labelText; // Hint text for the TextField
  final TextInputType textInputType; // Input type for the TextField
  final bool enabled; // Determines if the TextField is enabled
  final bool isDate; // Determines if the TextField is a date picker
  final bool isTime; // Determines if the TextField is a time picker
  final double height; // The height of the TextField
  final double width;
  final FormFieldValidator<String>? validator;

  // Constructor for the widget
  const TextFieldInput({
    Key? key,
    this.height = 50.0, 
    this.width = double.infinity,
    required this.textEditingController,
    this.isPass = false,
    required this.labelText,
    required this.textInputType,
    this.enabled = true,
    this.isDate = false,
    this.isTime = false,
    this.validator,
  }) : super(key: key);

  // Create the state for the widget
  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

// Define the state for the widget
class _TextFieldInputState extends State<TextFieldInput> {
  bool _isPasswordVisible = false; // Determines if the password is visible

  @override
  Widget build(BuildContext context) {
    // Define the border for the TextField
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    // Return a TextField widget
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: TextFormField(
        controller: widget.textEditingController, // Set the controller
        decoration: InputDecoration( // Set the decoration for the TextField
          labelText: widget.labelText, // Set the hint text
          border: inputBorder, // Set the border
          focusedBorder: inputBorder, // Set the border when the TextField is focused
          enabledBorder: inputBorder, // Set the border when the TextField is enabled
          contentPadding: const EdgeInsets.all(8), // Set the padding
          suffixIcon: widget.isPass // Set the suffix icon
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    // Toggle the password visibility when the icon is clicked
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
        validator: widget.validator,
        keyboardType: widget.textInputType, // Set the input type
        obscureText: widget.isPass && !_isPasswordVisible, // Set the obscure text
        enabled: widget.enabled, // Set if the TextField is enabled
        readOnly: widget.isDate || widget.isTime, // Set if the TextField is read only
        onTap: widget.isDate || widget.isTime // Set the onTap function
            ? () async {
                if (widget.isDate) {
                  // Show a date picker when the TextField is tapped
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    // Format the selected date and set it to the TextField
                    widget.textEditingController.text =
                        DateFormat('yyyy-MM-dd').format(date);
                  }
                } else if (widget.isTime) {
                  // Show a time picker when the TextField is tapped
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    // Format the selected time and set it to the TextField
                    if (mounted){
                      widget.textEditingController.text = time.format(context);
                    }
                  }
                }
              }
            : null,
      ),
    );
  }
}
