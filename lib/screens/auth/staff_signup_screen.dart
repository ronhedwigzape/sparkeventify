import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/screens/auth/login_screen.dart';
import 'package:student_event_calendar/layouts/client_screen_layout.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_logo.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

import '../../providers/darkmode_provider.dart';

class StaffSignupScreen extends StatefulWidget {
  const StaffSignupScreen({super.key});

  @override
  State<StaffSignupScreen> createState() => _StaffSignupScreenState();
}

class _StaffSignupScreenState extends State<StaffSignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleInitialController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  late String selectedStaffPositions = staffPositions[0];
  late String position = '';
  late String staffType = '';
  late String staffDescription = '';

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
  }

  Future<void> signUpAsClient() async {
    if (_firstNameController.text.trim().isEmpty ||
        _middleInitialController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneNumberController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        position.trim().isEmpty ||
        staffType.trim().isEmpty ||
        staffDescription.trim().isEmpty
    ) return onSignupFailure('Please complete all required fields.');

    // Validate the phone number
    String phoneNumber = _phoneNumberController.text.trim();
    if (!RegExp(r'^9[0-9]{9}$').hasMatch(phoneNumber)) {
      onSignupFailure('Please enter your last 10 digits of the phone number.');
      return;
    }

    if (selectedStaffPositions == staffPositions[0] || staffType.isEmpty || staffDescription.isEmpty || position.isEmpty) {
      onSignupFailure('Please select your position.');
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
      staffPosition: position,
      staffType: staffType,
      staffDescription: staffDescription,
    );
    
    BuildContext? dialogContext;
    showDialog(context: context, builder: (context) {
      return const Center(child: CircularProgressIndicator());
    });

    // Add a slight delay to ensure the dialog has displayed
    await Future.delayed(const Duration(milliseconds: 100));

    String res = await AuthMethods().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        profile: profile,
        userType: 'Staff');

    // ignore: unnecessary_null_comparison
    if (dialogContext != null) {
      mounted ? Navigator.of(dialogContext).pop() : '';
    }

    if (res == 'Success') {
      onSignupSuccess();
    } else {
      onSignupFailure(res);
    }
  }

  void onSignupSuccess() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ClientScreenLayout()));
  }

  void onSignupFailure(String message) {
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Row(
                      children: [
                        const Flexible(
                          child: CSPCLogo(
                            height: 60.0,
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Text(
                          'Register as Staff',
                          style: TextStyle(
                            color: darkModeOn ? lightColor : darkColor,
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
                      Flexible(
                        child: TextFieldInput(
                          prefixIcon: const Icon(Icons.person),
                          textEditingController: _firstNameController,
                          labelText: 'First name*',
                          textInputType: TextInputType.text,
                        ),   
                      ),
                      const SizedBox(width: 10,),
                      Flexible(
                        child: TextFieldInput(
                          prefixIcon: const Icon(Icons.person),
                          textEditingController: _middleInitialController,
                          labelText: 'Middle Initial*',
                          textInputType: TextInputType.text,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  // text field input for last name
                  TextFieldInput(
                    prefixIcon: const Icon(Icons.person),
                    textEditingController: _lastNameController,
                    labelText: 'Last name*',
                    textInputType: TextInputType.text,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Text(
                        '+63',
                        style: TextStyle(
                          color: darkModeOn ? lightColor : darkColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: TextFieldInput(
                          prefixIcon: const Icon(Icons.phone),
                          textEditingController: _phoneNumberController,
                          labelText: 'Phone: 9123456789*',
                          textInputType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  // text field input for email
                  TextFieldInput(
                    prefixIcon: const Icon(Icons.email),
                    textEditingController: _emailController,
                    labelText: 'Email*',
                    textInputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Flexible(
                        child: FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_4),
                                labelText: 'Position*',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,
                                  ),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedStaffPositions,
                                  style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedStaffPositions = newValue ?? staffPositions[0]; // handle null selection

                                      List<String> splitValue = selectedStaffPositions.split(' - ');
                                      position = splitValue[0];
                                      staffType = splitValue[1];
                                      staffDescription = splitValue[2];
                                    });
                                  },
                                  items: staffPositions.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value.isEmpty ? null : value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  // text field input for password
                  TextFieldInput(
                    prefixIcon: const Icon(Icons.lock),
                    textEditingController: _passwordController,
                    labelText: 'Password*',
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
                          child: const Text(
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
                        child: Text('Already have an account?', style: TextStyle(color: darkModeOn ? lightColor : darkColor,),),
                      ),
                      GestureDetector(
                        onTap: navigateToLogin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          child: Text(
                            ' Login here',
                            style: TextStyle(
                              color: darkModeOn ? lightColor : darkColor,
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
