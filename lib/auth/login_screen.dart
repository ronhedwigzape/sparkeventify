import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/auth/admin_signup_screen.dart';
import 'package:student_event_calendar/layouts/admin_screen_layout.dart';
import 'package:student_event_calendar/layouts/client_screen_layout.dart';
import 'package:student_event_calendar/auth/client_selection_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_logo.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

import '../data/auth_repository.dart';
import '../providers/darkmode_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _authRepository = AuthRepository();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<void> signIn() async {
    BuildContext? dialogContext;
    showDialog(
      context: context,
      builder: (context) {
        dialogContext = context;
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Add a slight delay to ensure the dialog has displayed
    await Future.delayed(const Duration(milliseconds: 100));

    String res = await _authRepository.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (dialogContext != null) {
      Navigator.of(dialogContext!).pop();
    }

    if (res == 'Success') {
      onSignInSuccess(res);
    } else {
      onSignInFailure(res); 
    }
  }

  void onSignInSuccess(String message) async { 
    if (!kIsWeb) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ClientScreenLayout()));
    } else {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AdminScreenLayout()));
    }
  }

  void onSignInFailure(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  void navigateToSignup() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => !kIsWeb
            ? const ClientSelectionScreen()
            : const AdminSignupScreen()));
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
              height: MediaQuery.of(context).size.height,
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 3) :
              const EdgeInsets.symmetric(horizontal: 32.0),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  flex: 2,
                  child: Container(),
                ),
                // Logo
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: CSPCLogo(height: 150.0),
                ),
                // School name and address
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: const Text(
                        schoolName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
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
                const Text('Log in',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 24.0),
                TextFieldInput(
                  prefixIcon: const Icon(Icons.email_outlined),
                  textEditingController: _emailController,
                  labelText: 'Email',
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                // text field input for password
                TextFieldInput(
                  prefixIcon: const Icon(Icons.lock_outline),
                  textEditingController: _passwordController,
                  labelText: 'Password',
                  textInputType: TextInputType.visiblePassword,
                  isPass: true,
                ),
                const SizedBox(height: 16.0),
                // button login
                InkWell(
                  onTap: signIn,
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
                      child: const Text('Log in', 
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
                ),
                !kIsWeb ? Row(
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
                ) : const SizedBox.shrink(),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
