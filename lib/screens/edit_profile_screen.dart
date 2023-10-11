import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/delete_user_dialog.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

import 'login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final model.User user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleInitialController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _officerPositionController = TextEditingController();

  late String selectedProgramAndDepartment = programsAndDepartments[0];
  late String selectedStaffPosition = staffPositions[0];
  late String program;
  late String department;
  late String profileImage;
  late String staffPosition;
  late String staffType;
  late String staffDescription;
  Uint8List? _pickedImage;
  bool _isImageUpdated = false;
  bool _isLoading = false;

  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.user.email!;
    _passwordController.text = widget.user.password!;
    _firstNameController.text = widget.user.profile!.firstName ?? '';
    _middleInitialController.text = widget.user.profile!.middleInitial?? '';
    _lastNameController.text = widget.user.profile!.lastName?? '';
    _phoneNumberController.text = widget.user.profile!.phoneNumber!.substring(2);
    department = widget.user.profile!.department?? '';
    program = widget.user.profile!.program?? '';
    _yearController.text = widget.user.profile!.year?? '';
    _sectionController.text = widget.user.profile!.section?? '';
    _officerPositionController.text = widget.user.profile!.officerPosition?? '';
    _organizationController.text = widget.user.profile!.organization?? '';
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

  update() async {
    setState(() {
      _isLoading = true;
    });

    if (
      _firstNameController.text.trim().isEmpty ||
      _middleInitialController.text.trim().isEmpty ||
      _lastNameController.text.trim().isEmpty ||
      _emailController.text.trim().isEmpty ||
      _passwordController.text.trim().isEmpty ||
      _phoneNumberController.text.trim().isEmpty
    ) return onUpdateFailure('Please complete all required fields.');

      // Validate the phone number
    String phoneNumber = _phoneNumberController.text.trim();
    if (!RegExp(r'^9[0-9]{9}$').hasMatch(phoneNumber)) {
      onUpdateFailure('Please enter your last 10 digits of the phone number.');
      return;
    }

    // Prepend '+63' to the phone number
    phoneNumber = '63$phoneNumber';

    String fullname = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    model.Profile profile = model.Profile(
      fullName: fullname,
      firstName: _firstNameController.text.trim(),
      middleInitial: _middleInitialController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: phoneNumber,
      department: widget.user.userType != 'Staff' ?  department : '',
      program: widget.user.userType != 'Staff' ? program : '',
      year: widget.user.userType != 'Staff' ? _yearController.text.trim() : '',
      section: widget.user.userType != 'Staff' ?  _sectionController.text.trim().toUpperCase() : '',
      organization: widget.user.userType == 'Officer' ?  _organizationController.text.trim() : '',
      officerPosition: widget.user.userType == 'Officer' ?  _officerPositionController.text.trim() : '',
      profileImage: profileImage,
      staffPosition: widget.user.userType == 'Staff' ? staffPosition : '',
      staffType: widget.user.userType == 'Staff' ? staffType : '',
      staffDescription: widget.user.userType == 'Staff' ? staffDescription : '',
    );

    String res = await FireStoreUserMethods().updateUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        profile: profile,
        userType: widget.user.userType, 
        uid: widget.user.uid);

    if (res == 'Success') {
      onUpdateSuccess();
    } else {
      onUpdateFailure(res);
    }
  }

  void onUpdateSuccess() {
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
    mounted ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Profile updated successfully!'),
      duration: Duration(seconds: 2),
    )) : '';
  }

  void onUpdateFailure(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  void selectImage() async {
    Uint8List image = await pickImage(ImageSource.gallery);
    setState(() {
      _pickedImage = image;
    });
  }

  void _showSuccessMessage() {
    Flushbar(
      message: "Profile image updated successfully!",
      duration: const Duration(seconds: 5),
    ).show(context);
  }

  @override
    void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _yearController.dispose();
    _sectionController.dispose();
    _organizationController.dispose();
    _officerPositionController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: darkModeOn ? white : black,
          ),
        ),
        backgroundColor: darkModeOn ? darkColor : lightColor,
        iconTheme: IconThemeData(
          color: darkModeOn ? white : black,
        ),
      ),
      body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20.0),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit),
              SizedBox(width: 10.0),
              Text('Edit your Profile',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                )),
            ],
          ),
          const SizedBox(height: 24.0),
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
                    icon: Icon(
                      Icons.add_a_photo,
                      color: darkModeOn ? white : black,
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
                        bool isConnected = await ConnectivityService().isConnected();
                        if (isConnected) {
                          await FireStoreUserMethods().updateProfileImage(_pickedImage!, widget.user.uid); 
                          setState(() {
                            _isImageUpdated = true;
                          });
                          _showSuccessMessage();
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
          const SizedBox(height: 20.0),
          Row(
            children: [
              // text field input for first name
              Expanded(
                child: TextFieldInput(
                  prefixIcon: const Icon(Icons.person),
                  textEditingController: _firstNameController,
                  labelText: 'First name*',
                  textInputType: TextInputType.text
                ),
              ),
          ]),
          const SizedBox(height: 10.0),
          Row(
            children: [
              // text field input for middle initial
              Expanded(
                child: TextFieldInput(
                  prefixIcon: const Icon(Icons.person),
                  textEditingController: _middleInitialController,
                  labelText: 'Middle Initial*',
                  textInputType: TextInputType.text
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              // text field input for last name
              Expanded(
                child: TextFieldInput(
                  prefixIcon: const Icon(Icons.person),
                  textEditingController: _lastNameController,
                  labelText: 'Last name*',
                  textInputType: TextInputType.text
                ),
              ),
            ]),
            const SizedBox(height: 10.0),
            // text field input for email
            Row(
            children: [
              Expanded(
                child: TextFieldInput(
                  prefixIcon: const Icon(Icons.email),
                  textEditingController: _emailController,
                  labelText: 'Email*',
                  textInputType: TextInputType.emailAddress
                ),
              )
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      '+63',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    Expanded(
                      child: TextFieldInput(
                        prefixIcon: const Icon(Icons.phone),
                        textEditingController: _phoneNumberController,
                        labelText: '9123456789*',
                        textInputType: TextInputType.phone
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          widget.user.userType != 'Staff' && 
          widget.user.userType != 'Admin'  ? Row(
            children: [
              Flexible(
                child: FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.school),
                        labelText: 'Program and Department*',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedProgramAndDepartment,
                          style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedProgramAndDepartment = newValue ?? programsAndDepartments[0]; // handle null selection

                              // split the selected value:
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
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ) : const SizedBox.shrink(),
          widget.user.userType != 'Staff' && 
          widget.user.userType != 'Admin'  ? const SizedBox(height: 10,) : const SizedBox.shrink(),
          widget.user.userType != 'Staff' && 
          widget.user.userType != 'Admin'  ? Row(
            children: [
              Flexible(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: Divider.createBorderSide(
                        context,
                        color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,)
                    ),
                    prefixIcon: const Icon(Icons.school),
                    labelText: 'Year*',
                  ),
                  value: _yearController.text.isEmpty
                      ? null
                      : _yearController.text,
                  items: <String>['1', '2', '3', '4']
                      .map((String value) {
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
                      _yearController.text = newValue!;
                    });
                  },
                )
              ),
              // text field for section
              const SizedBox(width: 10.0),
              Flexible(
                child: TextFieldInput(
                  prefixIcon: const Icon(Icons.school),
                  textEditingController: _sectionController,
                  labelText: 'Section (ex: A)*',
                  textInputType: TextInputType.text
                ),
              )
            ],
          ) : const SizedBox.shrink(),
          widget.user.userType != 'Staff' ? const SizedBox(height: 10.0) : const SizedBox.shrink(),
          widget.user.userType == 'Officer' ? TextFieldInput(
            prefixIcon: const Icon(Icons.group),
            textEditingController: _organizationController,
            labelText: 'Organization (e.g. JPCS Chapter)*',
            textInputType: TextInputType.text,
          ) : const SizedBox.shrink(),
          widget.user.userType == 'Officer' ? const SizedBox(height: 10.0) : const SizedBox.shrink(),
          // text field input for organization position
          widget.user.userType == 'Officer' ?  TextFieldInput(
            prefixIcon: const Icon(Icons.person_2),
            textEditingController: _officerPositionController,
            labelText: 'Organization position',
            textInputType: TextInputType.text,
          ) : const SizedBox.shrink(),
          widget.user.userType == 'Officer' ? const SizedBox(height: 10.0) : const SizedBox.shrink(),
          widget.user.userType == 'Staff' ? Row(
            children: [
              Flexible(
                child: FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_4),
                        labelText: 'Position*',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedStaffPosition,
                          style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedStaffPosition = newValue ?? staffPositions[0]; // handle null selection

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
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ) : const SizedBox.shrink(),
          widget.user.userType == 'Staff' ? const SizedBox(height: 10.0) : const SizedBox.shrink(),
          // text field input for password
          TextFieldInput(
            prefixIcon: const Icon(Icons.lock),
            textEditingController: _passwordController,
            labelText: 'Password*',
            textInputType: TextInputType.visiblePassword,
            isPass: true,
          ),
          const SizedBox(height: 12.0),
          const SizedBox(height: 10.0),
          Center(
            child: InkWell(
              onTap: () async {
                bool isConnected = await ConnectivityService().isConnected();
                if (isConnected) {
                  await update();
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
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0),
                decoration: ShapeDecoration(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(5.0)),
                  ),
                  color: darkModeOn ? darkModeGrassColor : lightModeGrassColor,
                ),
                child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                              lightColor),
                    ))
                  : const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                    children: [
                      Icon(Icons.update_rounded, color: lightColor),
                      SizedBox(width: 10),
                      Text(
                          'Update Profile',
                          style: TextStyle(
                            color: lightColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  )),
            ),
          ),
          const SizedBox(height: 10.0),
          Center(
            child: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return DeleteUserDialog(
                        uid: widget.user.uid,
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                    }
                );
              },
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0),
                  decoration: ShapeDecoration(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5.0)),
                    ),
                    color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,
                  ),
                  child: _isLoading
                      ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                            lightColor),
                      ))
                      : const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_forever, color: lightColor),
                      SizedBox(width: 10),
                      Text(
                        'Delete Your Account',
                        style: TextStyle(
                          color: lightColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),

        ),
      ),
    );
  }
}
