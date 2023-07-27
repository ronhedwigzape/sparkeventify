import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/widgets/notification_button.dart';
import 'package:student_event_calendar/widgets/users_card.dart';
import 'package:student_event_calendar/utils/global.dart';
import '../models/user.dart' as model;

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  String dropdownUserType = 'All';
  String dropdownYear = 'All';
  String dropdownDepartment = 'All';
  String dropdownCourse = 'All';
  String dropdownSection = 'All';
  List<String> selectedUsers = [];
  List<model.User> allUsers = [];
  List<model.User> filteredUsers = [];
  String searchQuery = "";

  bool get _allUsersSelected => selectedUsers.length == filteredUsers.length;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen for changes in text field
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  bool get _allFilteredUsersSelected {
    List<model.User> filteredUsers = allUsers.where((user) {
      return user.userType != 'Admin' &&
          (dropdownUserType == 'All' || user.userType == dropdownUserType) &&
          (dropdownYear == 'All' || (user.profile?.year ?? 'All') == dropdownYear) &&
          (dropdownDepartment == 'All' || (user.profile?.department ?? 'All') == dropdownDepartment) &&
          (dropdownCourse == 'All' || (user.profile?.course ?? 'All') == dropdownCourse) &&
          (dropdownSection == 'All' || (user.profile?.section ?? 'All') == dropdownSection);
    }).toList();
    var filteredUserIds = filteredUsers.map((u) => u.uid).toSet();
    var selectedUserIds = selectedUsers.toSet();
    return selectedUserIds.containsAll(filteredUserIds);
  }

  void toggleAllSelected() {
    setState(() {
      List<String> allUserUids = filteredUsers.map((user) => user.uid).toList();
      if (_allUsersSelected) {
        // If every user is already selected, clear the selection
        selectedUsers.clear();
      } else {
        // Otherwise, select every user
        selectedUsers = List.from(allUserUids);
      }
    });
  }

  @override
  void dispose() {
    // Dispose when not needed
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        allUsers = snapshot.data!.docs.map((doc) => model.User.fromSnap(doc)).toList();

        filteredUsers = allUsers.where((user) {
          return user.userType != 'Admin' &&
              (dropdownUserType == 'All' || user.userType == dropdownUserType) &&
              (dropdownYear == 'All' || (user.profile?.year ?? 'All') == dropdownYear) &&
              (dropdownDepartment == 'All' || (user.profile?.department ?? 'All') == dropdownDepartment) &&
              (dropdownCourse == 'All' || (user.profile?.course ?? 'All') == dropdownCourse) &&
              (dropdownSection == 'All' || (user.profile?.section ?? 'All') == dropdownSection) &&
              (searchQuery.isEmpty || (user.profile?.fullName != null && user.profile!.fullName!.toLowerCase().startsWith(searchQuery.toLowerCase())));
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                    labelText: "Search for users",
                  ),
                ),
              ),
              Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: DropdownButton<String>(
                        value: dropdownUserType,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownUserType = newValue!;
                          });
                        },
                        items: <String>['All', 'Student', 'Officer', 'Staff']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Flexible(
                      child: DropdownButton<String>(
                        value: dropdownYear,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownYear = newValue!;
                          });
                        },
                        items: <String>['All', '1', '2', '3', '4']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Flexible(
                      child: DropdownButton<String>(
                        value: dropdownDepartment,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownDepartment = newValue!;
                          });
                        },
                        items: <String>['All', 'CCS', 'CHS']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Flexible(
                      child: DropdownButton<String>(
                        value: dropdownCourse,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownCourse = newValue!;
                          });
                        },
                        items: <String>['All', 'BSIT', 'BSN', 'BSCS']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Flexible(
                      child: DropdownButton<String>(
                        value: dropdownSection,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownSection = newValue!;
                          });
                        },
                        items: <String>['All', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    NotificationButton(selectedUsers: selectedUsers),
                    Checkbox(
                      value: _allFilteredUsersSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          toggleAllSelected();
                        });
                      },
                    ),
                  ],
                ),
              )),
              SizedBox(
                height: 550,
                child: SingleChildScrollView(
                  child: Column(
                  children: filteredUsers.map((user) => Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: width > webScreenSize ? width * 0.08 : 0,
                        vertical: width > webScreenSize ? 8 : 0),
                      child: UsersCard(
                        user: user,
                        selectedUsers: selectedUsers,
                        onSelectedChanged: (uid) {
                          setState(() {
                            if (selectedUsers.contains(uid)) {
                              selectedUsers.remove(uid);
                            } else {
                              selectedUsers.add(uid);
                            }
                          });
                        }
                      )
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
