import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/screens/login_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';
import '../services/firebase_notifications.dart';
import 'package:another_flushbar/flushbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<model.User?> currentUser = FireStoreUserMethods().getCurrentUserData();
  Uint8List? _pickedImage;
  bool _isImageUpdated = false;
  bool _isError = false;

  void _showSuccessMessage() {
    Flushbar(
      message: "Profile image updated successfully!",
      duration: const Duration(seconds: 5),
    ).show(context);
  }

  void selectImage() async {
    Uint8List image = await pickImage(ImageSource.gallery);
    setState(() {
      _pickedImage = image;
    });
  }

  _signOut() async {
    return showDialog(
      context: context,
      builder: (context) {
        final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
        return SimpleDialog(
          title: Text(
            'Log Out Confirmation',
            style: TextStyle(
              color: Colors.red[900],
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text('Are you sure you want to sign out?'),
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              onPressed: () async {
                await FirebaseNotificationService().unregisterDevice(FirebaseAuth.instance.currentUser!.uid);
                await AuthMethods().signOut();
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LoginScreen()));
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
          return Center(child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          model.User? currentUser = snapshot.data;
          String? profileImage = currentUser?.profile?.profileImage ?? '';
          String? uid = currentUser?.uid;
          String email = currentUser?.email ?? '';
          // String password = currentUser?.password ?? '';
          String userType = currentUser?.userType ?? '';
          String phoneNumber = currentUser?.profile!.phoneNumber ?? '';
          String fullName = currentUser?.profile!.fullName ?? '';
          String department = currentUser?.profile!.department ?? '';
          String course = currentUser?.profile!.course ?? '';
          String year = currentUser?.profile!.year ?? '';
          String section = currentUser?.profile!.section ?? '';
          String organization = currentUser?.profile!.organization ?? '';
          String position = currentUser?.profile!.position ?? '';

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
            final maxWidth = min(1200, constraints.maxWidth).toDouble();
            return Scaffold(
              body: Center(
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
                              // if _pickedImage is not null, display the _pickedImage
                              _pickedImage != null
                                ? CircleAvatar(
                                    radius: 40,
                                    backgroundImage: MemoryImage(_pickedImage!),
                                    onBackgroundImageError: (exception, stackTrace) {
                                      setState(() {
                                        _isError = true;
                                      });
                                    },
                                    backgroundColor: darkColor,
                                    child: _isError ? const Icon(Icons.error, color: lightColor,) : null,)
                                // else if _pickedImage is null, display the profileImage
                                : profileImage.isNotEmpty
                                ? CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(profileImage),
                                    onBackgroundImageError: (exception, stackTrace) {
                                      setState(() {
                                        _isError = true;
                                      });
                                    },
                                    backgroundColor: darkColor,
                                    child: _isError ? const Icon(Icons.error, color: lightColor,) : null,
                                  )
                                // else display the default profile image
                                : CircleAvatar(
                                    radius: 40,
                                    backgroundColor: darkColor,
                                    backgroundImage: const NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'),
                                    onBackgroundImageError: (exception, stackTrace) {
                                      setState(() {
                                        _isError = true;
                                      });
                                    },
                                    child: _isError ? const Icon(Icons.error, color: lightColor,) : null,
                                  ),
                              Positioned(
                                bottom: -10,
                                left: 42,
                                child: IconButton(
                                  onPressed: _pickedImage == null ? selectImage : () {},
                                  icon: const Icon(
                                    Icons.add_a_photo,
                                  ),
                                  tooltip: 'Change profile picture',
                                )
                              ),  
                            ],
                          ), 
                        ),
                       _pickedImage != null && !_isImageUpdated ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Update profile picture?'),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await FireStoreUserMethods().updateProfileImage(_pickedImage!, uid!); 
                                      setState(() {
                                        _isImageUpdated = true;
                                      });
                                      _showSuccessMessage();
                                    }, 
                                    icon: const Icon(Icons.check_circle, color: darkModeGrassColor,)
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _pickedImage = null;
                                        _isImageUpdated = false;
                                      });
                                    }, 
                                    icon: const Icon(Icons.cancel, color: darkModeMaroonColor,)
                                  ),  
                                ],
                              ),
                            ),
                          ],
                        ) : const SizedBox.shrink(),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              userType == 'Officer' ?
                              Column(
                                children: [
                                  Text(
                                  '${position.toUpperCase()} - ${organization.toUpperCase()}', 
                                  style: TextStyle(
                                    fontSize: 15.0, 
                                    fontWeight: FontWeight.bold,
                                    color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor)),
                                  Text(
                                  userType.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12.0, 
                                    fontWeight: FontWeight.bold,
                                    color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor)),
                                ],
                              )
                              : userType == 'Student' ? Text(
                                '${course.toUpperCase()} ${userType.toUpperCase()}', 
                                style: TextStyle(
                                  fontSize: 15.0, 
                                  fontWeight: FontWeight.bold,
                                  color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor))
                              : userType == 'Staff' ? Text(
                                '${position.toUpperCase()} - ${userType.toUpperCase()}', 
                                style: TextStyle(
                                  fontSize: 15.0, 
                                  fontWeight: FontWeight.bold,
                                  color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor))
                              : Text(   
                                userType.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 15.0, 
                                  fontWeight: FontWeight.bold,
                                  color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor)),
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
                                    Text('Dept: $department', style: const TextStyle(fontSize: 16.0))
                                  ],
                                )
                            ),
                            Flexible(child:
                              Row(
                                children: [
                                  const Icon(Icons.school),
                                  const SizedBox(width: 20),
                                  Text('Course: $course', style: const TextStyle(fontSize: 16.0))
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
                            Text(currentUser?.profile?.position ?? 'Staff',
                            style: const TextStyle(fontSize: 16.0)),
                          ],
                        ) : const SizedBox.shrink(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: SizedBox(
                                  height: kIsWeb ? 40 : null,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: darkModeOn ? lightModePrimaryColor : darkModePrimaryColor,
                                    ),
                                    label: Text(
                                      darkModeOn ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                                      style: TextStyle(
                                        color: darkModeOn ? lightColor : darkColor,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    icon: Icon(darkModeOn ? Icons.light_mode : Icons.dark_mode,
                                      color: darkModeOn ? lightColor : darkColor,),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return SimpleDialog(
                                            title: Text(
                                              'Switch to ${darkModeOn ? 'Light' : 'Dark'} Mode',
                                              style: TextStyle(
                                                color: darkModeOn ? lightColor : darkColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                                child: Text(
                                                  'Are you sure you want to switch to ${darkModeOn ? 'Light' : 'Dark'} Mode? This will reload the app.',
                                                  style: TextStyle(color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor),
                                                  ),
                                              ),
                                              SimpleDialogOption(
                                                padding: const EdgeInsets.all(20),
                                                onPressed: () {
                                                  Provider.of<DarkModeProvider>(context, listen: false).toggleTheme();
                                                  Navigator.of(context).pop();
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
                                                    const Text('No'),
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
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        kIsWeb ? const SizedBox(height: 20) : const SizedBox.shrink(),
                        Row(                    
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ));
         } );
        }
      }
    );
  }
}
