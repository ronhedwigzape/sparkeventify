import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/utils/colors.dart';
import '../providers/darkmode_provider.dart';

class OngoingEvents extends StatefulWidget {
  const OngoingEvents(this._events, {Key? key}) : super(key: key);

  final Map<DateTime, List<Event>> _events;

  @override
  OngoingEventsState createState() => OngoingEventsState();
}

class OngoingEventsState extends State<OngoingEvents> {
  Set<Event> ongoingEvents = {};
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Defined update function
    void update() {
      DateTime now = DateTime.now();
      TimeOfDay nowTime = TimeOfDay(hour: now.hour, minute: now.minute);

      // Clear the list of ongoing events
      ongoingEvents.clear();

      // Get ongoing events
      widget._events.forEach((eventDate, events) {
        for (var event in events) {
          DateTime startDate = DateTime(
            event.startDate.year,
            event.startDate.month,
            event.startDate.day,
          );

          DateTime endDate = DateTime(
            event.endDate.year,
            event.endDate.month,
            event.endDate.day,
          );


          TimeOfDay endTime = TimeOfDay(
            hour: event.endTime.hour,
            minute: event.endTime.minute,
          );

          if ((now.isAfter(startDate) || now.isAtSameMomentAs(startDate)) && (now.isBefore(endDate) || now.isAtSameMomentAs(endDate))) {
            if (!(now.isAtSameMomentAs(endDate) && (nowTime.hour > endTime.hour || (nowTime.hour == endTime.hour && nowTime.minute > endTime.minute)))) {
              ongoingEvents.add(event);  // Add all ongoing events
            }
          }
        }
      });
    }

    // Call update function every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) => update());

    // Call update function immediately on init
    update();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    String formatParticipants(Map<String, dynamic>? participants) {
      List<String> formattedList = [];
      participants?.removeWhere((key, value) => (value as List).isEmpty);
      participants?.forEach((key, value) {
        String formattedString =
            '${key[0].toUpperCase()}${key.substring(1)}: ${(value as List).join(', ')}';
        formattedList.add(formattedString);
      });
      return formattedList.join('\n');
    }

    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    DateTime now = DateTime.now();
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: kIsWeb ? 600 : double.infinity,
          child: Card(
            elevation: 2,
            color: darkModeOn ? darkColor : lightColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'Ongoing Events!',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  ...(ongoingEvents.isEmpty) ? [
                    const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No ongoing events for now..', textAlign: TextAlign.center,),
                  )]
                  : ongoingEvents.map((event) {
                  return Card(
                    elevation: 0,
                    color: darkModeOn ? darkColor : lightColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          (event.image?.isEmpty ?? true)
                            ? Container(
                              decoration: BoxDecoration(border: Border.all(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor)),
                              child: CachedNetworkImage(
                                  imageUrl:
                                      'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                                  width: 300,
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
                            )
                          : CachedNetworkImage(
                            imageUrl: event.image!,
                            width: 300,
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
                            ListTile(
                              title: Center(child: Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                              subtitle: Text(
                              'Date: ${DateFormat('MMM dd, yyyy').format(now)}\n'
                              '${event.startTime.hour == event.endTime.hour && event.startTime.minute == event.endTime.minute
                                  ? 'Time: ${DateFormat.jm().format(event.startTime)}'
                                  : 'Time: ${DateFormat.jm().format(event.startTime)} - ${DateFormat.jm().format(event.endTime)}'}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  height: 2,
                                  fontSize: 15
                              ),
                              ),
                            ),
                            Text('Venue: ${event.venue}', style: TextStyle(fontSize: 14, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor ),),
                            Column(
                            children: [
                            Text(
                              formatParticipants(event.participants),
                              style: TextStyle(fontSize: 14, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor ),
                            ),
                          ],
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
        ),
      ),
    );
  }
}
