import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/password_widget.dart';
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
  final TextEditingController yearController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  late String profileImage;
  final _formKey = GlobalKey<FormState>();
    final List<String> coursesAndDepartments = [
    'BSCS - CCS - Computer Science',
    'BSIT - CCS - Information Technology',
    'BSN - CHS - Nursing',
    'BSM - CHS - Midwifery',
    'BSME - CEA - Mechanical Engineering',
    'BSEE - CEA - Electrical Engineering',
    'BSCE - CEA - Computer Engineering',
  ];
  late String selectedCourseAndDepartment = coursesAndDepartments[0];
  late String course;
  late String department;

  @override
  void initState() {
    super.initState();
    userTypeController.text = widget.user.userType;
    firstNameController.text = widget.user.profile!.firstName ?? '';
    middleInitialController.text = widget.user.profile!.middleInitial?? '';
    lastNameController.text = widget.user.profile!.lastName?? '';
    phoneNumberController.text = widget.user.profile!.phoneNumber?? '';
    department = widget.user.profile!.department?? '';
    course = widget.user.profile!.course?? '';
    yearController.text = widget.user.profile!.year?? '';
    sectionController.text = widget.user.profile!.section?? '';
    positionController.text = widget.user.profile!.position?? '';
    organizationController.text = widget.user.profile!.organization?? '';
    profileImage = widget.user.profile!.profileImage ?? '';

    // Set the default value for the dropdown
    for (String courseAndDepartment in coursesAndDepartments) {
      List<String> splitValue = courseAndDepartment.split(' - ');
      if (splitValue[0] == course && splitValue[1] == department) {
        selectedCourseAndDepartment = courseAndDepartment;
        break;
      }
    }
  }

  updateUserDetails() async {
    String fullname = '${firstNameController.text} ${lastNameController.text}';

    model.Profile profile = model.Profile(
        fullName: fullname,
        firstName: firstNameController.text,
        middleInitial: middleInitialController.text,
        lastName: lastNameController.text,
        phoneNumber: phoneNumberController.text,
        department: department,
        course: course,
        year: yearController.text,
        section: sectionController.text,
        position: positionController.text,
        organization: organizationController.text,
        profileImage: profileImage);

    try {
      String response = await FireStoreUserMethods().updateUserProfile(
        uid: widget.user.uid,
        userType: userTypeController.text,
        email: widget.user.email,
        password: widget.user.password,
        deviceTokens: widget.user.deviceTokens,
        profile: profile);

      if (response == 'Success') {
        onUpdateSuccess();
      } else {
        onUpdateFailure(response);
      }
    } catch (e) {
      onUpdateFailure(e.toString());
    }
  }

  void onUpdateSuccess() {
    Navigator.pop(context);
    showSnackBar('User details updated successfully!', context);
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
                key: _formKey,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Form(
                      child: Column(
                        children: [
                          Text('Note: You can only edit the user\'s profile image in the user\'s profile page. ', 
                          style: TextStyle(
                            color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor),),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                  const Icon(Icons.email),
                                  const SizedBox(width: 10),
                                  Text(widget.user.email ?? 'No email found')
                                ]),
                              ),
                              PasswordWidget(password: widget.user.password ?? 'No password found')
                            ],
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_pin),
                              labelText: 'User Type',
                              border: OutlineInputBorder(
                              borderSide: Divider.createBorderSide(
                                context,
                                color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,)
                            ),
                            ),
                            value: userTypeController.text.isEmpty ? widget.user.userType : userTypeController.text,
                            items: <String>[
                              'Student',
                              'Officer',
                              'Staff'
                            ].map((String value) {
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
                                userTypeController.text = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFieldInput(
                            labelText: 'First Name',
                            textEditingController: firstNameController,
                            textInputType: TextInputType.text,
                            prefixIcon: const Icon(Icons.person),
                          ),
                          const SizedBox(height: 10),
                          TextFieldInput(
                            labelText: 'Middle Initial',
                            textEditingController: middleInitialController,
                            textInputType: TextInputType.text,
                            prefixIcon: const Icon(Icons.person),
                          ),
                          const SizedBox(height: 10),
                          TextFieldInput(
                            labelText: 'Last Name',
                            textEditingController: lastNameController,
                            textInputType: TextInputType.text,
                            prefixIcon: const Icon(Icons.person),
                          ),
                          const SizedBox(height: 10),
                          TextFieldInput(
                            labelText: 'Phone Number',
                            textEditingController: phoneNumberController,
                            textInputType: TextInputType.text,
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          widget.user.userType != 'Staff' ? const SizedBox(height: 10) : const SizedBox.shrink(),
                          widget.user.userType != 'Staff' ? 
                          DropdownButtonFormField<String>(
                          value: selectedCourseAndDepartment,
                          style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                          decoration: InputDecoration(
                            focusColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                            prefixIcon: const Icon(Icons.school),
                            labelText: 'Course and Department*',
                            border: OutlineInputBorder(
                              borderSide: Divider.createBorderSide(
                                context,
                                color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,)
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCourseAndDepartment = newValue ?? coursesAndDepartments[0]; // Handle null selection

                              // Split the selected value:
                              List<String> splitValue = selectedCourseAndDepartment.split(' - ');
                              course = splitValue[0];
                              department = splitValue[1];
                            });
                          },
                          items: coursesAndDepartments.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value.isEmpty ? null : value,
                              child: Text(value),
                            );
                          }).toList(),
                        ) : const SizedBox.shrink(),
                          widget.user.userType != 'Staff' ? const SizedBox(height: 10) : const SizedBox.shrink(),
                          widget.user.userType != 'Staff' ? TextFieldInput(
                            labelText: 'Year',
                            textEditingController: yearController,
                            textInputType: TextInputType.text,
                            prefixIcon: const Icon(Icons.school),
                          ) : const SizedBox.shrink(),
                          widget.user.userType != 'Staff' ? const SizedBox(height: 10) : const SizedBox.shrink(),
                          widget.user.userType != 'Staff' ? TextFieldInput(
                            labelText: 'Section',
                            textEditingController: sectionController,
                            textInputType: TextInputType.text,
                            prefixIcon: const Icon(Icons.school),
                          ) : const SizedBox.shrink(),
                          widget.user.userType != 'Student' ? const SizedBox(height: 10) : const SizedBox.shrink(),
                          widget.user.userType != 'Student' ? TextFieldInput(
                            labelText: 'Position',
                            textEditingController: positionController,
                            textInputType: TextInputType.text,
                            prefixIcon: const Icon(Icons.star_border),
                          ) : const SizedBox.shrink(),
                          const SizedBox(height: 10),
                          widget.user.userType == 'Officer' ? TextFieldInput(
                            labelText: 'Organization',
                            textEditingController: organizationController,
                            textInputType: TextInputType.text,
                            prefixIcon: const Icon(Icons.group),
                          ) : const SizedBox.shrink(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(Icons.cancel, color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
                                    label: Text('Cancel',
                                    style: TextStyle(
                                      color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),)),
                                ),
                                Flexible(
                                  child: TextButton.icon(
                                  onPressed: () async {
                                     try {
                                      await updateUserDetails();
                                    } catch (e) {
                                      if (kDebugMode) {
                                        print('Failed to update user details: $e');
                                      }
                                    }
                                  },
                                  icon: Icon(Icons.update, color: darkModeOn ? darkModeGrassColor : lightModeGrassColor),
                                  label: Text('Update', 
                                  style: TextStyle(
                                    color: darkModeOn ? darkModeGrassColor : lightModeGrassColor,
                                    fontWeight: FontWeight.bold),)),
                                ),
                              ],
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ), 
              ),
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
