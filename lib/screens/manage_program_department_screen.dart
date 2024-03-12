import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/resources/global_methods.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

class ManageProgramDepartmentScreen extends StatefulWidget {
  const ManageProgramDepartmentScreen({super.key});

  @override
  State<ManageProgramDepartmentScreen> createState() => _ManageConstantsScreenState();
}

class _ManageConstantsScreenState extends State<ManageProgramDepartmentScreen> {
  final GlobalMethods globalMethods = GlobalMethods();
  final TextEditingController programController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController proponentController = TextEditingController(); // Added for proponent details if applicable

  void _addOrUpdateProgramAndDepartment({bool isUpdating = false, String? oldProgram, String? oldDepartment, String? oldOrganization, String? oldProponent}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isUpdating ? 'Update Program, Department, Organization/Proponent' : 'Add Program, Department, Organization/Proponent'),
          content: SingleChildScrollView( 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFieldInput(
                  textEditingController: programController,
                  labelText: 'Program',
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                TextFieldInput(
                  textEditingController: departmentController,
                  labelText: 'Department',
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                TextFieldInput(
                  textEditingController: organizationController,
                  labelText: 'Organization Name',
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                TextFieldInput(
                  textEditingController: proponentController,
                  labelText: 'Proponent (optional)',
                  textInputType: TextInputType.text,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('SUBMIT'),
              onPressed: () async {
                String organizationWithProponent = organizationController.text;
                if (proponentController.text.isNotEmpty) {
                  organizationWithProponent += ' - ${proponentController.text}'; // Concatenate proponent details if provided
                }

                if (isUpdating) {
                  bool success = await globalMethods.updateProgramDepartmentWithOrganization(
                    oldProgram!.trim(),
                    oldDepartment!.trim(),
                    programController.text.trim(),
                    departmentController.text.trim(),
                    oldOrganization!.trim(),
                    organizationWithProponent.trim(),
                    oldProponent: oldProponent!.trim(),
                    newProponent: proponentController.text.trim()
                  );
                  _showSnackBar(success ? 'Update successful' : 'Update failed');
                } else {
                  bool success = await globalMethods.insertProgramDepartmentWithOrganization(
                    programController.text.trim(),
                    departmentController.text.trim(),
                    organizationWithProponent.trim(),
                  );
                  _showSnackBar(success ? 'Insert successful' : 'Insert failed');
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDeletionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this item? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false), // Return false when cancellation
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true), // Return true when confirmation
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed
  }


  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Program, Departments, Organizations/Proponents'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: globalMethods.getConstantsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }

          Map<String, dynamic> constants = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> programsAndDepartmentsWithOrganizationArray = constants['programDepartmentWithOrganization'] ?? [];
          
          // Convert array to map for UI rendering
          Map<String, String> programsAndDepartmentsWithOrganization = {};
          for (var entry in programsAndDepartmentsWithOrganizationArray) {
            if (entry is Map) {
              String key = entry.keys.first;
              String value = entry[key];
              programsAndDepartmentsWithOrganization[key] = value;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: ListView.builder(
              itemCount: programsAndDepartmentsWithOrganization.length,
              itemBuilder: (context, index) {
                String key = programsAndDepartmentsWithOrganization.keys.elementAt(index);
                String value = programsAndDepartmentsWithOrganization[key]!;
                List<String> parts = value.split(' - ');
                String organization = parts[0];
                String proponent = parts.length > 1 ? parts[1] : '';

                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style, 
                      children: [
                        TextSpan(text: '$key '), 
                        const TextSpan(
                          text: ' | ', 
                          style: TextStyle(fontWeight: FontWeight.bold), // Makes the "|" bold
                        ),
                        TextSpan(text: ' $organization ${proponent.isNotEmpty ? '- $proponent' : ''}'), 
                      ],
                    ),
                  ),
                  onTap: () {
                    final parts = key.split(' - ');
                    programController.text = parts[0];
                    departmentController.text = parts[1];
                    organizationController.text = organization;
                    proponentController.text = proponent;
                    _addOrUpdateProgramAndDepartment(isUpdating: true, oldProgram: parts[0], oldDepartment: parts[1], oldOrganization: organization, oldProponent: proponent);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      // Confirm deletion with the user
                      bool confirmDelete = await _confirmDeletionDialog(context);
                      if (confirmDelete) {
                        final parts = key.split(' - ');
                        bool success = await globalMethods.deleteProgramDepartmentWithOrganization(parts[0], parts[1]);
                        _showSnackBar(success ? 'Deletion successful' : 'Deletion failed');
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          programController.clear();
          departmentController.clear();
          organizationController.clear();
          proponentController.clear(); // Clear proponent details as well
          _addOrUpdateProgramAndDepartment();
        },
      ),
    );
  }
}
