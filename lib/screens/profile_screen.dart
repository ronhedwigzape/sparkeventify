import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_event_calendar/models/user.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/screens/login_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<User?> currentUser = FireStoreUserMethods().getCurrentUserData();
  Uint8List? _pickedImage;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pickedImage = null;
  }

  void _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Upload an Image'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.camera),
                    SizedBox(width: 10),
                    Text('Take a photo'),
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.camera);
                  if (file != null) {
                    _pickedImage = file;
                    const SnackBar snackBar =
                        SnackBar(content: Text('Image is uploaded!'));
                    ScaffoldMessenger.of(_scaffoldMessengerKey.currentContext!)
                        .showSnackBar(snackBar);
                  }
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.image_rounded),
                    SizedBox(width: 10),
                    Text('Choose from gallery'),
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.gallery);
                  if (file != null) {
                    _pickedImage = file;
                    const SnackBar snackBar =
                        SnackBar(content: Text('Image is uploaded!'));
                    ScaffoldMessenger.of(_scaffoldMessengerKey.currentContext!)
                        .showSnackBar(snackBar);
                  }
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.cancel),
                    SizedBox(width: 10),
                    Text('Cancel'),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _signOut() async {
    return showDialog(
        context: context,
        builder: (context) {
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
                  await AuthMethods().signOut();
                  if (mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                  }
                },
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.check_circle, color: grassColor), 
                    SizedBox(width: 10),
                    Text('Yes'),
                  ],
                ),
                ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.cancel, color: maroonColor), 
                    SizedBox(width: 10),
                    Text('Go Back'),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
        future: currentUser,
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            User? currentUser = snapshot.data;
            String profileImage = currentUser?.profile!.profileImage ?? '';
            String username = currentUser?.username ?? '';
            String email = currentUser?.email ?? '';
            // String password = currentUser?.password ?? '';
            String phoneNumber = currentUser?.profile!.phoneNumber ?? '';
            String fullName = currentUser?.profile!.fullName ?? '';
            String department = currentUser?.profile!.department ?? '';
            String year = currentUser?.profile!.year ?? '';
            String section = currentUser?.profile!.section ?? '';

            return Scaffold(
                body: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        // if _pickedImage is not null, display the _pickedImage
                        _pickedImage != null
                            ? CircleAvatar(
                                radius: 64,
                                backgroundImage: MemoryImage(_pickedImage!))
                            // else if _pickedImage is null, display the profileImage
                            : profileImage.isNotEmpty
                                ? CircleAvatar(
                                    radius: 64,
                                    backgroundImage: NetworkImage(profileImage))
                                // else display the default profile image
                                : const CircleAvatar(
                                    radius: 64,
                                    backgroundImage: NetworkImage(
                                        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png'),
                                  ),
                        Positioned(
                            bottom: -10,
                            left: 80,
                            child: IconButton(
                                onPressed: () => _selectImage(context),
                                icon: const Icon(
                                  Icons.add_a_photo,
                                )))
                      ],
                    ),
                    const SizedBox(height: 20),
                    kIsWeb ? Text('Username: $username',
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)) : const SizedBox.shrink(),
                    const SizedBox(height: 20),     
                    Text('Email: $email', style: const TextStyle(fontSize: 16.0)),
                    const SizedBox(height: 20),
                    Text('Phone Number: $phoneNumber', style: const TextStyle(fontSize: 16.0)),
                    const SizedBox(height: 20),
                    Text('Full name: $fullName', style: const TextStyle(fontSize: 16.0)),
                    const SizedBox(height: 20),
                    currentUser?.userType != 'Staff' && currentUser?.userType != 'Admin' ? Text('Department: $department', style: const TextStyle(fontSize: 16.0)) : const SizedBox.shrink(),
                    const SizedBox(height: 20),
                    currentUser?.userType != 'Staff' && currentUser?.userType != 'Admin' ? Text('Year: $year', style: const TextStyle(fontSize: 16.0)) : const SizedBox.shrink(),
                    const SizedBox(height: 20),
                    currentUser?.userType != 'Staff' && currentUser?.userType != 'Admin' ? Text('Section: $section', style: const TextStyle(fontSize: 16.0)) : const SizedBox.shrink(),
                  !kIsWeb ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      onPressed: _signOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Sign out')),
                  ) : const SizedBox.shrink(),
                  ],
                ),
              ),
            ));
          }
        });
  }
}
