import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/screens/edit_profile_screen.dart';
import 'package:student_event_calendar/screens/login_screen.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_background.dart';
import 'package:student_event_calendar/widgets/custom_spinner.dart';
import 'package:student_event_calendar/widgets/dark_mode_dialog.dart';
import '../services/firebase_notifications.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<model.User?> currentUser = FireStoreUserMethods().getCurrentUserData();
  
  _signOut() async {
    return showDialog(
      context: context,
      builder: (context) {
        final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
        return SimpleDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Sign Out Confirmation',
                  style: TextStyle(
                    color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text('Are you sure you want to sign out?'),
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              onPressed:() async {
                bool isConnected = await ConnectivityService().isConnected();
                if (isConnected) {
                  await FirebaseNotificationService().unregisterDevice(FirebaseAuth.instance.currentUser!.uid);
                  await AuthMethods().signOut();
                  if (mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
                  }
                } else {
                  // Show a message to the user
                  mounted ? ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.wifi_off, color: darkModeOn ? black : white),
                          const SizedBox(width: 10,),
                          const Flexible(child: Text('No internet connection. Please check your connection and try again.')),
                        ],
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  ) : '';
                }
              },
              child: Row(
                children: <Widget>[
                  Icon(Icons.check_circle, 
                  color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                  const SizedBox(width: 10),
                  const Text('Yes'),
                ],
              ),
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.cancel, color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
                  const SizedBox(width: 10),
                  const Text('Go Back'),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return FutureBuilder<model.User?>(
      future: currentUser,
      builder: (context, AsyncSnapshot<model.User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CustomSpinner());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          model.User? currentUser = snapshot.data;
          String? profileImage = currentUser?.profile?.profileImage ?? '';
          String email = currentUser?.email ?? '';
          // String password = currentUser?.password ?? '';
          String userType = currentUser?.userType ?? '';
          String phoneNumber = currentUser?.profile!.phoneNumber ?? '';
          String fullName = currentUser?.profile!.fullName ?? '';
          String department = currentUser?.profile!.department ?? '';
          String program = currentUser?.profile!.program ?? '';
          String year = currentUser?.profile!.year ?? '';
          String section = currentUser?.profile!.section ?? '';
          String organization = currentUser?.profile!.organization ?? '';
          String officerPosition = currentUser?.profile!.officerPosition ?? '';
          String staffPosition = currentUser?.profile!.staffPosition ?? '';

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
            final maxWidth = min(900, constraints.maxWidth).toDouble();
            return Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: CSPCBackground(height: MediaQuery.of(context).size.height),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          darkModeOn ? darkColor.withOpacity(0.1) : lightColor.withOpacity(0.1),
                          darkModeOn ? darkColor : lightColor,
                        ],
                        stops: const [
                          0.0,
                          1.0
                        ]
                      ),
                    ),
                  ),
                  Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(fullName, style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                    // _pickedImage is null, display the profileImage
                                    profileImage.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage(profileImage),
                                        backgroundColor: darkColor,
                                      )
                                    // else display the default profile image
                                    : const CircleAvatar(
                                        radius: 40,
                                        backgroundColor: darkColor,
                                        backgroundImage: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'),
                                    ),  
                                ],
                              ), 
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  userType == 'Officer' ?
                                  Column(
                                    children: [
                                      Text(
                                      '${officerPosition.toUpperCase()} - ${organization.toUpperCase()}', 
                                      style: TextStyle(
                                        fontSize: 15.0, 
                                        fontWeight: FontWeight.bold,
                                        color: darkModeOn ? darkModeSecondaryColor : darkColor)),
                                      Text(
                                      userType.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12.0, 
                                        fontWeight: FontWeight.bold,
                                        color: darkModeOn ? darkModeTertiaryColor : darkColor)),
                                    ],
                                  )
                                  : userType == 'Student' ? Text(
                                    '${program.toUpperCase()} ${userType.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 15.0, 
                                      fontWeight: FontWeight.bold,
                                      color: darkModeOn ? darkModeSecondaryColor : darkColor))
                                  : userType == 'Staff' ? Text(
                                    '${staffPosition.toUpperCase()} - ${userType.toUpperCase()}', 
                                    style: TextStyle(
                                      fontSize: 15.0, 
                                      fontWeight: FontWeight.bold,
                                      color: darkModeOn ? darkModeSecondaryColor : darkColor))
                                  : Text(   
                                    userType.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 15.0, 
                                      fontWeight: FontWeight.bold,
                                      color: darkModeOn ? darkModeSecondaryColor : darkColor)),
                                ],
                              ),
                            ),
                            kIsWeb ? const SizedBox(height: 20) : const SizedBox.shrink(),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child:  Row(
                                    children: <Widget>[
                                      const Icon(Icons.email),
                                      const SizedBox(width: 20),
                                      Text(email, style: const TextStyle(fontSize: 16.0)), 
                                    ],
                                  ),
                                ),
                              ]  
                            ),
                            const Divider(height: 30, thickness: 2),
                            Row(
                              children: [
                                const Icon(Icons.person),
                                const SizedBox(width: 20),
                                Text(fullName, style: const TextStyle(fontSize: 16.0)),
                              ],
                            ),
                            const Divider(height: 30, thickness: 2),
                            Row(
                              children: <Widget>[
                                const Icon(Icons.phone),
                                const SizedBox(width: 20),
                                Text('+$phoneNumber', style: const TextStyle(fontSize: 16.0)),
                              ],
                            ),
                            currentUser?.userType != 'Staff' && currentUser?.userType != 'Admin' ? const Divider(height: 30, thickness: 2) : const SizedBox.shrink(),
                            currentUser?.userType != 'Staff' && currentUser?.userType != 'Admin'
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(child:
                                    Row(
                                      children: [
                                        const Icon(Icons.school),
                                        const SizedBox(width: 20),
                                        Flexible(child: Text('Dept: $department', style: const TextStyle(fontSize: 16.0)))
                                      ],
                                    )
                                ),
                                Flexible(child:
                                  Row(
                                    children: [
                                      const Icon(Icons.school),
                                      const SizedBox(width: 20),
                                      Flexible(child: Text('Program: $program', style: const TextStyle(fontSize: 16.0)))
                                    ],
                                  )
                                ),
                              ],
                            ): const SizedBox.shrink(),
                            currentUser?.userType != 'Staff' && currentUser?.userType != 'Admin' ? const Divider(height: 30, thickness: 2) : const SizedBox.shrink(),
                            currentUser?.userType != 'Staff' && currentUser?.userType != 'Admin'
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.school),
                                      const SizedBox(width: 20),
                                      Text('Year: $year', style: const TextStyle(fontSize: 16.0)),
                                    ],
                                  )
                                ),
                                Flexible(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.school),
                                      const SizedBox(width: 20), 
                                      Text('Section: $section',
                                      style: const TextStyle(fontSize: 16.0))
                                    ]
                                  )
                                )
                              ],
                            ) : const SizedBox.shrink(),
                            currentUser?.userType != 'Staff' ? const SizedBox(height: 20) : const SizedBox.shrink(),
                            currentUser?.userType == 'Staff' ? const Divider(height: 30, thickness: 2) : const SizedBox.shrink(),
                            currentUser?.userType == 'Staff' ? 
                            Row(
                              children: [
                                const Icon(Icons.work),
                                const SizedBox(width: 20),
                                Text(currentUser?.profile?.staffPosition ?? 'Staff',
                                style: const TextStyle(fontSize: 16.0)),
                              ],
                            ) : const SizedBox.shrink(),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: SizedBox(
                                    height: kIsWeb ? 40 : null,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: darkModeOn ? lightColor : darkColor,
                                      ),
                                      label: Text(
                                        darkModeOn ? 'Light Mode' : 'Dark Mode',
                                        style: TextStyle(
                                          color: darkModeOn ? darkColor : lightColor,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      icon: Icon(darkModeOn ? Icons.light_mode : Icons.dark_mode,
                                        color: darkModeOn ? darkColor : lightColor,),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return const DarkModeDialog();
                                          }
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: SizedBox(
                                    height: kIsWeb ? 40 : null,
                                    child: ElevatedButton.icon(
                                      icon: Icon(Icons.edit, color: darkModeOn ? darkColor : lightColor,),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: darkModeOn ? darkModeGrassColor : lightModeGrassColor,
                                        ),
                                      onPressed: () {
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) =>  EditProfileScreen(user: currentUser!)));
                                      },
                                      label: Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                          color: darkModeOn ? darkColor : lightColor,
                                          fontSize: 16.0,
                                        )),
                                    ),
                                  )
                                ),
                              ],
                            ),
                            kIsWeb ? const SizedBox(height: 20) : const SizedBox.shrink(),
                            Row(                    
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: kIsWeb ? 40 : null,
                                    child: TextButton.icon(
                                      onPressed: _signOut,
                                      style: TextButton.styleFrom(
                                        backgroundColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                                      ),
                                      icon: Icon(
                                          Icons.logout,
                                          color: darkModeOn ? darkColor : lightColor,
                                      ),
                                      label: Text(
                                        'Sign out',
                                        style: TextStyle(
                                          color: darkModeOn ? darkColor : lightColor,
                                          fontSize: 16.0,
                                        ),
                                      )
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                            ),
                ],
              ));
         } );
        }
      }
    );
  }
}
