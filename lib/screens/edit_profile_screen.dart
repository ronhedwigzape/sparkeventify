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
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();


  late String selectedProgramAndDepartment = programsAndDepartments![0];
  late String selectedStaffPosition = staffPositions![0];
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
    fetchAndSetConstants();
    _emailController.text = widget.user.email!;
    _passwordController.text = widget.user.password!;
    _firstNameController.text = widget.user.profile!.firstName ?? '';
    _middleInitialController.text = widget.user.profile!.middleInitial?? '';
    _lastNameController.text = widget.user.profile!.lastName?? '';
    if (widget.user.profile!.phoneNumber!.length > 2) {
      _phoneNumberController.text = widget.user.profile!.phoneNumber!.substring(2);
    } else {
      _phoneNumberController.text = widget.user.profile!.phoneNumber!;
    }
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
    for (String programAndDepartment in programsAndDepartments!) {
      List<String> splitValue = programAndDepartment.split(' - ');
      if (splitValue[0] == program && splitValue[1] == department) {
        selectedProgramAndDepartment = programAndDepartment;
        break;
      }
    }

    for (String staff in staffPositions!) {
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
      _passwordController.text.trim().isEmpty ||
      _phoneNumberController.text.trim().isEmpty
    ) return onUpdateFailure('Please complete all required fields.');

      // Validate the phone number
    String phoneNumber = _phoneNumberController.text.trim();
    if (!RegExp(r'^9[0-9]{9}$').hasMatch(phoneNumber)) {
      onUpdateFailure('Please enter your last 10 digits of the phone number.');
      return;
    }

    // Check if the new passwords match
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      onUpdateFailure('New passwords do not match.');
      return;
    }

    // Check if the old password is correct by reauthenticating the user
    bool reauthResult = await FireStoreUserMethods().reauthenticateUser(
      widget.user.email!,
      _currentPasswordController.text.trim(),
    );

    if (!reauthResult) {
      onUpdateFailure('Current password is incorrect.');
      return;
    }

    // If the old password is correct and new passwords match, update the password
    if (reauthResult && _newPasswordController.text.isNotEmpty) {
      String passwordUpdateResponse = await FireStoreUserMethods().updateUserPassword(
        uid: widget.user.uid!,
        newPassword: _newPasswordController.text.trim(),
      );

      if (passwordUpdateResponse != 'Success') {
        onUpdateFailure(passwordUpdateResponse);
        return;
      }
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
      department: widget.user.userType != 'Staff' && widget.user.userType != 'Admin' ? department : '',
      program: widget.user.userType != 'Staff' && widget.user.userType != 'Admin' ? program : '',
      year: widget.user.userType != 'Staff' && widget.user.userType != 'Admin' ? _yearController.text.trim() : '',
      section: widget.user.userType != 'Staff' && widget.user.userType != 'Admin' ?  _sectionController.text.trim().toUpperCase() : '',
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
        userType: widget.user.userType!, 
        uid: widget.user.uid!,
        currentPassword: widget.user.password!);

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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit your profile',
            style: TextStyle(
              color: darkModeOn ? lightColor : darkColor,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit),
                const SizedBox(width: 10.0),
                Text("${widget.user.profile!.firstName ?? ''} ${widget.user.profile!.lastName ?? ''}",
                  style: TextStyle(
                    color: darkModeOn ? lightColor : darkColor,
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
                            await FireStoreUserMethods().updateProfileImage(_pickedImage!, widget.user.uid!); 
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
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '+63',
                        style: TextStyle(
                          color: darkModeOn ? lightColor : darkColor,
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
            // Old Password TextFieldInput
            TextFieldInput(
              prefixIcon: const Icon(Icons.lock_outline),
              textEditingController: _currentPasswordController,
              labelText: 'Current Password*',
              textInputType: TextInputType.visiblePassword,
              isPass: true,
            ),
            const SizedBox(height: 10.0),
            // New Password TextFieldInput
            TextFieldInput(
              prefixIcon: const Icon(Icons.lock),
              textEditingController: _newPasswordController,
              labelText: 'New Password*',
              textInputType: TextInputType.visiblePassword,
              isPass: true,
            ),
            const SizedBox(height: 10.0),
            // Confirm New Password TextFieldInput
            TextFieldInput(
              prefixIcon: const Icon(Icons.lock),
              textEditingController: _confirmNewPasswordController,
              labelText: 'Confirm New Password*',
              textInputType: TextInputType.visiblePassword,
              isPass: true,
            ),
            const SizedBox(height: 12.0),
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
                    ? Center(
                        child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                                darkModeOn ? darkColor : lightColor),
                      ))
                    : Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                      children: [
                        Icon(Icons.update_rounded, color: darkModeOn ? darkColor : lightColor),
                        const SizedBox(width: 10),
                        Text(
                            'Update Profile',
                            style: TextStyle(
                              color: darkModeOn ? darkColor : lightColor,
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
                          uid: widget.user.uid!,
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
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: darkModeOn ? darkColor : lightColor),
                        const SizedBox(width: 10),
                        Text(
                          'Delete Your Account',
                          style: TextStyle(
                            color: darkModeOn ? darkColor : lightColor,
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
      ),
    );
  }
}
