import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/screens/admin_screen.dart';
import 'package:student_event_calendar/screens/admin_signup_screen.dart';
import 'package:student_event_calendar/screens/client_signup_screen.dart';
import 'package:student_event_calendar/screens/officer_screen.dart';
import 'package:student_event_calendar/screens/staff_screen.dart';
import 'package:student_event_calendar/screens/student_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_logo.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());

    if (res == 'Success') {
      onLoginSuccess(res);
    } else {
      onLoginFailure(res);
    }
  }

  void onLoginSuccess(String message) async {
    setState(() {
      _isLoading = false;
    });

    String userType = await AuthMethods().getUserType();
    if (userType == "Student") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const StudentScreen()));
    } else if (userType == "Officer") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const OfficerScreen()));
    } else if (userType == "Staff") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const StaffScreen()));
    } else if (userType == "Admin") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AdminScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid user type'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void onLoginFailure(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  void navigateToSignup() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
      !kIsWeb ? const ClientSignupScreen() : const AdminSignupScreen()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: MediaQuery.of(context).size.width > webScreenSize
            ?
            // Web screen
            EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 3)
            :
            // Mobile screen
            const EdgeInsets.symmetric(horizontal: 32.0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: Container(),
            ),
            // cspc logo
            const CspcLogo(
              height: 150.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: const Text(
                    'Camarines Sur Polytechnic Colleges',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: const Text('Nabua, Camarines Sur'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // text field input for email
            const Text('Log in',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 24.0),
            TextFieldInput(
              textEditingController: _emailController,
              hintText: 'Enter your email',
              textInputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24.0),
            // text field input for password
            TextFieldInput(
              textEditingController: _passwordController,
              hintText: 'Enter your password',
              textInputType: TextInputType.visiblePassword,
              isPass: true,
            ),
            const SizedBox(height: 24.0),
            // button login
            InkWell(
              onTap: loginUser,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    color: blueColor,
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ))
                      : const Text('Log in')),
            ),
            const SizedBox(height: 12.0),
            Flexible(
              flex: 2,
              child: Container(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  child: const Text('Don\'t have an account?'),
                ),
                GestureDetector(
                  onTap: navigateToSignup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    child: const Text(
                      ' Sign up.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            )
            // transitioning to signing up
          ],
        ),
      )),
    );
  }
}