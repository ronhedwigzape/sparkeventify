import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/auth/login_screen.dart';
import 'package:student_event_calendar/layouts/client_screen_layout.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleInitialController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  late String selectedProgramAndDepartment = programsAndDepartments[0];
  late String program;
  late String department;

  Future<void> signUpAsClient() async {
    BuildContext? dialogContext;
    showDialog(context: context, builder: (context) {
      return const Center(child: CircularProgressIndicator());
    });

    if (_firstNameController.text.trim().isEmpty ||
        _middleInitialController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneNumberController.text.trim().isEmpty ||
        _yearController.text.trim().isEmpty ||
        _sectionController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _organizationController.text.trim().isEmpty ||
        _positionController.text.trim().isEmpty ||
        program.isEmpty ||
        department.isEmpty
    ) return onSignupFailure('Please complete all required fields.');

    // Validate the phone number
    String phoneNumber = _phoneNumberController.text.trim();
    if (!RegExp(r'^9[0-9]{9}$').hasMatch(phoneNumber)) {
      onSignupFailure('Please enter your last 10 digits of the phone number.');
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
      department: department,
      program: program,
      year: _yearController.text.trim(),
      section: _sectionController.text.trim().toUpperCase(),
      organization: _organizationController.text.trim(),
      officerPosition: _positionController.text.trim(),
    );

    // Add a slight delay to ensure the dialog has displayed
    await Future.delayed(const Duration(milliseconds: 100));

    String res = await AuthMethods().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        profile: profile,
        userType: 'Officer');

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
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _yearController.dispose();
    _sectionController.dispose();
    _organizationController.dispose();
    _positionController.dispose();
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
                          // text field input for first name
                          Expanded(
                            child: TextFieldInput(
                              prefixIcon: const Icon(Icons.person),
                              textEditingController: _firstNameController,
                              labelText: 'First name*',
                              textInputType: TextInputType.text
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          // text field input for middle initial
                          Expanded(
                            child: TextFieldInput(
                              prefixIcon: const Icon(Icons.person),
                              textEditingController: _middleInitialController,
                              labelText: 'Middle Initial*',
                              textInputType: TextInputType.text
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          // text field input for last name
                          Expanded(
                            child: TextFieldInput(
                              prefixIcon: const Icon(Icons.person),
                              textEditingController: _lastNameController,
                              labelText: 'Last name*',
                              textInputType: TextInputType.text
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          // text field input for email
                          Expanded(
                            child: TextFieldInput(
                              prefixIcon: const Icon(Icons.email),
                              textEditingController: _emailController,
                              labelText: 'Email*',
                              textInputType: TextInputType.emailAddress
                            ),
                          )
                        ]
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
                                      prefixIcon: const Icon(Icons.phone),
                                      textEditingController: _phoneNumberController,
                                      labelText: '9123456789*',
                                      textInputType: TextInputType.phone
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          Flexible(
                            child: FormField<String>(
                              builder: (FormFieldState<String> state) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.school),
                                    labelText: 'Program and Department*',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,
                                      ),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedProgramAndDepartment,
                                      style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedProgramAndDepartment = newValue ?? programsAndDepartments[0]; // handle null selection

                                          // split the selected value:
                                          List<String> splitValue = selectedProgramAndDepartment.split(' - ');
                                          program = splitValue[0];
                                          department = splitValue[1];
                                        });
                                      },
                                      items: programsAndDepartments.map<DropdownMenuItem<String>>((String value) {
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
                      Row(
                        children: [
                          Flexible(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: Divider.createBorderSide(
                                    context,
                                    color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,)
                                ),
                                prefixIcon: const Icon(Icons.school),
                                labelText: 'Year*',
                              ),
                              value: _yearController.text.isEmpty
                                  ? null
                                  : _yearController.text,
                              items: <String>['1', '2', '3', '4']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _yearController.text = newValue!;
                                });
                              },
                            )
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: TextFieldInput(
                              prefixIcon: const Icon(Icons.school),
                              textEditingController: _sectionController,
                              labelText: 'Section (e.g. A)*',
                              textInputType: TextInputType.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      // text field input for organization
                      TextFieldInput(
                        prefixIcon: const Icon(Icons.group),
                        textEditingController: _organizationController,
                        labelText: 'Organization (e.g. JPCS Chapter)*',
                        textInputType: TextInputType.text,
                      ),
                      const SizedBox(height: 10.0),
                      // text field input for organization position
                      TextFieldInput(
                        prefixIcon: const Icon(Icons.person_2),
                        textEditingController: _positionController,
                        labelText: 'Organization position',
                        textInputType: TextInputType.text,
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
