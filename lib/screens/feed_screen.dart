import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/utils/global.dart';
import 'package:student_event_calendar/widgets/post_card.dart';

import '../models/event.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key, this.snap}) : super(key: key);

  final snap;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String dropdownEventType = 'All';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          Future<List<Event>> allEventsFutures = Future.wait(
              snapshot.data!.docs.map((doc) => Event.fromSnap(doc)));

          return FutureBuilder(
              future: allEventsFutures,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                List<Event> allEvents = snapshot.data!;
                List<Event> filteredEvents = allEvents.where((event) {
                  return (dropdownEventType == 'All' ||
                      event.type == dropdownEventType);
                }).toList();

                return Column(
                  children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Flexible(child: Text('Feeds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),)),
                        Flexible(
                          child: DropdownButton<String>(
                            value: dropdownEventType,
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownEventType = newValue!;
                              });
                            },
                            items: <String>['All', 'Non-academic', 'Academic']
                                .map<DropdownMenuItem<String>>((String value) {
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
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) => Container(
                            margin: EdgeInsets.symmetric(
                                horizontal:
                                    width > webScreenSize ? width * 0.2 : 0,
                                vertical: width > webScreenSize ? 15 : 0),
                            child: PostCard(snap: filteredEvents[index]))),
                  )
                ]);
              });
        },
      ),
    );
  }
}
