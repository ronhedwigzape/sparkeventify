import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/resources/global_methods.dart';

class ManageProgramDepartmentScreen extends StatefulWidget {
  const ManageProgramDepartmentScreen({super.key});

  @override
  State<ManageProgramDepartmentScreen> createState() => _ManageConstantsScreenState();
}

class _ManageConstantsScreenState extends State<ManageProgramDepartmentScreen> {
  final GlobalMethods globalMethods = GlobalMethods();
  final TextEditingController programController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController majorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Program and Departments'),
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
          List<String> programsAndDepartments = List<String>.from(constants['programsAndDepartments']);

          return Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: ListView.builder(
              itemCount: programsAndDepartments.length,
              itemBuilder: (context, index) {
                String programAndDepartment = programsAndDepartments[index];
                return ListTile(
                  title: Text(programAndDepartment),
                  onTap: () {
                    programController.text = programAndDepartment.split(' - ')[0];
                    departmentController.text = programAndDepartment.split(' - ')[1];
                    majorController.text = programAndDepartment.split(' - ')[2];
            
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Update Program and Department'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: programController,
                                decoration: const InputDecoration(labelText: 'Program'),
                              ),
                              TextField(
                                controller: departmentController,
                                decoration: const InputDecoration(labelText: 'Department'),
                              )
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              child: const Text('UPDATE'),
                              onPressed: () async {
                                bool success = await globalMethods.updateProgramAndDepartment(
                                  programAndDepartment.split(' - ')[0],
                                  programAndDepartment.split(' - ')[1],
                                  programAndDepartment.split(' - ')[2],
                                  programController.text,
                                  departmentController.text,
                                  majorController.text,
                                );
                                mounted ? ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(success ? 'Update successful' : 'Update failed')),
                                ) : '';
                                programController.clear();
                                departmentController.clear();
                                majorController.clear();
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
                  },
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
          majorController.clear();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Program and Department'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: programController,
                      decoration: const InputDecoration(labelText: 'Program'),
                    ),
                    TextField(
                      controller: departmentController,
                      decoration: const InputDecoration(labelText: 'Department'),
                    )
                  ],
                ),
                actions: [
                  ElevatedButton(
                    child: const Text('ADD'),
                    onPressed: () async {
                      // Add a new program and department
                      bool success = await globalMethods.insertProgramAndDepartment(
                        programController.text,
                        departmentController.text,
                        majorController.text,
                      );
                      
                      mounted ? ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Adding successful' : 'Adding failed')),
                      ) : '';

                      programController.clear();
                      departmentController.clear();
                      majorController.clear();
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
        },
      ),
    );
  }
}
