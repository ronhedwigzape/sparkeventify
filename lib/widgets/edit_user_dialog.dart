import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/global.dart';
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
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController officerPositionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String selectedProgramAndDepartment = programsAndDepartments[0];
  late String selectedStaffPosition = staffPositions[0];
  late String profileImage;
  late String program;
  late String department;
  late String staffPosition;
  late String staffType;
  late String staffDescription;

  @override
  void initState() {
    super.initState();
    userTypeController.text = widget.user.userType;
    firstNameController.text = widget.user.profile!.firstName ?? '';
    middleInitialController.text = widget.user.profile!.middleInitial?? '';
    lastNameController.text = widget.user.profile!.lastName?? '';
    phoneNumberController.text = widget.user.profile!.phoneNumber?? '';
    department = widget.user.profile!.department?? '';
    program = widget.user.profile!.program?? '';
    yearController.text = widget.user.profile!.year?? '';
    sectionController.text = widget.user.profile!.section?? '';
    officerPositionController.text = widget.user.profile!.officerPosition?? '';
    organizationController.text = widget.user.profile!.organization?? '';
    profileImage = widget.user.profile!.profileImage ?? '';
    staffPosition = widget.user.profile!.staffPosition?? '';
    staffType = widget.user.profile!.staffType?? '';
    staffDescription = widget.user.profile!.staffDescription?? '';

    // Set the default value for the dropdown
    for (String programAndDepartment in programsAndDepartments) {
      List<String> splitValue = programAndDepartment.split(' - ');
      if (splitValue[0] == program && splitValue[1] == department) {
        selectedProgramAndDepartment = programAndDepartment;
        break;
      }
    }

    for (String staff in staffPositions) {
      List<String> splitValue = staff.split(' - ');
      if (splitValue[0] == staffPosition && splitValue[1] == staffType && splitValue[2] == staffDescription) {
        selectedStaffPosition = staff;
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
        department: widget.user.userType != 'Staff' ? department : '',
        program: widget.user.userType != 'Staff' ? program : '',
        year: widget.user.userType != 'Staff' ? yearController.text : '',
        section: widget.user.userType != 'Staff' ? sectionController.text : '',
        officerPosition: widget.user.userType == 'Officer' ? officerPositionController.text : '',
        staffPosition: widget.user.userType == 'Staff' ?  staffPosition : '',
        staffType: widget.user.userType == 'Staff' ? staffType : '',
        staffDescription: widget.user.userType == 'Staff' ? staffDescription : '',
        organization: widget.user.userType == 'Officer' ? organizationController.text : '',
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
    officerPositionController.dispose();
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
                              prefixIcon: const Icon(Icons.account_box),
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
                          value: selectedProgramAndDepartment,
                          style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                          decoration: InputDecoration(
                            focusColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                            prefixIcon: const Icon(Icons.school),
                            labelText: 'Program and Department*',
                            border: OutlineInputBorder(
                              borderSide: Divider.createBorderSide(
                                context,
                                color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,)
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedProgramAndDepartment = newValue ?? programsAndDepartments[0]; // Handle null selection

                              // Split the selected value:
                              List<String> splitValue = selectedProgramAndDepartment.split(' - ');
                              program = splitValue[0];
                              department = splitValue[1];
                            });
                          },
                          items: programsAndDepartments.map<DropdownMenuItem<String>>((String value) {
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
                          widget.user.userType == 'Officer' ? TextFieldInput(
                            labelText: 'Officer Position',
                            textEditingController: officerPositionController,
                            textInputType: TextInputType.text,
                            prefixIcon: const Icon(Icons.star_border),
                          ) : const SizedBox.shrink(),
                          widget.user.userType == 'Staff' ? 
                          DropdownButtonFormField<String>(
                            value: selectedStaffPosition,
                            style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                            decoration: InputDecoration(
                              focusColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                              prefixIcon: const Icon(Icons.school),
                              labelText: 'Staff Positions*',
                              border: OutlineInputBorder(
                                borderSide: Divider.createBorderSide(
                                  context,
                                  color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,)
                              ),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedStaffPosition = newValue ?? staffPositions[0]; // Handle null selection

                                // Split the selected value:
                                List<String> splitValue = selectedStaffPosition.split(' - ');
                                staffPosition = splitValue[0];
                                staffType = splitValue[1];
                                staffDescription = splitValue[2];
                              });
                            },
                            items: staffPositions.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value.isEmpty ? null : value,
                                child: Text(value),
                              );
                            }).toList(),
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
