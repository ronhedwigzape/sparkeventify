import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/auth/login_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import '../providers/darkmode_provider.dart';
import '../resources/firestore_user_methods.dart';
import '../services/connectivity_service.dart';

class DeleteUserDialog extends StatefulWidget {
  const DeleteUserDialog({super.key, required this.uid, required this.email, required this.password});

  final String uid;
  final String email;
  final String password;

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {

  deleteUser() async {
    if (
      widget.uid.isEmpty ||
      widget.email.isEmpty ||
      widget.password.isEmpty
    ) return onDeleteFailure('Some error occurred.');

    String res = await FireStoreUserMethods().deleteUser(
        email: widget.email,
        password: widget.password,
        uid: widget.uid);

    if (res == 'Success') {
      onDeleteSuccess();
    } else {
      onDeleteFailure(res);
    }
  }

  void onDeleteSuccess() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
    mounted ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Account deleted successfully!'),
      duration: Duration(seconds: 2),
    )) : '';
  }

  void onDeleteFailure(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;

    return SimpleDialog(
      title: Row(
        children: [
          Icon(darkModeOn ? Icons.delete_forever : Icons.delete_forever,
            color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,),
          const SizedBox(width: 10),
          Text(
            'Delete your Account',
            style: TextStyle(
              color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor),
          ),
        ),
        SimpleDialogOption(
          padding: const EdgeInsets.all(20),
          onPressed:() async {
            bool isConnected = await ConnectivityService().isConnected();
            if (isConnected) {
              await deleteUser();
            } else {
              // Show a message to the user
              mounted ? ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [Icon(Icons.wifi_off, color: darkModeOn ? black : white),const SizedBox(width: 10,),const Flexible(child: Text('No internet connection. Please check your connection and try again.')),],),
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
}
