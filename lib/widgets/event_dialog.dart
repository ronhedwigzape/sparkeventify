import 'package:another_flushbar/flushbar.dart';
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
import 'package:timezone/timezone.dart' as tz;

class EventDialog extends StatefulWidget {
  final List<model.Event> selectedDayEvents;
  final DateTime adjustedSelectedDay;

  const EventDialog(this.selectedDayEvents, this.adjustedSelectedDay,
      {Key? key})
      : super(key: key);

  @override
  EventDialogState createState() => EventDialogState();
}

class EventDialogState extends State<EventDialog> {

  void _showOpenDocumentMessage() {
    Flushbar(
      message: "Please wait for the document to be accessed...",
      duration: const Duration(seconds: 6),
    ).show(context);
  }

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

  @override
  Widget build(BuildContext context) {
    
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return AlertDialog(
      title: Center(
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: !kIsWeb ? 20 : 22,
            ),
            const SizedBox(width: 10.0),
            kIsWeb
                ? Text(
                    '${widget.selectedDayEvents.length > 1 ? 'Events' : 'Event'} for ${DateFormat('MMMM dd, yyyy').format(widget.adjustedSelectedDay)}',
                    style: const TextStyle(fontSize: 26))
                : Text(
                    DateFormat('MMMM dd, yyyy')
                        .format(widget.adjustedSelectedDay),
                    style: const TextStyle(fontSize: 18),
                  ),
          ],
        ),
      ),
      content: SizedBox(
        width: kIsWeb ? 500 : double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.selectedDayEvents.length,
          itemBuilder: (context, index) {
            // Initialize the event, local time, and location
            var event = widget.selectedDayEvents[index];
            final manila = tz.getLocation('Asia/Manila');
            final localTime = tz.TZDateTime.from(event.datePublished!, manila);

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
                              fontSize: kIsWeb ? 24 : 22.0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Text(
                            DateFormat.jm().format(event.startTime), 
                            style: TextStyle(
                              color: darkModeOn ? lightColor : darkColor,
                              fontSize: kIsWeb ? 18 : 13
                            ),
                          ),
                          Text(
                            DateFormat.jm().format(event.endTime), 
                            style: TextStyle(
                              color: darkModeOn ? lightColor : darkColor,
                              fontSize: kIsWeb ? 18 : 13
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: StreamBuilder<model.User>(
                          stream: FireStoreUserMethods()
                              .getUserDetailsByEventsCreatedBy(event
                                  .createdBy), 
                          builder: (BuildContext context,
                              AsyncSnapshot<model.User> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Fetching Data...');
                            } else {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          size: 15,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${snapshot.data?.profile?.fullName}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: darkModeOn
                                            ? darkModeSecondaryColor
                                            : lightModeSecondaryColor,
                                              fontSize: 13.5),
                                        ),
                                      ],
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: DateFormat.yMMMd().format(localTime),
                                            style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: lightModeSecondaryColor,
                                                fontSize: 11,
                                              ),
                                          ),
                                          const TextSpan( text: " "),
                                          TextSpan(
                                            text: DateFormat.jm().format(localTime),
                                            style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: lightModeSecondaryColor,
                                                fontSize: 11
                                              ),
                                          ),              
                                        ],
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
                        height: 30,
                        width: kIsWeb
                            ? (event.type == 'Academic' ? 80 : 100)
                            : (event.type == 'Academic' ? 60 : 80),
                        child: Chip(
                          label: Text(
                            event.type,
                            style: const TextStyle(
                                color: lightColor, fontSize: kIsWeb ? 12 : 8),
                          ),
                          padding: const EdgeInsets.all(2.0),
                          backgroundColor: event.type == 'Academic'
                              ? (darkModeOn
                                  ? darkModeMaroonColor
                                  : lightModeMaroonColor)
                              : (darkModeOn
                                  ? darkModePrimaryColor
                                  : lightModePrimaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  (event.image?.isEmpty ?? true)
                      ? CachedNetworkImage(
                          imageUrl:
                              'https://cspc.edu.ph/wp-content/uploads/2022/03/cspc-blue-2-scaled.jpg',
                          width: double.infinity,
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
                          width: double.infinity,
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
                  const SizedBox(height: 20.0),
                  event.document == null || event.document == ''
                      ? const SizedBox.shrink()
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: () { 
                                downloadAndOpenFile(event.document ?? '', event.title);
                                _showOpenDocumentMessage();
                              },
                              icon: const Icon(Icons.download_for_offline),
                              label: const Text('Open document',)),
                          ],
                        ),
                  event.document == null || event.document == ''
                      ? const SizedBox.shrink()
                      : const SizedBox(height: 20.0),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: darkModeOn
                                ? darkModeSecondaryColor
                                : lightModeSecondaryColor,
                            size: kIsWeb ? 18 : 15,
                          ),
                          Text(
                            ' Description',
                            style: TextStyle(
                                color: darkModeOn ? lightColor : darkColor,
                                fontSize: kIsWeb ? 18 : 15),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        event.description,
                        style: TextStyle(
                          color: darkModeOn
                              ? darkModeSecondaryColor
                              : lightModeSecondaryColor,
                          fontSize: kIsWeb ? 16.0 : 13,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Icon(
                        Icons.supervised_user_circle_sharp,
                        color: darkModeOn
                            ? darkModeSecondaryColor
                            : lightModeSecondaryColor,
                        size: kIsWeb ? 18 : 15,
                      ),
                      Text(
                        ' Participants',
                        style: TextStyle(
                            color: darkModeOn ? lightColor : darkColor,
                            fontSize: kIsWeb ? 18 : 15),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Column(
                    children: [
                      Text(
                        formatParticipants(event.participants),
                        style: TextStyle(
                            fontSize: kIsWeb ? 16.0 : 13,
                            color: darkModeOn
                                ? darkModeTertiaryColor
                                : lightModeTertiaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  )
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
