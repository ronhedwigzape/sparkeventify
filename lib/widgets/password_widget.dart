import 'package:flutter/material.dart';

class PasswordWidget extends StatefulWidget {
  const PasswordWidget({super.key, required this.password});

  final String password;

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}

class _PasswordWidgetState extends State<PasswordWidget> {
  bool _isHidden = true;

  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock),
          const SizedBox(width: 10),
          Text(
            _isHidden ? '********' : widget.password,
            style: TextStyle(
              letterSpacing: _isHidden ? 2 : 0,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(
              _isHidden ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: _toggleVisibility,
          ),
        ],
      ),
    );
  }
}


