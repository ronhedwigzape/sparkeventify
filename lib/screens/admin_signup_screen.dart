import 'package:flutter/material.dart';
import 'package:student_event_calendar/layouts/admin_screen_layout.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/screens/login_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_logo.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  State<AdminSignupScreen> createState() => AdminSignupScreenState();
}

class AdminSignupScreenState extends State<AdminSignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
  }

  Future<void> signUpAsAdmin() async {
    setState(() {
      _isLoading = true;
    });

    // Validate the phone number
    String phoneNumber = _phoneNumberController.text.trim();
    if (!RegExp(r'^9[0-9]{9}$').hasMatch(phoneNumber)) {
      onSignupFailure('Please enter a valid phone number.');
      return;
    }

    // Prepend '+63' to the phone number
    phoneNumber = '63$phoneNumber';

    model.Profile profile = model.Profile(
      fullName: _fullNameController.text.trim(),
      phoneNumber: phoneNumber,
    );

    String res = await AuthMethods().signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      userType: 'Admin',
      profile: profile,
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
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AdminScreenLayout()));
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
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
            const CSPCLogo(
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
                    schoolName,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: const Text(schoolAddress),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // text field input for email
            const Text('Sign up as Admin',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 20.0),
            // text field input for username
            TextFieldInput(
              textEditingController: _emailController,
              hintText: 'Enter your username',
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 20.0),
            // text field input for full name
            TextFieldInput(
              textEditingController: _fullNameController,
              hintText: 'Enter your full name',
              textInputType: TextInputType.text,
            ),
            // text field input for phone number
            const SizedBox(height: 20.0),
            Row(
              children: [
                const Text(
                  '+63',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5.0),
                Expanded(
                  child: TextFieldInput(
                    textEditingController: _phoneNumberController,
                    hintText: '9123456789',
                    textInputType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
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
              onTap: signUpAsAdmin,
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
                          valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                        ))
                      : const Text(
                          'Sign up',
                          style: TextStyle(
                            color: whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
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
                  child: const Text('Already have an account?'),
                ),
                GestureDetector(
                  onTap: navigateToLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    child: const Text(
                      ' Login here.',
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
