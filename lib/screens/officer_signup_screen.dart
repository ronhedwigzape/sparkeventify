import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/screens/login_screen.dart';
import 'package:student_event_calendar/screens/officer_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_logo.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

class OfficerSignupScreen extends StatefulWidget {
  const OfficerSignupScreen({super.key});

  @override
  State<OfficerSignupScreen> createState() => _OfficerSignupScreenState();
}

class _OfficerSignupScreenState extends State<OfficerSignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _sectionController.dispose();
  }

  Future<void> signUpAsClient() async {
    setState(() {
      _isLoading = true;
    });

    // Validate the phone number
    String phoneNumber = _phoneNumberController.text.trim();
    if (!RegExp(r'^9[0-9]{9}$').hasMatch(phoneNumber)) {
      onSignupFailure('Please enter your last 10 digits of the phone number');
      return;
    }

    // Prepend '+63' to the phone number
    phoneNumber = '63$phoneNumber';

    model.Profile profile = model.Profile(
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      department: _departmentController.text.trim(),
      year: _yearController.text.trim(),
      section: _sectionController.text.trim(),
    );

    String res = await AuthMethods().signUpAsClient(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        profile: profile, 
        userType: 'Officer');

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
        MaterialPageRoute(builder: (context) => const OfficerScreen()));
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
                const CspcLogo( height: 90.0,),
                const SizedBox(height: 20.0),
                const Text(
                  'Register as Officer',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30.0),
                Row(
                  children: [
                    // text field input for fullname
                    Flexible(
                      child: TextFieldInput(
                        textEditingController: _fullNameController,
                        hintText: 'Enter your full name*',
                        textInputType: TextInputType.text,
                      ), 
                    ),
                    const SizedBox(width: 10.0),
                    // text field input for email
                    Flexible(
                      child: TextFieldInput(
                        textEditingController: _emailController,
                        hintText: 'Enter your email*',
                        textInputType: TextInputType.emailAddress,
                      ),
                    )
                  ],
                ),       
                const SizedBox(height: 10.0),
                Row(
                  children: [
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
                          const SizedBox(width:5.0), 
                          Expanded(
                            child: TextFieldInput(
                              textEditingController: _phoneNumberController,
                              hintText: '9123456789*',
                              textInputType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Flexible(
                      child: TextFieldInput(
                        textEditingController: _departmentController,
                        hintText: 'Department',
                        textInputType: TextInputType.text,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Flexible(
                      child: TextFieldInput(
                        textEditingController: _yearController,
                        hintText: 'Year (Students)',
                        textInputType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Flexible(
                      child: TextFieldInput(
                        textEditingController: _sectionController,
                        hintText: 'Section (Students)',
                        textInputType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                // text field input for password
                TextFieldInput(
                  textEditingController: _passwordController,
                  hintText: 'Enter your password*',
                  textInputType: TextInputType.visiblePassword,
                  isPass: true,
                ),
                const SizedBox(height: 12.0),
                // button login
                InkWell(
                    onTap: signUpAsClient,
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
                            : const Text(
                              'Sign up',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ))),
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
