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
        title: Text('Manage Program and Departments'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: globalMethods.getConstantsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data'));
          }

          Map<String, dynamic> constants = snapshot.data!.data() as Map<String, dynamic>;
          List<String> programsAndDepartments = List<String>.from(constants['programsAndDepartments']);

          return ListView.builder(
            itemCount: programsAndDepartments.length,
            itemBuilder: (context, index) {
              String programAndDepartment = programsAndDepartments[index];
              return ListTile(
                title: Text(programAndDepartment),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    globalMethods.emptyProgramAndDepartment(
                      programAndDepartment.split(' - ')[0],
                      programAndDepartment.split(' - ')[1],
                      programAndDepartment.split(' - ')[2],
                    );
                  },
                ),
                onTap: () {
                  programController.text = programAndDepartment.split(' - ')[0];
                  departmentController.text = programAndDepartment.split(' - ')[1];
                  majorController.text = programAndDepartment.split(' - ')[2];

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Update Program and Department'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: programController,
                              decoration: InputDecoration(labelText: 'Program'),
                            ),
                            TextField(
                              controller: departmentController,
                              decoration: InputDecoration(labelText: 'Department'),
                            ),
                            TextField(
                              controller: majorController,
                              decoration: InputDecoration(labelText: 'Major'),
                            ),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            child: Text('UPDATE'),
                            onPressed: () {
                              globalMethods.updateProgramAndDepartment(
                                programAndDepartment.split(' - ')[0],
                                programAndDepartment.split(' - ')[1],
                                programAndDepartment.split(' - ')[2],
                                programController.text,
                                departmentController.text,
                                majorController.text,
                              );
                              programController.clear();
                              departmentController.clear();
                              majorController.clear();
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('CANCEL'),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          programController.clear();
          departmentController.clear();
          majorController.clear();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Program and Department'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: programController,
                      decoration: InputDecoration(labelText: 'Program'),
                    ),
                    TextField(
                      controller: departmentController,
                      decoration: InputDecoration(labelText: 'Department'),
                    ),
                    TextField(
                      controller: majorController,
                      decoration: InputDecoration(labelText: 'Major'),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    child: Text('ADD'),
                    onPressed: () {
                      globalMethods.insertProgramAndDepartment(
                        programController.text,
                        departmentController.text,
                        majorController.text,
                      );
                      programController.clear();
                      departmentController.clear();
                      majorController.clear();
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('CANCEL'),
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
