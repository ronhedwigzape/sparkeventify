import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/resources/global_methods.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

class ManageOrganizationScreen extends StatefulWidget {
  const ManageOrganizationScreen({Key? key}) : super(key: key);

  @override
  State<ManageOrganizationScreen> createState() => _ManageOrganizationScreenState();
}

class _ManageOrganizationScreenState extends State<ManageOrganizationScreen> {
  final GlobalMethods globalMethods = GlobalMethods();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController proponentController = TextEditingController();
  String? editingOrganization; // Used to store the organization name when editing
  String? editingProponent; // Used to store the proponent name when editing

  void clearControllers() {
    organizationController.clear();
    proponentController.clear();
    editingOrganization = null;
    editingProponent = null;
  }

  void setControllersForEdit(String organizationWithProponent) {
    var parts = organizationWithProponent.split(' - ');
    if (parts.length == 2) {
      editingOrganization = parts[0];
      editingProponent = parts[1];
      organizationController.text = editingOrganization!;
      proponentController.text = editingProponent!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Organizations'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: globalMethods.getConstantsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('No data'));
          }

          Map<String, dynamic> constants = snapshot.data!.data() as Map<String, dynamic>;
          List<String> organizations = List<String>.from(constants['organizations'] ?? []);

          return Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: ListView.builder(
              itemCount: organizations.length,
              itemBuilder: (context, index) {
                String organizationWithProponent = organizations[index];
                // var parts = organizationWithProponent.split(' - ');
                // String organization = parts[0];
                // String proponent = parts.length > 1 ? parts[1] : '';

                return ListTile(
                  title: Text(organizationWithProponent),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setControllersForEdit(organizationWithProponent);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Update Organization'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min, // To prevent AlertDialog from taking full height
                                  children: [
                                    TextFieldInput(
                                      textEditingController: organizationController,
                                      labelText: 'Organization Name',
                                      textInputType: TextInputType.text,
                                    ),
                                    const SizedBox(height: 10,),
                                    TextFieldInput(
                                      textEditingController: proponentController,
                                      labelText: 'Proponent',
                                      textInputType: TextInputType.text,
                                    ),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    child: const Text('UPDATE'),
                                    onPressed: () async {
                                      if (editingOrganization != null && editingProponent != null) {
                                        bool success = await globalMethods.updateOrganization(
                                          editingOrganization!,
                                          editingProponent!,
                                          // organizationController.text,
                                          // proponentController.text,
                                        );
                                        if (success) {
                                          clearControllers();
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Update successful')),
                                          );
                                        } else {
                                          clearControllers();
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Update failed')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('CANCEL'),
                                    onPressed: () {
                                      clearControllers();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          // bool success = await globalMethods.deleteOrganization(organization, proponent);
                          // if (success) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(content: Text('Organization deleted')),
                          //   );
                          // } else {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(content: Text('Delete failed')),
                          //   );
                          // }
                        },
                      ),
                    ],
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
          clearControllers();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Organization/Proponent'),
                content: Column(
                  mainAxisSize: MainAxisSize.min, // To prevent AlertDialog from taking full height
                  children: [
                    TextFieldInput(
                      textEditingController: organizationController,
                      labelText: 'Organization Name',
                      textInputType: TextInputType.text,
                    ),
                    const SizedBox(height: 10,),
                    TextFieldInput(
                      textEditingController: proponentController,
                      labelText: 'Proponent',
                      textInputType: TextInputType.text,
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    child: const Text('ADD'),
                    onPressed: () async {
                      bool success = await globalMethods.insertOrganization(
                        organizationController.text,
                        // proponentController.text,
                      );
                      if (success) {
                        clearControllers();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Organization added')),
                        );
                      } else {
                        clearControllers();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Adding failed')),
                        );
                      }
                    },
                  ),
                  TextButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      clearControllers();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
