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
import 'package:student_event_calendar/screens/auth/password_recovery_screen.dart';
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
  final TextEditingController _emailController = TextEditingController(); // Controller for the email input field
  final TextEditingController _passwordController = TextEditingController(); // Controller for the password input field
  final _authRepository = AuthRepository(); // Instance of the AuthRepository class
  bool _isLoading = false; // State variable for loading status

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAndSetConstants();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose(); // Dispose email controller
    _passwordController.dispose(); // Dispose password controller
  }

  Future<void> signIn() async {
    // Show a loading dialog
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
      email: _emailController.text.trim(), // Trimmed email input
      password: _passwordController.text.trim(), // Trimmed password input
    );

    // Handle sign-in result
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
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? userCredential = await AuthMethods().signInWithGoogle();
      if (userCredential != null) {
        // Check if the user is in the 'users' collection and if they are disabled
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userSnapshot.exists && userSnapshot.data() != null) {
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
          if (userData['disabled'] == true) {
            // User is disabled, do not proceed with sign-in
            setState(() {
              _isLoading = false;
            });
            onSignInFailure('Your account has been disabled. Please contact support for further assistance.');
            return;
          }
        }

        // Check if the user is in the 'trashedUsers' collection
        DocumentSnapshot trashedUserSnapshot = await FirebaseFirestore.instance
            .collection('trashedUsers')
            .doc(userCredential.user!.uid)
            .get();

        if (trashedUserSnapshot.exists) {
          // User is trashed, do not proceed with sign-in
          setState(() {
            _isLoading = false;
          });
          onSignInFailure('Your account has been disabled. Please contact support for further assistance.');
          return;
        }

        // User is not disabled or trashed, proceed with sign-in
        // Handle successful sign-in
        final String userType = userSnapshot.get('userType');
        if (userType == 'Admin' && kIsWeb) {
          mounted ? Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminScreenLayout())) : '';
        } else if ((userType == 'Student' && !kIsWeb) || (userType == 'Staff' && !kIsWeb) || (userType == 'Officer' && !kIsWeb) || (userType == 'Guest' && !kIsWeb)) {
          mounted ? Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const ClientScreenLayout())) : '';
        } else {
          // Handle unknown user type or platform
          onSignInFailure('Unknown user type or platform');
        }
      } else {
        // Handle sign-in failure
        onSignInFailure("Sign in failed");
      }
    } catch (e) {
      onSignInFailure(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  void onSignInSuccess(String message) async {
    // Handle successful sign-in
    if (!kIsWeb) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ClientScreenLayout()));
    } else {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AdminScreenLayout()));
    }
  }

  void onSignInFailure(String message) {
    // Handle sign-in failure
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
    // Build the login screen UI
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return FutureBuilder(
      future: fetchAndSetConstants(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
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
                          flex: 1,
                          child: Container(),
                        ),
                        // Logo
                        const Padding(
                          padding: EdgeInsets.only(top: 25),
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
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PasswordRecoveryScreen()));
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                              ),
                            ),
                          ],
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
                          text: _isLoading ? "Loading..." : "Sign up with Google",
                          onPressed: () async {
                            if (!_isLoading) {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                await signInWithGoogle();
                              } catch(e) {
                                if(e is FirebaseAuthException){
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(e.message!),
                                    duration: const Duration(seconds: 2),
                                  ));
                                }
                              }
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
