import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/personal_event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';
import 'package:timezone/timezone.dart' as tz;

class PersonalEventDialog extends StatefulWidget {
  const PersonalEventDialog({super.key, this.personalEvent});

  final PersonalEvent? personalEvent;

  @override
  State<PersonalEventDialog> createState() => _PersonalEventDialogState();
}

class _PersonalEventDialogState extends State<PersonalEventDialog> {

  void _showOpenDocumentMessage() {
    Flushbar(
      message: "Please wait for the document to be accessed...",
      duration: const Duration(seconds: 6),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final manila = tz.getLocation('Asia/Manila');
    final startDate =
        tz.TZDateTime.from(widget.personalEvent!.startDate, manila);
    final endDate = tz.TZDateTime.from(widget.personalEvent!.endDate, manila);
    final startTime =
        tz.TZDateTime.from(widget.personalEvent!.startTime, manila);
    final endTime = tz.TZDateTime.from(widget.personalEvent!.endTime, manila);
    final datePublished = tz.TZDateTime.from(widget.personalEvent!.datePublished!, manila);
    

    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return AlertDialog(
      title: Text(widget.personalEvent!.title,
          style: TextStyle(
              color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
              fontSize: 24)),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            RichText(
              text: TextSpan(
                text: 'Start Date: ',
                style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                children: <TextSpan>[
                  TextSpan(text: DateFormat.yMMMd().format(startDate), style: TextStyle(fontWeight: FontWeight.bold,color: darkModeOn ? lightColor : darkColor)),
                ],
              ),
            ),
            const SizedBox(height: 3),
            RichText(
              text: TextSpan(
                text: 'End Date: ',
                style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                children: <TextSpan>[
                  TextSpan(text: DateFormat.yMMMd().format(endDate), style: TextStyle(fontWeight: FontWeight.bold,color: darkModeOn ? lightColor : darkColor)),
                ],
              ),
            ),
            const SizedBox(height: 3),
            RichText(
              text: TextSpan(
                text: 'Start Time: ',
                style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                children: <TextSpan>[
                  TextSpan(text: DateFormat.jm().format(startTime), style: TextStyle(fontWeight: FontWeight.bold,color: darkModeOn ? lightColor : darkColor)),
                ],
              ),
            ),
            const SizedBox(height: 3),
            RichText(
              text: TextSpan(
                text: 'End Time: ',
                style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                children: <TextSpan>[
                  TextSpan(text: DateFormat.jm().format(endTime), style: TextStyle(fontWeight: FontWeight.bold,color: darkModeOn ? lightColor : darkColor)),
                ],
              ),
            ),
            const SizedBox(height: 3),
            RichText(
              text: TextSpan(
                text: 'Description: ',
                style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                children: <TextSpan>[
                  TextSpan(text: widget.personalEvent!.description, style: TextStyle(fontWeight: FontWeight.bold,color: darkModeOn ? lightColor : darkColor)),
                ],
              )
            ),
            const SizedBox(height: 3),
            RichText(
              text: TextSpan(
                text: 'Location: ',
                style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                children: <TextSpan>[
                  TextSpan(text: widget.personalEvent!.venue, style: TextStyle(fontWeight: FontWeight.bold,color: darkModeOn ? lightColor : darkColor)),
                ],
              )
            ),
            const SizedBox(height: 3),
            RichText(
              text: TextSpan(
                text: 'Type: ',
                style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                children: <TextSpan>[
                  TextSpan(text: widget.personalEvent!.type, style: TextStyle(fontWeight: FontWeight.bold,color: darkModeOn ? lightColor : darkColor)),
                ],
              )
            ),
            const SizedBox(height: 10),
            widget.personalEvent!.document == null || widget.personalEvent!.document == ''
              ? const SizedBox.shrink()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                    onPressed: () async {
                      bool isConnected = await ConnectivityService().isConnected();
                      if (isConnected) {
                        downloadAndOpenFile(widget.personalEvent!.document ?? '', widget.personalEvent!.title);
                        _showOpenDocumentMessage();
                      } else {
                        // Show a message to the user
                        mounted ? ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(children: [Icon(Icons.wifi_off, color: darkModeOn ? black : white),const SizedBox(width: 10,),const Flexible(child: Text('No internet connection. Please check your connection and try again.')),],),
                            duration: const Duration(seconds: 5),
                          ),
                        ) : '';
                      }
                    },
                    icon: Icon(Icons.download_for_offline, color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,),
                    label: Text('Open document', style: TextStyle(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),)),
                  ],
                ),
            widget.personalEvent!.document == null || widget.personalEvent!.document == ''
              ? const SizedBox.shrink()
              : const SizedBox(height: 20.0),
            Text('Event created: ${DateFormat.yMMMd().format(datePublished)} @ ${DateFormat.jm().format(datePublished)}', style: TextStyle(color: darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor, fontSize: 12),),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close', style: TextStyle(color: white)),
        ),
      ],
    );
  }
}
