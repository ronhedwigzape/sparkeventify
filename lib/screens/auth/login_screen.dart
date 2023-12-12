import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/screens/auth/admin_signup_screen.dart';
import 'package:student_event_calendar/layouts/admin_screen_layout.dart';
import 'package:student_event_calendar/layouts/client_screen_layout.dart';
import 'package:student_event_calendar/screens/auth/client_selection_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_logo.dart';
import 'package:student_event_calendar/widgets/login_divider.dart';
import 'package:student_event_calendar/widgets/cspc_signin_button.dart';
import 'package:student_event_calendar/widgets/signup_navigation.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import '../../data/auth_repository.dart';
import '../../providers/darkmode_provider.dart';

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
      // ignore: use_build_context_synchronously
      Navigator.of(dialogContext!).pop();
    }

    if (res == 'Success') {
      onSignInSuccess(res);
    } else {
      onSignInFailure(res);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      UserCredential? userCredential = await AuthMethods().signInWithGoogle();
      if (userCredential != null) {
        // Handle successful sign-in
        final doc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
        final String userType = doc.get('userType');
        if (userType == 'Admin' && kIsWeb) {
          mounted ? Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminScreenLayout())) : '';
        } else if ((userType == 'Student' && !kIsWeb) || (userType == 'Staff' && !kIsWeb) || (userType == 'Officer' && !kIsWeb)) {
          mounted ? Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const ClientScreenLayout())) : '';
        } else {
          // Handle unknown user type or platform
        }
      } else {
        // Handle sign-in failure
        if (kDebugMode) {
          print("Sign in failed");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
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
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32.0),
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
                  padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
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
                      child: Text(
                        schoolName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: darkModeOn ? lightColor : darkColor),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: Text(
                        schoolAddress,
                        style: TextStyle(
                            color: darkModeOn ? lightColor : darkColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                // text field input for email
                Text('Log in',
                    style: TextStyle(
                      color: darkModeOn ? lightColor : darkColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 24.0),
                // Text field input for email address
                TextFieldInput(
                  prefixIcon: const Icon(Icons.email_outlined),
                  textEditingController: _emailController,
                  labelText: 'Email',
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                // Text field input for password
                TextFieldInput(
                  prefixIcon: const Icon(Icons.lock_outline),
                  textEditingController: _passwordController,
                  labelText: 'Password',
                  textInputType: TextInputType.visiblePassword,
                  isRegistration: false,
                  isPass: true,
                ),
                const SizedBox(height: 16.0),
                // Sign in button
                CSPCSignInButton(signIn: signIn),
                const SizedBox(height: 12.0),
                Flexible(
                  flex: 2,
                  child: Container(),
                ),
                SignUpNavigation(navigateToSignup: navigateToSignup),
                const SizedBox(
                  height: 10,
                ),
                // Login Divider
                const LoginDivider(),
                const SizedBox(
                  height: 10,
                ),
                SignInButton(
                  Buttons.Google,
                  text: "Sign up with Google",
                  onPressed: signInWithGoogle,
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
