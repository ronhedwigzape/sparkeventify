import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

class EditUserDialog extends StatefulWidget {
  const EditUserDialog({super.key, required this.user});

  final model.User user;

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final TextEditingController userTypeController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleInitialController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  late String profileImage;

  @override
  void initState() {
    super.initState();
    userTypeController.text = widget.user.userType;
    firstNameController.text = widget.user.profile!.firstName ?? '';
    middleInitialController.text = widget.user.profile!.middleInitial?? '';
    lastNameController.text = widget.user.profile!.lastName?? '';
    phoneNumberController.text = widget.user.profile!.phoneNumber?? '';
    departmentController.text = widget.user.profile!.department?? '';
    courseController.text = widget.user.profile!.course?? '';
    yearController.text = widget.user.profile!.year?? '';
    sectionController.text = widget.user.profile!.section?? '';
    positionController.text = widget.user.profile!.position?? '';
    organizationController.text = widget.user.profile!.organization?? '';
    profileImage = widget.user.profile!.profileImage ?? '';
  }

  updateUserDetails() async {
    String fullname = '${firstNameController.text} ${lastNameController.text}';

    model.Profile profile = model.Profile(
        fullName: fullname,
        firstName: firstNameController.text,
        middleInitial: middleInitialController.text,
        lastName: lastNameController.text,
        phoneNumber: phoneNumberController.text,
        department: departmentController.text,
        course: courseController.text,
        year: yearController.text,
        section: sectionController.text,
        position: positionController.text,
        organization: organizationController.text,
        profileImage: profileImage);

    String response = await FireStoreUserMethods().updateUserProfile(
        uid: widget.user.uid,
        userType: userTypeController.text,
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
  void dispose() {
    userTypeController.dispose();
    firstNameController.dispose();
    middleInitialController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    departmentController.dispose();
    courseController.dispose();
    yearController.dispose();
    sectionController.dispose();
    positionController.dispose();
    organizationController.dispose();
    super.dispose();
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
                  Text('Edit ${widget.user.profile!.firstName}\'s profile'),
                ],
              ),
              insetPadding: const EdgeInsets.symmetric(vertical: 80),
              content: Form(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      children: [
                        Text('Note: This user will also be signed out after updating account details.', 
                        style: TextStyle(
                          color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor),),
                        const SizedBox(height: 20),
                        TextFieldInput(
                          labelText: 'User Type',
                          textEditingController: userTypeController, 
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter user type';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.account_box),
                        ),
                        const SizedBox(height: 10),
                        TextFieldInput(
                          labelText: 'First Name',
                          textEditingController: firstNameController,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.person),
                        ),
                        const SizedBox(height: 10),
                        TextFieldInput(
                          labelText: 'Middle Initial',
                          textEditingController: middleInitialController,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) return 'Please enter your section';
                            if (!RegExp(r"^[A-Z]$")
                                .hasMatch(value)) {
                              return 'Please enter your middle initial (A-Z)';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.person),
                        ),
                        const SizedBox(height: 10),
                        TextFieldInput(
                          labelText: 'Last Name',
                          textEditingController: lastNameController,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.person),
                        ),
                        const SizedBox(height: 10),
                        TextFieldInput(
                          labelText: 'Phone Number',
                          textEditingController: phoneNumberController,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) return 'Please enter your phone number';
                            if (!RegExp(r"^639\d{9}$").hasMatch(value)) return 'Please enter a valid phone number. (e.g. 639123456789)';
                            return null;
                          },
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        widget.user.userType != 'Staff' ? const SizedBox(height: 10) : const SizedBox.shrink(),
                        widget.user.userType != 'Staff' ? TextFieldInput(
                          labelText: 'Department',
                          textEditingController: departmentController,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter department';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.school),
                        ) : const SizedBox.shrink(),
                        widget.user.userType != 'Staff' ? const SizedBox(height: 10) : const SizedBox.shrink(),
                        widget.user.userType != 'Staff' ? TextFieldInput(
                          labelText: 'Course',
                          textEditingController: courseController,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter course';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.school),
                        ) : const SizedBox.shrink(),
                        widget.user.userType != 'Staff' ? const SizedBox(height: 10) : const SizedBox.shrink(),
                        widget.user.userType != 'Staff' ? TextFieldInput(
                          labelText: 'Year',
                          textEditingController: yearController,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) return 'Please enter your year';
                            if (int.tryParse(value) == null ||
                                int.tryParse(value)! < 1 ||
                                int.tryParse(value)! > 4) {
                              return 'Please enter a valid year (1-4)';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.school),
                        ) : const SizedBox.shrink(),
                        widget.user.userType != 'Staff' ? const SizedBox(height: 10) : const SizedBox.shrink(),
                        widget.user.userType != 'Staff' ? TextFieldInput(
                          labelText: 'Section',
                          textEditingController: sectionController,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) return 'Please enter your section';
                            if (!RegExp(r"^[A-Z]$").hasMatch(value)) {
                              return 'Please enter a valid section (A-Z)';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.school),
                        ) : const SizedBox.shrink(),
                        widget.user.userType != 'Student' ? const SizedBox(height: 10) : const SizedBox.shrink(),
                        widget.user.userType != 'Student' ? TextFieldInput(
                          labelText: 'Position',
                          textEditingController: positionController,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter position';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.star_border),
                        ) : const SizedBox.shrink(),
                        const SizedBox(height: 10),
                        widget.user.userType == 'Officer' ? TextFieldInput(
                          labelText: 'Organization',
                          textEditingController: organizationController,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter organization';
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.group),
                        ) : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.cancel, color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
                    label: Text('Cancel',
                    style: TextStyle(
                      color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                    onPressed: () async {
                      await updateUserDetails();
                    },
                    icon: Icon(Icons.update, color: darkModeOn ? darkModeGrassColor : lightModeGrassColor),
                    label: Text('Update', 
                    style: TextStyle(
                      color: darkModeOn ? darkModeGrassColor : lightModeGrassColor,
                      fontWeight: FontWeight.bold),)),
                ),
              ],
            ),
          )
        );
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
