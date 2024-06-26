import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart' as model;
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/widgets/cspc_spinkit_fading_circle.dart';
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
                    style: TextStyle(fontSize: 26, color: darkModeOn ? lightColor : darkColor))
                : Text(
                    DateFormat('MMMM dd, yyyy')
                        .format(widget.adjustedSelectedDay),
                    style: TextStyle(fontSize: 18, color: darkModeOn ? lightColor : darkColor),
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

            return StreamBuilder<model.User?>(
                stream: FireStoreUserMethods().getCurrentUserDataStream(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CSPCSpinKitFadingCircle());
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: CSPCSpinKitFadingCircle());
                  }
                  
                  final user = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title!,
                                style: TextStyle(
                                    color: darkModeOn ? lightColor : darkColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: kIsWeb ? 24 : 22.0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                Text(
                                  DateFormat.jm().format(event.startTime!),
                                  style: TextStyle(
                                      color:
                                          darkModeOn ? lightColor : darkColor,
                                      fontSize: kIsWeb ? 18 : 13),
                                ),
                                Text(
                                  DateFormat.jm().format(event.endTime!),
                                  style: TextStyle(
                                      color:
                                          darkModeOn ? lightColor : darkColor,
                                      fontSize: kIsWeb ? 18 : 13),
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
                                    .getUserDetailsByEventsCreatedBy(
                                        event.createdBy!),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 15,
                                              ),
                                              const SizedBox(width: 5),
                                              Flexible(
                                                child: Text(
                                                  '${snapshot.data?.profile?.fullName}',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: darkModeOn
                                                          ? darkModeSecondaryColor
                                                          : lightModeSecondaryColor,
                                                      fontSize: 13.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: DateFormat.yMMMd()
                                                      .format(localTime),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        color:
                                                            lightModeSecondaryColor,
                                                        fontSize: 11,
                                                      ),
                                                ),
                                                const TextSpan(text: " "),
                                                TextSpan(
                                                  text: DateFormat.jm()
                                                      .format(localTime),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          color:
                                                              lightModeSecondaryColor,
                                                          fontSize: 11),
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
                              child: InkWell(
                                onTap: 
                                    user.userType == 'Admin' ||
                                    user.userType == 'Staff'
                                    ? () {
                                        Stream<String> stream =
                                            FireStoreEventMethods()
                                                .updateEventStatusByStream(
                                                    event.id!,
                                                    false,
                                                    false,
                                                    event.startDate!,
                                                    event.endDate!,
                                                    event.startTime!,
                                                    event.endTime!);
                                        stream.listen(
                                          (status) {
                                            setState(() {
                                              event.status = status;
                                            });
                                          },
                                          onError: (error) {
                                            if (kDebugMode) {
                                              print('Error: $error');
                                            }
                                          },
                                        );
                                      }
                                    : () {},
                                child: Chip(
                                  label: Text(
                                    event.status!,
                                    style: const TextStyle(
                                        color: lightColor,
                                        fontSize: kIsWeb ? 12 : 8),
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  backgroundColor: event.status == 'Cancelled'
                                      ? (darkModeOn
                                          ? darkModeMaroonColor
                                          : lightModeMaroonColor)
                                      : event.status == 'Upcoming'
                                          ? (darkModeOn
                                              ? darkModePrimaryColor
                                              : lightModePrimaryColor)
                                          : event.status == 'Moved'
                                              ? (darkModeOn
                                                  ? darkModeSecondaryColor
                                                  : lightModeSecondaryColor)
                                              : event.status == 'Past'
                                                  ? black
                                                  : (darkModeOn
                                                      ? darkModeGrassColor
                                                      : lightModeGrassColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
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
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    height: kIsWeb ? 250.0 : 100,
                                    child: Center(
                                        child: CircularProgressIndicator
                                            .adaptive()),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : CachedNetworkImage(
                                imageUrl: event.image!,
                                width: double.infinity,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    height: kIsWeb ? 250.0 : 100,
                                    child: Center(
                                        child: CircularProgressIndicator
                                            .adaptive()),
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
                                      onPressed: () async {
                                        bool isConnected =
                                            await ConnectivityService()
                                                .isConnected();
                                        if (isConnected) {
                                          downloadAndOpenFile(
                                              event.document ?? '',
                                              event.title!);
                                          _showOpenDocumentMessage();
                                        } else {
                                          // Show a message to the user
                                          mounted
                                              ? ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Icon(Icons.wifi_off,
                                                            color: darkModeOn
                                                                ? black
                                                                : white),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        const Flexible(
                                                            child: Text(
                                                                'No internet connection. Please check your connection and try again.')),
                                                      ],
                                                    ),
                                                    duration: const Duration(
                                                        seconds: 5),
                                                  ),
                                                )
                                              : '';
                                        }
                                      },
                                      icon: const Icon(
                                          Icons.download_for_offline),
                                      label: const Text(
                                        'Open document',
                                      )),
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
                                  Icons.school,
                                  color: darkModeOn
                                      ? darkModeSecondaryColor
                                      : lightModeSecondaryColor,
                                  size: kIsWeb ? 18 : 15,
                                ),
                                Text(
                                  ' Type',
                                  style: TextStyle(
                                      color:
                                          darkModeOn ? lightColor : darkColor,
                                      fontSize: kIsWeb ? 18 : 15),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  event.type!,
                                  style: TextStyle(
                                    color: darkModeOn
                                        ? darkModeSecondaryColor
                                        : lightModeSecondaryColor,
                                    fontSize: kIsWeb ? 16.0 : 13,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                          ],
                        ),
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
                                      color:
                                          darkModeOn ? lightColor : darkColor,
                                      fontSize: kIsWeb ? 18 : 15),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              event.description!,
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
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: darkModeOn
                                  ? darkModeSecondaryColor
                                  : lightModeSecondaryColor,
                              size: kIsWeb ? 18 : 15,
                            ),
                            Text(
                              ' Venue',
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
                              event.venue!,
                              style: TextStyle(
                                  fontSize: kIsWeb ? 16.0 : 13,
                                  color: darkModeOn
                                      ? darkModeTertiaryColor
                                      : lightModeTertiaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        event.approvedBy!.isNotEmpty ? Row(
                          children: [
                            Icon(
                              Icons.approval,
                              color: darkModeOn
                                  ? darkModeSecondaryColor
                                  : lightModeSecondaryColor,
                              size: kIsWeb ? 18 : 15,
                            ),
                            Text(
                              ' Approved by',
                              style: TextStyle(
                                  color: darkModeOn ? lightColor : darkColor,
                                  fontSize: kIsWeb ? 18 : 15),
                            ),
                          ],
                        ) : const SizedBox.shrink(),
                        const SizedBox(
                          height: 5,
                        ),
                        event.approvedBy!.isNotEmpty ? Column(
                          children: [
                            Text(
                              event.approvedBy!,
                              style: TextStyle(
                                  fontSize: kIsWeb ? 16.0 : 13,
                                  color: darkModeOn
                                      ? darkModeTertiaryColor
                                      : lightModeTertiaryColor),
                            ),
                          ],
                        ) : const SizedBox.shrink(),
                        const SizedBox(
                          height: 15.0,
                        ),
                      ],
                    ),
                  );
                });
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
