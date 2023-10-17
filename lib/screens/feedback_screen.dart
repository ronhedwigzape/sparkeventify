import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/resources/firestore_feedback_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/feedback_form.dart';
import 'package:student_event_calendar/widgets/feedback_summary_button.dart';
import '../providers/darkmode_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  FeedbackScreenState createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> {
  final Stream<Map<DateTime, List<Event>>> _events = FirestoreFeedbackMethods().getEventsWithFeedbackByDate();
  Set<Event> pastEvents = {};
  Event? selectedEvent;

  @override
  void initState() {
    super.initState();

    _events.listen((events) {
      // Clear previous state
      pastEvents.clear();

      DateTime now = DateTime.now();

      // Get past events
      events.forEach((eventDate, events) {
        if (eventDate.isBefore(now)) {
          pastEvents.addAll(events);  // Add all events of days in past
        } else if (eventDate.day == now.day) {
          for (var event in events) {
            if (event.endDate.isBefore(now)) {
              pastEvents.add(event);  // Add events that ended today
            }
          }
        }
      });

      // Convert the Set to a List for sorting
      List<Event> pastEventsList = pastEvents.toList();

      // Sort past events by date
      pastEventsList.sort((a, b) => b.startDate.compareTo(a.startDate));

      // Update the Set with the sorted List
      setState(() {
        pastEvents = pastEventsList.toSet();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    DateTime now = DateTime.now();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            children: [
              kIsWeb ? StreamBuilder<List<Event>>(
                stream: FirestoreFeedbackMethods().getEventsWithoutFeedback(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<Event> events = snapshot.data!;
                    selectedEvent = events.contains(selectedEvent) ? selectedEvent : null;
                    return Row(
                      children: [
                        const Flexible(child: Text('Select an event to add feedback: ')),
                        DropdownButton<Event>(
                          value: selectedEvent,
                          onChanged: (Event? newValue) {
                            setState(() {
                              selectedEvent = newValue;
                            });
                                            
                            if (selectedEvent != null) {
                              FirestoreFeedbackMethods().addEmptyFeedback(selectedEvent!.id);
                            }
                          },
                          items: events.map<DropdownMenuItem<Event>>((Event event) {
                            return DropdownMenuItem<Event>(
                              value: event,
                              child: Text(event.title),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }
                },
              ) : const SizedBox.shrink(),
              ...pastEvents.map((event) {
                DateTime endDate = event.endDate.isAfter(now) ? now.subtract(const Duration(days: 1)) : event.endDate;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Card( 
                    elevation: 1,
                    shadowColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Parallax image with opacity
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.6,
                            child:
                            (event.image?.isEmpty ?? true)
                            ? CachedNetworkImage(
                                imageUrl:
                                    'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    height: kIsWeb ? 250.0 : 100,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            color: darkModeOn
                                                ? darkModePrimaryColor
                                                : lightModePrimaryColor)),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : CachedNetworkImage(
                              imageUrl: event.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: SizedBox(
                                  height: kIsWeb ? 250.0 : 100,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: darkModeOn
                                              ? darkModePrimaryColor
                                              : lightModePrimaryColor)),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, black.withOpacity(0.6)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        // Event details
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: SizedBox(
                                    width: 100 * 6,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(event.title, style: const TextStyle(fontSize: 16, color: white, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis,),
                                        Text(
                                            (event.startDate.day == endDate.day
                                              ? '${DateFormat('MMM dd, yyyy').format(event.startDate)}\n'
                                              : '${DateFormat('MMM dd, yyyy').format(event.startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}\n')
                                              + (event.startTime.hour == event.endTime.hour && event.startTime.minute == event.endTime.minute
                                              ? DateFormat.jm().format(event.startTime)
                                              : '${DateFormat.jm().format(event.startTime)} - ${DateFormat.jm().format(event.endTime)}'),
                                          style: const TextStyle(
                                              height: 1.5,
                                              color: white,
                                              fontSize: 10,
                                          ),
                                        ),
                                        !kIsWeb ? FeedbackForm(eventId: event.id) : FeedbackSummaryButton(eventId: event.id)
                                      ],                        
                                    ),
                                  ),
                                ),
                              ),
                              // remove all event feedback
                              kIsWeb ? TextButton.icon(
                                onPressed: () async {
                                  await FirestoreFeedbackMethods().removeAllEventFeedbacks(event.id);
                                },
                                icon: const Icon(Icons.delete), 
                                label: const Text('Remove All Feedback')) : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
