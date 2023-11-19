import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:student_event_calendar/utils/global.dart';
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
  late TextEditingController _searchController;
  final _searchSubject = BehaviorSubject<String>();
  ScrollController _scrollController = ScrollController();

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
          .orderBy('datePublished', descending: true)
          .snapshots()
          .map((QuerySnapshot query) {
            return query.docs.map((doc) => Event.fromSnapStream(doc)).toList();
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
                return const Center(child: Text('Something went wrong'));
              } else if (!eventSnapshot.hasData || eventSnapshot.data!.isEmpty) {
                return const Center(child: Text('No events found.'));
              }

              List<Event> allEvents = eventSnapshot.data!;
              List<Event> filteredEvents = allEvents.where((event) {
                return (dropdownEventType == 'All' || event.type == dropdownEventType);
              }).toList();

              List<Event> searchTermFilteredEvents = filterEvents(filteredEvents, searchTerm);
              List<Event> eventsUserType = allEvents.where((event) => event.createdBy == 
              FirebaseAuth.instance.currentUser!.uid).toList();

              if (searchTermFilteredEvents.isEmpty) {
                return const Text('No events match your search.');
              }

              if (eventsUserType.isEmpty) {
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
                          const Flexible(
                            child: Text(
                            'You haven\'t made any events yet.',
                            textAlign: TextAlign.center,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ); 
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      !kIsWeb ? Expanded(
                        child: Text(
                        'Event Type',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 21.0,
                          color: darkModeOn ? lightColor : darkColor,
                        ),
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
