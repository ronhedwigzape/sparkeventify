import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
 PasswordRecoveryScreenState createState() => PasswordRecoveryScreenState();
}

class PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _authMethods = AuthMethods();

  Future<void> sendPasswordResetEmail() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (_emailController.text.isNotEmpty) {
      await _authMethods.sendPasswordResetEmail(_emailController.text.trim());
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Password reset email sent'),
        duration: Duration(seconds: 2),
      ));
      _emailController.clear();
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Please enter your email'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Recovery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Forgot your password? No problem. Just let us know your email address and we will email you a password reset link that will allow you to choose a new one.'),
            const SizedBox(height: 10,),
            TextFieldInput(
              prefixIcon: const Icon(Icons.email_outlined),
              textEditingController: _emailController,
              labelText: 'Email',
              textInputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
              onPressed: sendPasswordResetEmail,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
              ),
              child: const Text(
                'Send Password Reset Email',
                style: TextStyle(color: white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
