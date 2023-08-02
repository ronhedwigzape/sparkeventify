import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart' as model;
import '../models/user.dart' as model;
import '../providers/darkmode_provider.dart';
import '../resources/firestore_user_methods.dart';
import '../utils/colors.dart';
import '../utils/file_pickers.dart';

class EventDialog extends StatefulWidget {
  final List<model.Event> selectedDayEvents;
  final DateTime adjustedSelectedDay;

  const EventDialog(this.selectedDayEvents, this.adjustedSelectedDay, {Key? key}) : super(key: key);

  @override
  EventDialogState createState() => EventDialogState();
}
class EventDialogState extends State<EventDialog> {

  String formatParticipants(Map<String, dynamic>? participants) {
    List<String> formattedList = [];
    participants?.removeWhere((key, value) => (value as List).isEmpty);
    participants?.forEach((key, value) {
      String formattedString = '${key[0].toUpperCase()}${key.substring(1)}: ${(value as List).join(', ')}';
      formattedList.add(formattedString);
    });
    return formattedList.join('\n');
  }


  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return AlertDialog(
      title: Center(
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: !kIsWeb ? 20 : 22,),
            const SizedBox(width: 10.0),
            Text('Events for ${DateFormat('MMMM dd, yyyy').format(widget.adjustedSelectedDay)}'),
          ],
        ),
      ),
      content: SizedBox(
        width: kIsWeb ? 500 : double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.selectedDayEvents.length,
          itemBuilder: (context, index) {
            var event = widget.selectedDayEvents[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat.jm().format(event.startTime),  // assuming time is a string
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: StreamBuilder<model.User>(
                          stream: FireStoreUserMethods().getUserDetailsByEventsCreatedBy(event.createdBy),  // assuming that this returns a Future<String>
                          builder: (BuildContext context, AsyncSnapshot<model.User> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('Fetching Data...');
                            } else {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Row(
                                  children: [
                                    const Icon(Icons.person, size: 15,),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Created by ${snapshot.data?.profile?.fullName}',
                                      style: const TextStyle(
                                          color: lightModeSecondaryColor,
                                          fontSize: 12
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 120,
                        child: Chip(
                          label: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Text(
                              event.type,
                              style: const TextStyle(color: lightColor, fontSize: 12),
                            ),
                          ),
                          backgroundColor: event.type == 'Academic' ? (darkModeOn ? darkModeMaroonColor : lightModeMaroonColor) : (darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  (event.image?.isEmpty ?? true)
                      ? CachedNetworkImage(
                    imageUrl: 'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                    width: double.infinity,
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        height: kIsWeb ? 250.0 : 100,
                        child: Center(child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor)),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                      : CachedNetworkImage(
                    imageUrl: event.image!,
                    width: double.infinity,
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        height: kIsWeb ? 250.0 : 100,
                        child: Center(child: CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor)),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  const SizedBox(height: 20.0),
                  Column(
                    children: [
                      event.document == null || event.document == '' ?
                      const SizedBox.shrink() :
                      TextButton.icon(
                          onPressed: () => downloadAndOpenFile(event.document ?? '', event.title),
                          icon: const Icon(Icons.download_for_offline),
                          label: Text('Open ${event.title} document')
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.description, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              event.description,
                              style: TextStyle(
                                color: darkModeOn ? lightColor : darkColor,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.supervised_user_circle_sharp, color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,),
                          const SizedBox(width: 10,),
                          Expanded(child: Text(formatParticipants(event.participants), style: TextStyle(fontSize: 15, color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor),)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0,)
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
