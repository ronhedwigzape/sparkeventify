import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {

  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  final bool enabled;

  const TextFieldInput({
    super.key, 
    required this.textEditingController, 
    this.isPass = false, 
    required this.hintText, 
    required this.textInputType,
    this.enabled = true,
  });

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context)
    );

    return TextField(
      controller: widget.textEditingController,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
        suffixIcon: widget.isPass ? IconButton(
          icon: Icon(
            // Change the icon based on the password visibility
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            // Toggle the password visibility when the icon is clicked
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ) : null,
      ),
      keyboardType: widget.textInputType,
      obscureText: widget.isPass && !_isPasswordVisible,
      enabled: widget.enabled,
    );
  }
}
