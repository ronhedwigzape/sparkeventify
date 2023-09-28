import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/personal_event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class PersonalEventNote extends StatefulWidget {
  const PersonalEventNote({super.key, this.personalEvent});

  final PersonalEvent? personalEvent;

  @override
  State<PersonalEventNote> createState() => _PersonalEventNoteState();
}

class _PersonalEventNoteState extends State<PersonalEventNote> {
  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Parallax image
            Positioned.fill(
              child: (widget.personalEvent?.image == null || widget.personalEvent!.image!.isEmpty)
                ? Image.asset('assets/images/cspc_background.jpg', fit: BoxFit.cover)
                : CachedNetworkImage(
                    imageUrl: widget.personalEvent!.image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                    errorWidget: (context, url, error) => Image.asset('assets/images/cspc_background.jpg', fit: BoxFit.cover),
                  ),
            ),
            // Dark gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Event details
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    widget.personalEvent!.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.personalEvent!.description,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          timeago.format(widget.personalEvent!.dateUpdated!),
                          style: const TextStyle(
                            color: light,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        'Start Date: ${DateFormat('MMMM dd, yyyy').format(widget.personalEvent!.startDate)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}