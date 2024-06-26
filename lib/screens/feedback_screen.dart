import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/resources/firestore_feedback_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/screens/event_feedback_screen.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_background.dart';
import 'package:student_event_calendar/widgets/cspc_spinkit_fading_circle.dart';
import 'package:student_event_calendar/widgets/feedback_form.dart';
import 'package:student_event_calendar/widgets/feedback_summary_button.dart';
import '../providers/darkmode_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  FeedbackScreenState createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> {
  List<Event> pastEvents = [];
  Event? selectedEvent;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final FireStoreUserMethods _userMethods = FireStoreUserMethods();

  @override
  void initState() {
    super.initState();
    _userMethods.getCurrentUserDataStream().listen((user) {
      String? department = user?.profile?.department;
      final Stream<Map<DateTime, List<Event>>> events = kIsWeb ? FirestoreFeedbackMethods().getEventsWithFeedbackByDate() : FirestoreFeedbackMethods().getEventsWithFeedbackByDateByDepartment(department!);
      _updatePastEvents(events);
    });
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    _userMethods.getCurrentUserDataStream().listen((user) {
      String? department = user?.profile?.department;
      final Stream<Map<DateTime, List<Event>>> events = kIsWeb ? FirestoreFeedbackMethods().getEventsWithFeedbackByDate() : FirestoreFeedbackMethods().getEventsWithFeedbackByDateByDepartment(department!);
      _updatePastEvents(events);
    });
  }

  void _updatePastEvents(Stream<Map<DateTime, List<Event>>> eventsStream) {
    eventsStream.listen((events) {
      // Clear previous state
      pastEvents.clear();

      DateTime now = DateTime.now();

      // Get past events
      events.forEach((eventDate, events) {
        if (eventDate.isBefore(now)) {
          pastEvents.addAll(events);  // Add all events of days in past
        } else if (eventDate.day == now.day) {
          for (var event in events) {
            if (event.endDate!.isBefore(now)) {
              pastEvents.add(event);  // Add events that ended today
            }
          }
        }
      });

      // Sort past events by date
      pastEvents.sort((a, b) => b.startDate!.compareTo(a.startDate!));

      // Update the state with the sorted List
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    DateTime now = DateTime.now();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CSPCBackground(height: MediaQuery.of(context).size.height),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  darkModeOn ? darkColor.withOpacity(0.0) : lightColor.withOpacity(0.0),
                  darkModeOn ? darkColor : lightColor,
                ],
                stops: const [
                  0.0,
                  1.0
                ]
              ),
            ),
          ),
          SmartRefresher(
            enablePullDown: true,
            header: const WaterDropHeader(),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'Select an event to add feedback: '.toUpperCase(), 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: darkModeOn ? lightColor : darkColor
                                    ),)),
                              Expanded(
                                child: DropdownButton<Event>(
                                  isExpanded: true,
                                  value: selectedEvent,
                                  onChanged: (Event? newValue) {
                                    setState(() {
                                      selectedEvent = newValue;
                                    });
                                                    
                                    if (selectedEvent != null) {
                                      FirestoreFeedbackMethods().addEmptyFeedback(selectedEvent!.id!);
                                    }
                                  },
                                  items: events.map<DropdownMenuItem<Event>>((Event event) {
                                    return DropdownMenuItem<Event>(
                                      value: event,
                                      child: Text(event.title!, style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ) : const SizedBox.shrink(),
                    ...pastEvents.map((event) {
                      DateTime endDate = event.endDate!.isAfter(now) ? now.subtract(const Duration(days: 1)) : event.endDate!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: InkWell(
                          onTap: kIsWeb ? () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => EventFeedbackScreen(eventId: event.id!)
                            ));
                          } : () {},
                          child: Card( 
                            elevation: 1,
                            shadowColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
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
                                        placeholder: (context, url) => const Center(
                                          child: SizedBox(
                                            height: kIsWeb ? 250.0 : 100,
                                            child: Center(child: CSPCSpinKitFadingCircle(isLogoVisible: false,)),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      )
                                    : CachedNetworkImage(
                                      imageUrl: event.image!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: SizedBox(
                                          height: kIsWeb ? 250.0 : 100,
                                          child: Center(
                                              child: CSPCSpinKitFadingCircle(isLogoVisible: false)),
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
                                        colors: [transparent, black.withOpacity(0.6)],
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
                                                Text(event.title!, style: const TextStyle(fontSize: 16, color: white, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis,),
                                                Text(
                                                    (event.startDate!.day == endDate.day
                                                      ? '${DateFormat('MMM dd, yyyy').format(event.startDate!)}\n'
                                                      : '${DateFormat('MMM dd, yyyy').format(event.startDate!)} - ${DateFormat('MMM dd, yyyy').format(endDate)}\n')
                                                      + (event.startTime!.hour == event.endTime!.hour && event.startTime!.minute == event.endTime!.minute
                                                      ? DateFormat.jm().format(event.startTime!)
                                                      : '${DateFormat.jm().format(event.startTime!)} - ${DateFormat.jm().format(event.endTime!)}'),
                                                  style: const TextStyle(
                                                      height: 1.5,
                                                      color: white,
                                                      fontSize: 10,
                                                  ),
                                                ),
                                                !kIsWeb ? FeedbackForm(eventId: event.id!) : FeedbackSummaryButton(eventId: event.id!)
                                              ],                        
                                            ),
                                          ),
                                        ),
                                      ),
                                      // remove all event feedback
                                      kIsWeb ? TextButton.icon(
                                        onPressed: () async {
                                          await FirestoreFeedbackMethods().removeAllEventFeedbacks(event.id!);
                                        },
                                        icon: Icon(Icons.delete_forever_rounded, color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,), 
                                        label: Text('Remove All Feedback', style: TextStyle(color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),)) : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
