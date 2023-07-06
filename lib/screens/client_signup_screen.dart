import 'package:flutter/material.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/screens/client_login_screen.dart';
import 'package:student_event_calendar/screens/officer_screen.dart';
import 'package:student_event_calendar/screens/staff_screen.dart';
import 'package:student_event_calendar/screens/student_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

class ClientSignupScreen extends StatefulWidget {
  const ClientSignupScreen({super.key});

  @override
  State<ClientSignupScreen> createState() => _ClientSignupScreenState();
}

class _ClientSignupScreenState extends State<ClientSignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _userTypeController.dispose();
  }

  Future<void> signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
      userType: _userTypeController.text.trim(),
    );

    if (res == 'Success') {
      onSignupSuccess();
    } else {
      onSignupFailure(res);
    }
  }

  void onSignupSuccess() {
    setState(() {
      _isLoading = false;
    });
    switch (_userTypeController.text) {
      case 'Student':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const StudentScreen()));
        break;
      case 'Officer':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const OfficerScreen()));
        break;
      case 'Staff':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const StaffScreen()));
        break;
      default:
        break;
    }
  }

  void onSignupFailure(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  void navigateToLogin() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ClientLoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          body: SafeArea(
              child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
                // svg image
                const Image(
                    image: AssetImage('assets/cspc_logo.png'), height: 100.0),
                const SizedBox(height: 25.0),
                // circular widget to accept and show our selected file
                const SizedBox(height: 12.0),
                // text field input for username
                TextFieldInput(
                  textEditingController: _usernameController,
                  hintText: 'Enter your username',
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 12.0),
                // text field input for email
                TextFieldInput(
                  textEditingController: _emailController,
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12.0),
                // text field input for password
                TextFieldInput(
                  textEditingController: _passwordController,
                  hintText: 'Enter you password',
                  textInputType: TextInputType.visiblePassword,
                  isPass: true,
                ),
                const SizedBox(height: 12.0),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _userTypeController.text.isEmpty
                      ? null
                      : _userTypeController.text,
                  items: <String>['Student', 'Officer', 'Staff']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _userTypeController.text = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 12.0),
                // button login
                InkWell(
                    onTap: signUpUser,
                    child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                          color: blueColor,
                        ),
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(primaryColor),
                              ))
                            : const Text('Sign up'))),
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
                      child: const Text('Already have an account?'),
                    ),
                    GestureDetector(
                      onTap: navigateToLogin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: const Text(
                          ' Login here',
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
        ));
  }
}
