import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/personal_event.dart';
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_personal_event_methods.dart';
import 'package:student_event_calendar/screens/edit_personal_event_screen.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/personal_event_dialog.dart';
import 'package:timeago/timeago.dart' as timeago;

class PersonalEventNote extends StatefulWidget {
  const PersonalEventNote({super.key, this.personalEvent});

  final PersonalEvent? personalEvent;

  @override
  State<PersonalEventNote> createState() => _PersonalEventNoteState();
}

class _PersonalEventNoteState extends State<PersonalEventNote> {

  removePersonalEvent(personalEventId) async {
    try {
      String response = await FireStorePersonalEventMethods().removePersonalEvent(personalEventId);
      if (response == "Success") {
        // Pop all dialogs
        mounted ? Navigator.of(context).popUntil((route) => route.isFirst) : '';
        mounted ? ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your event was deleted successfully.'),
          ),
        ) : '';
      } else {
        mounted ? ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            duration: Duration(seconds: 5),
          ),
        ) : '';
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;

    return Dismissible(
      key: Key(widget.personalEvent!.id), // Assuming your PersonalEvent model has an id field
      background: Container(
        color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,
        child: const Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.delete, color: white, size: 20,),
                SizedBox(width: 5),
                Text("Delete", style: TextStyle(color: white, fontWeight: FontWeight.w700, fontSize: 20),),
              ],
            ),
          ),
        ),
      ),
      secondaryBackground: Container(
        color: darkModeOn ? darkModeGrassColor : lightModeGrassColor,
        child: const Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(Icons.edit, color: white, size: 20,),
                SizedBox(width: 5),
                Text("Edit", style: TextStyle(color: white, fontWeight: FontWeight.w700, fontSize: 20),),
              ],
            ),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return PersonalEventDialog(personalEvent: widget.personalEvent!);
            }
          );
        },
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Parallax image
              Positioned.fill(
                child: (widget.personalEvent?.image == null || widget.personalEvent!.image!.isEmpty)
                  ? Opacity(opacity: 0.9 ,child: Image.asset('assets/images/cspc_background.jpg', fit: BoxFit.cover))
                  : Opacity(
                    opacity: 0.9,
                    child: CachedNetworkImage(
                        imageUrl: widget.personalEvent!.image!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Image.asset('assets/images/cspc_background.jpg', fit: BoxFit.cover),
                      ),
                  ),
              ),
              // Dark gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, black.withOpacity(0.9)],
                      begin: Alignment.topCenter,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.personalEvent!.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            widget.personalEvent!.type,
                            style: const TextStyle(
                                color: lightColor, fontSize: kIsWeb ? 12 : 8),
                          ),
                          padding: const EdgeInsets.all(2.0),
                          backgroundColor: widget.personalEvent!.type == 'Academic'
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
                      ],
                    ),
                    Row(
                      children: [
                          const Icon(Icons.location_on, color: light, size: 12,),
                          const SizedBox(width: 5),
                          Text(
                            widget.personalEvent!.venue ?? '',
                            style: const TextStyle(
                              color: light),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        widget.personalEvent!.description,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: light, size: 12,),
                              const SizedBox(width: 5),
                              Text(
                                '${widget.personalEvent!.isEdited ? 'Updated' : 'Created' } ${timeago.format(widget.personalEvent!.dateUpdated!)}',
                                style: const TextStyle(
                                  color: light,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: light, size: 12,),
                            const SizedBox(width: 5),
                            Text(
                              DateFormat('MMMM dd, yyyy').format(widget.personalEvent!.startDate),
                              style: const TextStyle(
                                color: white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
       confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Edit action
          Future.delayed(Duration.zero, () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => EditPersonalEventScreen(eventSnap: widget.personalEvent!,)));
          }); 
        } else {
          // Delete action
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Row(
                  children: [
                    Icon(Icons.delete_forever,
                      color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,),
                    const SizedBox(width: 10),
                    Text(
                      'Delete Personal Event',
                      style: TextStyle(
                        color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Text(
                      'Are you sure you want to delete this personal event?',
                      style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                      ),
                  ),
                  SimpleDialogOption(
                    padding: const EdgeInsets.all(20),
                    onPressed: () async {
                      bool isConnected = await ConnectivityService().isConnected();
                      if (isConnected) {
                        mounted ? Navigator.of(context).pop() : '';
                        await removePersonalEvent(widget.personalEvent!.id);
                      } else {
                        // Show a message to the user
                        mounted ? Navigator.of(context).pop() : '';
                        mounted ? ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(children: [Icon(Icons.wifi_off, color: darkModeOn ? black : white),const SizedBox(width: 10,),const Flexible(child: Text('No internet connection. Please check your connection and try again.')),],),
                            duration: const Duration(seconds: 5),
                          ),
                        ) : '';
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.check_circle, 
                        color: darkModeOn ? darkModeMaroonColor : lightModeMaroonColor),
                        const SizedBox(width: 10),
                        Text('Yes', style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
                      ],
                    ),
                  ),
                  SimpleDialogOption(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.cancel, color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor),
                        const SizedBox(width: 10),
                        Text('No', style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          );
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // Edit action
        } else {
          
        }
      },
    );
  }
}