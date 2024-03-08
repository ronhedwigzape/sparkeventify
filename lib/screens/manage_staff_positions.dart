import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_event_calendar/resources/global_methods.dart';

class ManageStaffPositionsScreen extends StatefulWidget {
  const ManageStaffPositionsScreen({super.key});

  @override
  State<ManageStaffPositionsScreen> createState() => _ManageStaffPositionsScreenState();
}

class _ManageStaffPositionsScreenState extends State<ManageStaffPositionsScreen> {
  final GlobalMethods globalMethods = GlobalMethods();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Staff Positions'),
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
          List<String> staffPositions = List<String>.from(constants['staffPositions']);

          return ListView.builder(
            itemCount: staffPositions.length,
            itemBuilder: (context, index) {
              String staffPosition = staffPositions[index];
              return ListTile(
                title: Text(staffPosition),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    bool success = await globalMethods.emptyStaffPosition(staffPosition);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? 'Delete successful' : 'Delete failed')),
                    );
                  },
                ),
                onTap: () {
                  positionController.text = staffPosition.split(' - ')[0];
                  descriptionController.text = staffPosition.split(' - ')[1];
                  typeController.text = staffPosition.split(' - ')[2];

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Update Staff Position'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: positionController,
                              decoration: const InputDecoration(labelText: 'Position'),
                            ),
                            TextField(
                              controller: descriptionController,
                              decoration: const InputDecoration(labelText: 'Description'),
                            ),
                            TextField(
                              controller: typeController,
                              decoration: const InputDecoration(labelText: 'Type'),
                            ),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            child: const Text('UPDATE'),
                            onPressed: () async {
                              bool success = await globalMethods.updateStaffPosition(
                                staffPosition,
                                positionController.text,
                                descriptionController.text,
                                typeController.text,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(success ? 'Update successful' : 'Update failed')),
                              );
                              positionController.clear();
                              descriptionController.clear();
                              typeController.clear();
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          positionController.clear();
          descriptionController.clear();
          typeController.clear();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Staff Position'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: positionController,
                      decoration: const InputDecoration(labelText: 'Position'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    child: const Text('ADD'),
                    onPressed: () async {
                      bool success = await globalMethods.insertStaffPosition(
                        positionController.text,
                        descriptionController.text,
                        typeController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Insert successful' : 'Insert failed')),
                      );
                      positionController.clear();
                      descriptionController.clear();
                      typeController.clear();
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
