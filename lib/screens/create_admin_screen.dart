import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/screens/auth/login_screen.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';
import '../../providers/darkmode_provider.dart';

class CreateAdminScreen extends StatefulWidget {
  const CreateAdminScreen({super.key});

  @override
  State<CreateAdminScreen> createState() => CreateAdminScreenState();
}

class CreateAdminScreenState extends State<CreateAdminScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleInitialController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAndSetConstants();
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

    // Validation for password
    if (_passwordController.text.trim() != _retypePasswordController.text.trim()) {
      onSignupFailure('Passwords do not match.');
      return;
    }

    // Prepend '+63' to the phone number
    phoneNumber = '63$phoneNumber';

    String fullname = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    model.Profile profile = model.Profile(
      fullName: fullname,
      firstName: _firstNameController.text.trim(),
      middleInitial: _middleInitialController.text.trim(),
      lastName: _lastNameController.text.trim(),
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
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _retypePasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: MediaQuery.of(context).size.width > webScreenSize!
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
            const SizedBox(height: 20.0),
            // text field input for email
            const Text('Create an Admin account',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 20.0),
            // text field input for username
            Row(
              children: [
                Flexible(
                  child: TextFieldInput(
                    textEditingController: _emailController,
                    labelText: 'Email address',
                    textInputType: TextInputType.emailAddress,
                  ), 
                ),
                const SizedBox(width: 10.0),
                Flexible(
                  child: Row(
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
                          labelText: '9123456789',
                          textInputType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),  
                )
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Flexible(
                  child: TextFieldInput(
                    textEditingController: _firstNameController,
                    labelText: 'First name*',
                    textInputType: TextInputType.text,
                  ),
                ),
                const SizedBox(width: 10.0),
                Flexible(
                  child: TextFieldInput(
                    textEditingController: _middleInitialController,
                    labelText: 'Middle Initial',
                    textInputType: TextInputType.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Flexible(
                  child:  TextFieldInput(
                    textEditingController: _lastNameController,
                    labelText: 'Last name*',
                    textInputType: TextInputType.text,
                  ),
                ), 
              ],
            ),
            const SizedBox(height: 10.0),
            // text field input for password
            TextFieldInput(
              textEditingController: _passwordController,
              labelText: 'Password',
              textInputType: TextInputType.visiblePassword,
              isPass: true,
            ),
            const SizedBox(height: 10.0),
            TextFieldInput(
              prefixIcon: const Icon(Icons.lock),
              textEditingController: _retypePasswordController,
              labelText: 'Retype Password*',
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
                  decoration: ShapeDecoration(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    color: darkModeOn ? darkModePrimaryColor : lightModeBlueColor,
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(lightColor),
                        ))
                      : const Text(
                          'Create Admin',
                          style: TextStyle(
                            color: lightColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
            ),
            const SizedBox(height: 12.0),
            Flexible(
              flex: 2,
              child: Container(),
            )
            // transitioning to signing up
          ],
        ),
      )),
    );
  }
}
