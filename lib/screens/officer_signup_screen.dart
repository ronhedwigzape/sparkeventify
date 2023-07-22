import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/layouts/client_screen_layout.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/screens/login_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_logo.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';
import '../providers/darkmode_provider.dart';

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
  final TextEditingController _courseController = TextEditingController();
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
    _courseController.dispose();
    _yearController.dispose();
    _sectionController.dispose();
  }

  Future<void> signUpAsClient() async {
    setState(() {
      _isLoading = true;
    });

    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneNumberController.text.trim().isEmpty ||
        _courseController.text.trim().isEmpty ||
        _departmentController.text.trim().isEmpty ||
        _yearController.text.trim().isEmpty ||
        _sectionController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty
    ) return onSignupFailure('Please complete all required fields.');

    // Validate the phone number
    String phoneNumber = _phoneNumberController.text.trim();
    if (!RegExp(r'^9[0-9]{9}$').hasMatch(phoneNumber)) {
      onSignupFailure('Please enter your last 10 digits of the phone number.');
      return;
    }

    // Prepend '+63' to the phone number
    phoneNumber = '63$phoneNumber';

    model.Profile profile = model.Profile(
      fullName: _fullNameController.text.trim(),
      phoneNumber: phoneNumber,
      department: _departmentController.text.trim(),
      course: _courseController.text.trim(),
      year: _yearController.text.trim(),
      section: _sectionController.text.trim(),
    );

    String res = await AuthMethods().signUp(
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
        MaterialPageRoute(builder: (context) => const ClientScreenLayout()));
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
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return GestureDetector(
      // When screen touched, keyboard will be hidden
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
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: Container(),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                        child: Row(
                          children: [
                            Flexible(
                              child: CSPCLogo(
                                height: 60.0,
                              ),
                            ),
                            SizedBox(width: 20.0),
                            Text(
                              'Register as Officer',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(thickness: 1.0),
                      ),
                      Row(
                        children: [
                          // text field input for fullname
                          Expanded(
                            child: TextFieldInput(
                                textEditingController: _fullNameController,
                                labelText: 'Enter full name*',
                                textInputType: TextInputType.text
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          // text field input for email
                          Expanded(
                            child: TextFieldInput(
                                textEditingController: _emailController,
                                labelText: 'Enter your email*',
                                textInputType: TextInputType.emailAddress
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          Expanded(
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
                                      labelText: '9123456789*',
                                      textInputType: TextInputType.phone
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: TextFieldInput(
                                textEditingController: _courseController,
                                labelText: 'Course (e.g. BSIT)',
                                textInputType: TextInputType.text
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFieldInput(
                                textEditingController: _departmentController,
                                labelText: 'Department (e.g. CCS)*',
                                textInputType: TextInputType.text
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFieldInput(
                              textEditingController: _yearController,
                              labelText: 'Year (e.g. 1)*',
                              textInputType: TextInputType.text,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: TextFieldInput(
                              textEditingController: _sectionController,
                              labelText: 'Section (e.g. A)*',
                              textInputType: TextInputType.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      // text field input for password
                      TextFieldInput(
                        textEditingController: _passwordController,
                        labelText: 'Enter your password*',
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
                              decoration: ShapeDecoration(
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                                ),
                                color: darkModeOn ? darkModePrimaryColor : lightModeBlueColor,
                              ),
                              child: _isLoading
                                  ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(lightColor),
                                  ))
                                  : const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: lightColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ))),
                      const SizedBox(height: 12.0),
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
                ),
              )),
        ));
  }
}
