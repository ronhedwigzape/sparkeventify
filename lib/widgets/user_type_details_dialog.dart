import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/profile.dart' as model;
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserTypeAndDetailsDialog extends StatefulWidget {
  final model.Profile? profile;

  const UserTypeAndDetailsDialog({
    Key? key,
    this.profile,
  }) : super(key: key);

  @override
  State<UserTypeAndDetailsDialog> createState() => _UserTypeAndDetailsDialogState();
}

class _UserTypeAndDetailsDialogState extends State<UserTypeAndDetailsDialog> {
  String? selectedUserType;
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _officerPositionController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  String? selectedProgramAndDepartment;
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing profile data if available
    if (widget.profile != null) {
      
      _programController.text = widget.profile?.program ?? '';
      _departmentController.text = widget.profile?.department ?? '';
      _yearController.text = widget.profile?.year ?? '';
      _sectionController.text = widget.profile?.section ?? '';
      _officerPositionController.text = widget.profile?.officerPosition ?? '';
      _organizationController.text = widget.profile?.organization ?? '';
      selectedProgramAndDepartment = '${widget.profile?.program} - ${widget.profile?.department}';
      selectedYear = widget.profile?.year;
    }
  }

  @override
  void dispose() {
    _programController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _sectionController.dispose();
    _officerPositionController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  List<Widget> _buildUserTypeFields() {
    List<Widget> fields = [
      TextFieldInput(
        textEditingController: _programController,
        labelText: 'Program*',
        textInputType: TextInputType.text,
        prefixIcon: const Icon(Icons.school),
      ),
      TextFieldInput(
        textEditingController: _departmentController,
        labelText: 'Department*',
        textInputType: TextInputType.text,
        prefixIcon: const Icon(Icons.account_balance),
      ),
      TextFieldInput(
        textEditingController: _yearController,
        labelText: 'Year*',
        textInputType: TextInputType.number,
        prefixIcon: const Icon(Icons.calendar_today),
      ),
      TextFieldInput(
        textEditingController: _sectionController,
        labelText: 'Section*',
        textInputType: TextInputType.text,
        prefixIcon: const Icon(Icons.group),
      ),
    ];

    if (selectedUserType == 'Officer') {
      fields.addAll([
        TextFieldInput(
          textEditingController: _officerPositionController,
          labelText: 'Officer Position*',
          textInputType: TextInputType.text,
          prefixIcon: const Icon(Icons.badge),
        ),
        TextFieldInput(
          textEditingController: _organizationController,
          labelText: 'Organization*',
          textInputType: TextInputType.text,
          prefixIcon: const Icon(Icons.business),
        ),
      ]);
    }

    return fields;
  }

  Future<void> _submitProfileDetails() async {
    // Perform input validation here
    // For example, check if the text fields are not empty
    if (_programController.text.isEmpty ||
        _departmentController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _sectionController.text.isEmpty ||
        (selectedUserType == 'Officer' &&
            (_officerPositionController.text.isEmpty || _organizationController.text.isEmpty))) {
      // Show an error message if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    // Call the updateUserProfileDetails method with the form field values
    String result = await FireStoreUserMethods().updateUserProfileDetails(
      uid: FirebaseAuth.instance.currentUser!.uid,
      userType: selectedUserType!,
      program: _programController.text,
      department: _departmentController.text,
      year: _yearController.text,
      section: _sectionController.text,
      officerPosition: selectedUserType == 'Officer' ? _officerPositionController.text : null,
      organization: selectedUserType == 'Officer' ? _organizationController.text : null,
    );

    // Handle the result of the profile update
    if (result == "Success") {
      // Close the dialog and show a success message
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      // Show an error message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 24),
          SizedBox(width: 8), // Spacing between icon and text
          Flexible(child: Text('Complete Your Profile')),
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: selectedUserType,
              hint: const Text('Select User Type'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedUserType = newValue;
                });
              },
              items: <String>['Student', 'Officer']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (selectedUserType != null) ..._buildUserTypeFields(),
          ],
        ),
      ),
      actions: <Widget>[
        if (selectedUserType != null)
          TextButton(
            child: const Text('Submit'),
            onPressed: () async {
              // Dismiss the keyboard if it's open
              FocusScope.of(context).unfocus();
              // Show a loading SnackBar
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text('Updating profile...'),
                      ],
                    ),
                  ),
                );
              // Call the submit profile details method
              await _submitProfileDetails();
              // Hide the loading SnackBar
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
      ],
    );
  }
}
