import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/cspc_spinkit_fading_circle.dart';
import 'package:student_event_calendar/widgets/cspc_spinner.dart';
import 'package:student_event_calendar/widgets/post_card.dart';
import '../models/event.dart';
import '../providers/darkmode_provider.dart';
import '../utils/colors.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({Key? key, this.snap}) : super(key: key);

  final snap;

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  String dropdownEventType = 'All';
  String dropdownDepartment = 'All'; 
  late TextEditingController _searchController;
  final _searchSubject = BehaviorSubject<String>();
  final ScrollController _scrollController = ScrollController();
  final FireStoreUserMethods _fireStoreUserMethods = FireStoreUserMethods(); 

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  Stream<List<String>> getUniqueDepartmentsStream() {
    return _fireStoreUserMethods.getUniqueDepartments();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchSubject.close();
    _scrollController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (!_searchSubject.isClosed) {
      _searchSubject.add(_searchController.text);
    }
  }

  List<Event> filterEvents(List<Event> events, String searchTerm) {
    return events
        .where((event) =>
            event.title.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    final width = MediaQuery.of(context).size.width;

    Stream<List<Event>> getEventsStream() {
      return FirebaseFirestore.instance
          .collection('events')
          .where('approvalStatus', isEqualTo: 'approved')
          .orderBy('datePublished', descending: true)
          .snapshots()
          .map((QuerySnapshot query) {
            return query.docs.map((doc) => Event.fromSnapStream(doc)).toList();
          });
    }

    Stream<List<Event>> getPendingEventsStream() {
      return FirebaseFirestore.instance
          .collection('events')
          .where('approvalStatus', isEqualTo: 'pending')
          .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('datePublished', descending: true)
          .snapshots()
          .map((QuerySnapshot query) {
             List<Event> events = query.docs.map((doc) => Event.fromSnapStream(doc)).toList();
              print(events); // Add this line
              return events;
          });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TextField(
            style: TextStyle(color: darkModeOn ? lightColor : darkColor),
            controller: _searchController,
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Search events',
                  prefixIcon: Icon(
                    Icons.search,
                    color: darkModeOn ? lightColor : darkColor,
                    size: kIsWeb ? 24 : 25,),),
          ),
          titleSpacing: 0.0,
          toolbarHeight: 70,
          elevation: 0.0,
          backgroundColor: transparent,
        ),
        body: StreamBuilder<String>(
          stream: _searchSubject.stream.debounceTime(const Duration(milliseconds: 300)),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            String searchTerm = snapshot.data ?? '';

            return StreamBuilder<List<Event>>(
              stream: getEventsStream(),
              builder: (BuildContext context, AsyncSnapshot<List<Event>> eventSnapshot) {
              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CSPCFadeLoader());
              } else if (eventSnapshot.hasError) {
                print(eventSnapshot.error.toString());
                return Center(child: Text('Something went wrong', style: TextStyle(color: darkModeOn ? lightColor : darkColor),));
              } else if (!eventSnapshot.hasData || eventSnapshot.data!.isEmpty) {
                return StreamBuilder<List<Event>>(
                  stream: getPendingEventsStream(),
                  builder: (BuildContext context, AsyncSnapshot<List<Event>> pendingEventSnapshot) {
                    if (pendingEventSnapshot.hasData && pendingEventSnapshot.data!.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_busy, size: 25.0, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                    'You have an event pending approval.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ); 
                    } else {
                      return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy, size: 25.0, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                  'You haven\'t made any events yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ); 
                    }
                  },
                );
              }

              List<Event> allEvents = eventSnapshot.data!;
              List<Event> filteredEvents = allEvents.where((event) {
                return (dropdownEventType == 'All' || event.type == dropdownEventType);
              }).toList();

              // Filter events by department
              List<Event> departmentFilteredEvents = filteredEvents.where((event) {
                return (dropdownDepartment == 'All' || (event.participants != null && event.participants!['department'].contains(dropdownDepartment)));
              }).toList();

              List<Event> searchTermFilteredEvents = filterEvents(departmentFilteredEvents, searchTerm);
              List<Event> eventsUserType = allEvents.where((event) => event.createdBy == 
              FirebaseAuth.instance.currentUser!.uid).toList();

              if (searchTermFilteredEvents.isEmpty) {
                return const Text('No events match your search.');
              }

              if (eventsUserType.isEmpty) {
                return StreamBuilder<List<Event>>(
                  stream: getPendingEventsStream(),
                  builder: (BuildContext context, AsyncSnapshot<List<Event>> pendingEventSnapshot) {
                    if (pendingEventSnapshot.hasData && pendingEventSnapshot.data!.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_busy, size: 25.0, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                    'You have an event pending approval.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ); 
                    } else {
                      return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy, size: 25.0, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                  'You haven\'t made any events yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ); 
                    }
                  },
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                  child: Row(
                    mainAxisAlignment: kIsWeb 
                    ? MainAxisAlignment.center 
                    : MainAxisAlignment.spaceBetween,
                    children: [
                      kIsWeb ? Flexible(
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: darkModeOn ? lightColor : darkColor,
                              size: 40,
                            ),
                            const SizedBox(width: 10),
                            Text(
                          'Manage Events',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0,
                              color: darkModeOn ? lightColor : darkColor,
                              ),
                            ),
                          ],
                        )) : const SizedBox.shrink(),
                        Flexible(
                          child: DropdownButton<String>(
                            value: dropdownEventType,
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownEventType = newValue!;
                              });
                            },
                            items: <String>[
                              'All',
                              'Non-academic',
                              'Academic'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
                              );
                            }).toList(),
                          ),
                        ),
                        StreamBuilder<List<String>>(
                          stream: getUniqueDepartmentsStream(),
                          builder: (BuildContext context, AsyncSnapshot<List<String>> departmentSnapshot) {
                            if (!departmentSnapshot.hasData) {
                              return const CircularProgressIndicator();
                            }
                            if (departmentSnapshot.hasError) {
                              return const CSPCSpinKitFadingCircle();
                            }
                        
                            List<String> departments = departmentSnapshot.data!;
                            departments.insert(0, 'All');
                        
                            return Flexible(
                              child: SizedBox(
                                width: 140,
                                child: DropdownButton<String>(
                                  value: dropdownDepartment,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      dropdownDepartment = newValue!;
                                    });
                                  },
                                  items: departments.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value, style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        )
                    ],
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Instructions: In this section, all events can be viewed. You can update and delete the created events here.',
                    style: TextStyle(
                    fontSize: 15.0,
                    color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: searchTermFilteredEvents.length,
                      itemBuilder: (context, index) => Container(
                          key: ValueKey(searchTermFilteredEvents[index].id),
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  width > webScreenSize ? width * 0.2 : 0,
                              vertical: width > webScreenSize ? 10 : 0),
                          child: PostCard(
                              key: ValueKey(searchTermFilteredEvents[index].id),
                              snap: searchTermFilteredEvents[index]))),
                )
              ]);
            });
          },
        ),
      ),
    );
  }
}
