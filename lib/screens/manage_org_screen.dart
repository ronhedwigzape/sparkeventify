import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/resources/global_methods.dart';

class ManageOrganizationScreen extends StatefulWidget {
  const ManageOrganizationScreen({super.key});

  @override
  State<ManageOrganizationScreen> createState() => _ManageOrganizationScreenState();
}

class _ManageOrganizationScreenState extends State<ManageOrganizationScreen> {
  final GlobalMethods globalMethods = GlobalMethods();
  final TextEditingController organizationController = TextEditingController();

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

          if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }

          Map<String, dynamic> constants = snapshot.data!.data() as Map<String, dynamic>;
          List<String> organizations = List<String>.from(constants['organizations'] ?? []);

          return Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: ListView.builder(
              itemCount: organizations.length,
              itemBuilder: (context, index) {
                String organization = organizations[index];
                return ListTile(
                  title: Text(organization),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          organizationController.text = organization;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Update Organization'),
                                content: TextField(
                                  controller: organizationController,
                                  decoration: const InputDecoration(labelText: 'Organization Name'),
                                ),
                                actions: [
                                  ElevatedButton(
                                    child: const Text('UPDATE'),
                                    onPressed: () async {
                                      bool success = await globalMethods.updateOrganization(
                                        organization,
                                        organizationController.text,
                                      );
                                      if (success) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Update successful')),
                                        );
                                      } else {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Update failed')),
                                        );
                                      }
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('CANCEL'),
                                    onPressed: () {
                                      organizationController.clear();
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
                          bool success = await globalMethods.deleteOrganization(organization);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Organization deleted')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Delete failed')),
                            );
                          }
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
          organizationController.clear();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Organization'),
                content: TextField(
                  controller: organizationController,
                  decoration: const InputDecoration(labelText: 'Organization Name'),
                ),
                actions: [
                  ElevatedButton(
                    child: const Text('ADD'),
                    onPressed: () async {
                      if (organizationController.text.isNotEmpty) {
                        bool success = await globalMethods.insertOrganization(organizationController.text);
                        if (success) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Organization added')),
                          );
                        } else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Adding failed')),
                          );
                        }
                        organizationController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in the organization name')),
                        );
                      }
                    },
                  ),
                  TextButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      organizationController.clear();
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
