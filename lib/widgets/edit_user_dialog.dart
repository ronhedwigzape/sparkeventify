import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';

class EditUserDialog extends StatefulWidget {
  const EditUserDialog({super.key, required this.user});

  final model.User user;

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late String firstName,
      middleInitial,
      lastName,
      phoneNumber,
      department,
      course,
      year,
      section,
      position,
      organization,
      profileImage;

  @override
  void initState() {
    super.initState();
    firstName = widget.user.profile!.firstName ?? '';
    middleInitial = widget.user.profile!.middleInitial ?? '';
    lastName = widget.user.profile!.lastName ?? '';
    phoneNumber = widget.user.profile!.phoneNumber ?? '';
    department = widget.user.profile!.department ?? '';
    course = widget.user.profile!.course ?? '';
    year = widget.user.profile!.year ?? '';
    section = widget.user.profile!.section ?? '';
    position = widget.user.profile!.position ?? '';
    organization = widget.user.profile!.organization ?? '';
    profileImage = widget.user.profile!.profileImage?? 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png';
  }

  updateUserDetails() async {
    String fullname = '$firstName $lastName';
    
    model.Profile profile = model.Profile(
        fullName: fullname,
        firstName: firstName,
        middleInitial: middleInitial,
        lastName: lastName,
        phoneNumber: phoneNumber,
        department: department,
        course: course,
        year: year,
        section: section,
        position: position,
        organization: organization,
        profileImage: profileImage);

    String response = await FireStoreUserMethods().updateUserProfile(
        uid: widget.user.uid, 
        userType: widget.user.userType,
        email: widget.user.email,
        password: widget.user.password,
        profile: profile);

    if (response == 'Success') {
      onUpdateSuccess();
    } else {
      onUpdateFailure(response);
    }
  }

  void onUpdateSuccess() {
    Navigator.pop(context);
    showSnackBar('User details updated successfully', context);
  }

  void onUpdateFailure(String message) {
    showSnackBar(message, context);
  }

  void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return TextButton.icon(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: AlertDialog(
                    title: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 10),
                        Text(
                            'Edit ${widget.user.profile!.firstName}\'s profile'),
                      ],
                    ),
                    insetPadding: const EdgeInsets.symmetric(vertical: 80),
                    content: Form(
                      child: SingleChildScrollView(
                        child: Container(
                          child: Column(
                            children: [
                              // Repeat TextFormField modification for all fields
                              TextFormField(
                                initialValue: firstName,
                                decoration: const InputDecoration(
                                    labelText: 'First Name'),
                                validator: (value) {
                                  if (value!.isEmpty)
                                    return 'Please enter your first name';
                                  return null;
                                },
                                onSaved: (value) => firstName = value!,
                              ),
                              TextFormField(
                                initialValue: middleInitial,
                                decoration: const InputDecoration(
                                    labelText: 'Middle Initial'),
                                validator: (value) {
                                  if (value!.isEmpty)
                                    return 'Please enter your middle initial';
                                  return null;
                                },
                                onSaved: (value) => middleInitial = value!,
                              ),
                              TextFormField(
                                initialValue: lastName,
                                decoration: const InputDecoration(
                                    labelText: 'Last Name'),
                                validator: (value) {
                                  if (value!.isEmpty)
                                    return 'Please enter your last name';
                                  return null;
                                },
                                onSaved: (value) => lastName = value!,
                              ),
                              TextFormField(
                                initialValue: phoneNumber,
                                decoration: const InputDecoration(
                                    labelText: 'Phone Number'),
                                validator: (value) {
                                  if (value!.isEmpty)
                                    return 'Please enter your phone number';
                                  if (!RegExp(r"^639\d{9}$").hasMatch(value)) {
                                    return 'Please enter a valid phone number. (e.g. 639123456789)';
                                  }
                                  return null;
                                },
                                onSaved: (value) => phoneNumber = value!,
                              ),
                              widget.user.userType != 'Staff'
                                  ? TextFormField(
                                      initialValue: department,
                                      decoration: const InputDecoration(
                                          labelText: 'Department'),
                                      validator: (value) {
                                        if (value!.isEmpty)
                                          return 'Please enter your department';
                                        return null;
                                      },
                                      onSaved: (value) => department = value!,
                                    )
                                  : const SizedBox.shrink(),
                              widget.user.userType != 'Staff'
                                  ? TextFormField(
                                      initialValue: course,
                                      decoration: const InputDecoration(
                                          labelText: 'Course'),
                                      validator: (value) {
                                        if (value!.isEmpty)
                                          return 'Please enter your course';
                                        return null;
                                      },
                                      onSaved: (value) => course = value!,
                                    )
                                  : const SizedBox.shrink(),
                              widget.user.userType != 'Staff'
                                  ? TextFormField(
                                      initialValue: year,
                                      decoration: const InputDecoration(
                                          labelText: 'Year'),
                                      validator: (value) {
                                        if (value!.isEmpty)
                                          return 'Please enter your year';
                                        int? valueAsInt = int.tryParse(value);
                                        if (valueAsInt == null ||
                                            valueAsInt < 1 ||
                                            valueAsInt > 4) {
                                          return 'Please enter a valid year (1-4)';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => year = value!,
                                    )
                                  : const SizedBox.shrink(),
                              widget.user.userType != 'Staff'
                                  ? TextFormField(
                                      initialValue: section,
                                      decoration: const InputDecoration(
                                          labelText: 'Section'),
                                      validator: (value) {
                                        if (value!.isEmpty)
                                          return 'Please enter your section';
                                        if (!RegExp(r"^[A-Z]$")
                                            .hasMatch(value)) {
                                          return 'Please enter a valid section (A-Z)';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => section = value!,
                                    )
                                  : const SizedBox.shrink(),
                              widget.user.userType != 'Student'
                                  ? TextFormField(
                                      initialValue: position,
                                      decoration: const InputDecoration(
                                          labelText: 'Position'),
                                      validator: (value) {
                                        if (value!.isEmpty)
                                          return 'Please enter your position';
                                        return null;
                                      },
                                      onSaved: (value) => position = value!,
                                    )
                                  : const SizedBox.shrink(),
                              widget.user.userType == 'Officer'
                                  ? TextFormField(
                                      initialValue: organization,
                                      decoration: const InputDecoration(
                                          labelText: 'Organization'),
                                      validator: (value) {
                                        if (value!.isEmpty)
                                          return 'Please enter your organization';
                                        return null;
                                      },
                                      onSaved: (value) => organization = value!,
                                      maxLines: 1,
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () async {
                            await updateUserDetails();
                          },
                          child: const Text('Update')),
                    ],
                  ),
                ));
      },
      icon: Icon(
        Icons.edit,
        color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
      ),
      label: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          'Edit ${widget.user.profile!.firstName}\'s profile',
          style: TextStyle(
              color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
        ),
      ),
    );
  }
}
