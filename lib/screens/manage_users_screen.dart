import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_spinkit_fading_circle.dart';
import 'package:student_event_calendar/widgets/notification_button.dart';
import 'package:student_event_calendar/widgets/users_card.dart';
import 'package:student_event_calendar/utils/global.dart';
import '../models/user.dart' as model;
import '../providers/darkmode_provider.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  String? dropdownUserType;
  String? dropdownYear;
  String? dropdownDepartment;
  String? dropdownProgram;
  String? dropdownSection;
  String? dropdownDisabledStatus;
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
          (dropdownUserType == null || user.userType == dropdownUserType) &&
          (dropdownYear == null || user.profile?.year == dropdownYear) &&
          (dropdownDepartment == null || user.profile?.department == dropdownDepartment) &&
          (dropdownProgram == null || user.profile?.program == dropdownProgram) &&
          (dropdownSection == null || user.profile?.section == dropdownSection);
    }).toList();
    var filteredUserIds = filteredUsers.map((u) => u.uid).toSet();
    var selectedUserIds = selectedUsers.toSet();
    return selectedUserIds.containsAll(filteredUserIds);
  }

  void toggleAllSelected() {
    setState(() {
      List<String> allUserUids = filteredUsers.map((user) => user.uid!).toList();
      if (_allUsersSelected) {
        // If every user is already selected, clear the selection
        selectedUsers.clear();
      } else {
        // Otherwise, select every user
        selectedUsers = List.from(allUserUids);
      }
    });
  }

  void clearSelectedUsers() {
    setState(() {
      selectedUsers.clear();
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
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    final width = MediaQuery.of(context).size.width;
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CSPCSpinKitFadingCircle(isLogoVisible: false,),
              Text('Loading users...', style: TextStyle(color: darkModeOn ? lightColor : darkColor,))
            ],
          ));
        }

        allUsers = snapshot.data!.docs.map((doc) => model.User.fromSnap(doc)).toList();

        filteredUsers = allUsers.where((user) {
          bool matchesDisabledStatus = true;
          if (dropdownDisabledStatus == 'Enabled') {
            matchesDisabledStatus = !(user.disabled ?? false); 
          } else if (dropdownDisabledStatus == 'Disabled') {
            matchesDisabledStatus = user.disabled ?? false;
          }

          return matchesDisabledStatus && user.userType != 'Admin' &&
              (dropdownUserType == null || user.userType == dropdownUserType) &&
              (dropdownYear == null || user.profile?.year == dropdownYear) &&
              (dropdownDepartment == null || user.profile?.department == dropdownDepartment) &&
              (dropdownProgram == null || user.profile?.program == dropdownProgram) &&
              (dropdownSection == null || user.profile?.section == dropdownSection) &&
              (searchQuery.isEmpty || (user.profile?.fullName != null && user.profile!.fullName!.toLowerCase().startsWith(searchQuery.toLowerCase())));
        }).toList();


        return Padding(
          padding: const EdgeInsets.fromLTRB(13, 15, 13, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                    controller: searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      labelText: "Search for users",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 100),
                  child: Row(
                    children: [
                      Icon(
                        Icons.manage_accounts,
                        color: darkModeOn ? lightColor : darkColor,
                        size: 40,
                      ),
                      const SizedBox(width: 5,),
                      Text(
                        'Manage Users',
                        style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            color: darkModeOn ? lightColor : darkColor
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
                  child: SizedBox(
                    height: 50.0,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('Filtered by:', style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
                              const SizedBox(width: 10),
                              StreamBuilder<List<String>>(
                                stream: FireStoreUserMethods().getUniqueUserTypes(),  // Stream function
                                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) return const CSPCSpinKitFadingCircle(isLogoVisible: false,);
                                  if (!snapshot.hasData || snapshot.hasError) return const CSPCSpinKitFadingCircle(isLogoVisible: false); 
                                  return DropdownButton<String>(
                                    value: dropdownUserType,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownUserType = newValue!.trim();
                                      });
                                    },
                                    hint: const Text('User type'),
                                    items: <String>[...?snapshot.data]
                                        .where((String value) => value.trim().isNotEmpty)  // Filter out blank or empty strings
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value.trim(),  // Remove whitespaces
                                        child: Text(value.trim(), style: TextStyle(color: darkModeOn ? lightColor : darkColor,),),  // Remove whitespaces
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                          StreamBuilder<List<String>>(
                            stream: FireStoreUserMethods().getUniqueYears(),  // Stream function
                            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) return const CSPCSpinKitFadingCircle(isLogoVisible: false,);
                              if (!snapshot.hasData || snapshot.hasError) return const CSPCSpinKitFadingCircle(isLogoVisible: false); 
                              return DropdownButton<String>(
                                value: dropdownYear,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownYear = newValue!.trim();
                                  });
                                },
                                hint: const Text('Year level'),
                                items: <String>[...?snapshot.data]
                                    .where((String value) => value.trim().isNotEmpty)  // Filter out blank or empty strings
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value.trim(),  // Remove whitespaces
                                    child: Text(value.trim(), style: TextStyle(color: darkModeOn ? lightColor : darkColor,)),  // Remove whitespaces
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          StreamBuilder<List<String>>(
                            stream: FireStoreUserMethods().getUniqueDepartments(),  // Stream function
                            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) return const CSPCSpinKitFadingCircle(isLogoVisible: false,);
                              if (!snapshot.hasData || snapshot.hasError) return const CSPCSpinKitFadingCircle(isLogoVisible: false); 
                              return DropdownButton<String>(
                                value: dropdownDepartment,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownDepartment = newValue!.trim();
                                  });
                                },
                                hint: const Text('Departments'),
                                items: <String>[...?snapshot.data]
                                    .where((String value) => value.trim().isNotEmpty)  // Filter out blank or empty strings
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value.trim(),  // Remove whitespaces
                                    child: Text(value.trim(), style: TextStyle(color: darkModeOn ? lightColor : darkColor,)),  // Remove whitespaces
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          StreamBuilder<List<String>>(
                            stream: FireStoreUserMethods().getUniquePrograms(),  // Stream function
                            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) return const CSPCSpinKitFadingCircle(isLogoVisible: false,);
                              if (!snapshot.hasData || snapshot.hasError) return const CSPCSpinKitFadingCircle(isLogoVisible: false);
                              return DropdownButton<String>(
                                value: dropdownProgram,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownProgram = newValue!.trim();
                                  });
                                },
                                hint: const Text('Programs'),
                                items: <String>[...?snapshot.data]
                                    .where((String value) => value.trim().isNotEmpty)  // Filter out blank or empty strings
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value.trim(),  // Remove whitespaces
                                    child: Text(value.trim(), style: TextStyle(color: darkModeOn ? lightColor : darkColor,)),  // Remove whitespaces
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          StreamBuilder<List<String>>(
                            stream: FireStoreUserMethods().getUniqueSections(),  // Stream function
                            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) return const CSPCSpinKitFadingCircle(isLogoVisible: false,);
                              if (!snapshot.hasData || snapshot.hasError) return const CSPCSpinKitFadingCircle(isLogoVisible: false);
                              return DropdownButton<String>(
                                value: dropdownSection,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownSection = newValue!.trim();
                                  });
                                },
                                hint: const Text('Sections'),
                                items: <String>[...?snapshot.data]
                                    .where((String value) => value.trim().isNotEmpty)  // Filter out blank or empty strings
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value.trim(),  // Remove whitespaces
                                    child: Text(value.trim(), style: TextStyle(color: darkModeOn ? lightColor : darkColor,)),  // Remove whitespaces
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          DropdownButton<String>(
                            value: dropdownDisabledStatus,
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownDisabledStatus = newValue!;
                              });
                            },
                            hint: const Text('Visibility'),
                            items: <String>['Enabled', 'Disabled']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
                              );
                            }).toList(),
                          ),
                          NotificationButton(selectedUsers: selectedUsers, clearSelectedUsers: clearSelectedUsers),
                          Checkbox(
                            activeColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                            checkColor: darkModeOn ? darkColor : lightColor,
                            value: _allFilteredUsersSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                toggleAllSelected();
                              });
                            },
                          ),
                          ],
                        ),
                        
                        
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(100, 0, 100, 10),
                  child: Text(
                    'Instructions: In this section, you can view all users. To edit or delete a user, you must first select them. You can also notify users about events and announcements. This is where you can update and delete user account information.',
                    style: TextStyle(
                        fontSize: 15.0,
                        color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height > webScreenSize ? width * 0.33 : 0,
                  child: SingleChildScrollView(
                    child: Column(
                    children: snapshot.connectionState == ConnectionState.waiting
                    ? <Widget>[
                        const CSPCSpinKitFadingCircle(isLogoVisible: true),
                        Text('Loading users...', style: TextStyle(color: darkModeOn ? lightColor : darkColor,))
                    ] : filteredUsers.isEmpty ? <Widget>[
                        Center(child: Text('No user matches your search.', style: TextStyle(color: darkModeOn ? lightColor : darkColor,))),
                    ]
                    : filteredUsers.map((user) => Container(  // Otherwise, display the list of users
                      margin: EdgeInsets.symmetric(
                      horizontal: width > webScreenSize ? width * 0.08 : 0,
                      vertical: width > webScreenSize ? 7 : 0),
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
                        })
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
