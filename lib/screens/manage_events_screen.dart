import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:student_event_calendar/utils/global.dart';
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
  late TextEditingController _searchController;
  final _searchSubject = BehaviorSubject<String>();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchSubject.close();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search events', prefixIcon: Icon(Icons.search),),
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

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .orderBy('datePublished', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                Future<List<Event>> allEventsFutures = Future.wait(
                    snapshot.data!.docs.map((doc) => Event.fromSnap(doc)));

                return FutureBuilder(
                    future: allEventsFutures,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Event>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor));
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Something went wrong'));
                      }

                      List<Event> allEvents = snapshot.data!;
                      List<Event> filteredEvents = allEvents.where((event) {
                        return (dropdownEventType == 'All' ||
                            event.type == dropdownEventType);
                      }).toList();

                      List<Event> searchTermFilteredEvents =
                          filterEvents(filteredEvents, searchTerm);

                      if (searchTermFilteredEvents.isEmpty) {
                        return const Text('No events match your search.');
                      }

                      return Column(children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
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
                                        fontSize: kIsWeb ? 32.0 : 24.0,
                                        color: darkModeOn ? lightColor : darkColor,
                                        ),
                                      ),
                                    ],
                                  )),
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
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              )
                            ],
                          ),
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
                              shrinkWrap: true,
                              itemCount: searchTermFilteredEvents.length,
                              itemBuilder: (context, index) => Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          width > webScreenSize ? width * 0.2 : 0,
                                      vertical: width > webScreenSize ? 10 : 0),
                                  child: PostCard(
                                      snap: searchTermFilteredEvents[index]))),
                        )
                      ]);
                    });
              },
            );
          },
        ),
      ),
    );
  }
}
