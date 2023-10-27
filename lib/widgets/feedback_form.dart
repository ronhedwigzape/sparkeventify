import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/evaluator_feedback.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/providers/darkmode_provider.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/resources/firestore_feedback_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:student_event_calendar/widgets/cspc_spinner.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({Key? key, required this.eventId}) : super(key: key);

  final String eventId;

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  late Future<Event> event;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    event = FireStoreEventMethods().getEventById(widget.eventId);
  }

  @override
  void dispose() {
    super.dispose();
    _feedbackController.dispose();
    _ratingController.dispose();
  }

  createFeedback(context, eventName) async {
    model.User? user = await FireStoreUserMethods().getCurrentUserData();
    if (kDebugMode) {
      print('User: $user');
    } 

    String? eventFeedbackUid = await FirestoreFeedbackMethods().getEventFeedbackUid(widget.eventId);
    if (kDebugMode) {
      print('Event Feedback UID: $eventFeedbackUid');
    }  // Print the event feedback UID

    // Print the rating and feedback text
    if (kDebugMode) {
      print('Rating: ${_ratingController.text}');
    }
    if (kDebugMode) {
      print('Feedback: ${_feedbackController.text}');
    }

    // If feedback is empty
    if (eventFeedbackUid == null && user != null) {
      // Will be assigned with returned Widget id from this function
      eventFeedbackUid = await FirestoreFeedbackMethods().addEmptyFeedback(widget.eventId); 

      EvaluatorFeedback evaluatorFeedback = EvaluatorFeedback(
        userUid: user.uid,
        userFullName: user.profile?.fullName ?? '',
        userProgram: user.profile?.program ?? '',
        userDepartment: user.profile?.department ?? '',
        satisfactionStatus: _ratingController.text.isNotEmpty ? (_ratingController.text == 'Satisfied' ? true : false) : false,
        studentEvaluation: _feedbackController.text.isNotEmpty ? _feedbackController.text : 'No evaluation provided',
        attendanceStatus: true,
        isFeedbackDone: true,
      );

      // Should add evaluatorFeedback to newly created feedback doc
      await FirestoreFeedbackMethods().addEvaluatorFeedback(
        widget.eventId, 
        eventFeedbackUid, 
        evaluatorFeedback
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback submitted successfully for $eventName')),
        );
      }
    }
    // Else if feedback is present and has user
    else if (user != null) {
      EvaluatorFeedback evaluatorFeedback = EvaluatorFeedback(
        userUid: user.uid,
        userFullName: user.profile?.fullName ?? '',
        userProgram: user.profile?.program ?? '',
        userDepartment: user.profile?.department ?? '',
        satisfactionStatus: _ratingController.text.isNotEmpty ? (_ratingController.text == 'Satisfied' ? true : false) : false,
        studentEvaluation: _feedbackController.text.isNotEmpty ? _feedbackController.text : 'No evaluation provided',
        attendanceStatus: true,
        isFeedbackDone: true,
      );
      await FirestoreFeedbackMethods().addEvaluatorFeedback(
          widget.eventId, eventFeedbackUid!, evaluatorFeedback);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback submitted successfully for $eventName')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
    stream: FirestoreFeedbackMethods().getEventFeedbackStatusByUserId(
      widget.eventId, FirebaseAuth.instance.currentUser!.uid),
    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      if (snapshot.hasData) {
        bool eventFeedbackStatus = snapshot.data!;
        return TextButton.icon(
          icon: Icon(
            eventFeedbackStatus ? Icons.check : Icons.feedback,
            color: eventFeedbackStatus ? darkModeGrassColor : lightColor,
          ),
          label: Text(
            eventFeedbackStatus ? 'Feedback Submitted' : 'Add Feedback',
            style: TextStyle(
              color: eventFeedbackStatus ? darkModeGrassColor : lightColor,
              fontWeight: eventFeedbackStatus ? FontWeight.bold : null,  
            ),
          ),
          onPressed: () {
            eventFeedbackStatus ? null : openFeedbackForm();
          },
        );
      } else {
        return const Center(child: LinearProgressIndicator());
      }
    },
  );

  }

  Future openFeedbackForm() => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
          return FutureBuilder<Event>(
            future: event,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CSPCFadeLoader());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return GestureDetector(
                  onTap: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AlertDialog(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Make Your Feedback for:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14,
                                  color: darkModeOn
                                    ? darkModeTertiaryColor
                                    : lightModeTertiaryColor),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              snapshot.data!.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Thank you for attending our event! We hope you had a great experience. Your feedback is important to us as it helps us improve future events. Please take a moment to complete this feedback form.',
                              style: TextStyle(
                                  color: darkModeOn
                                      ? darkModeSecondaryColor
                                      : lightModeSecondaryColor,
                                  fontSize: 13),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Instructions:',
                                style: TextStyle(fontSize: 13)),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '- Use the dropdown to select either "Satisfied" or "Dissatisfied" for each section.',
                              style: TextStyle(
                                  color: darkModeOn
                                      ? darkModeTertiaryColor
                                      : lightModeTertiaryColor,
                                  fontSize: 12),
                            ),
                            Text(
                              '- In the comment box, please provide specific details or suggestions to support your rating.',
                              style: TextStyle(
                                  color: darkModeOn
                                      ? darkModeTertiaryColor
                                      : lightModeTertiaryColor,
                                  fontSize: 12),
                            ),
                            Text(
                              '- Be honest and constructive in your feedback as it cannot be undone.',
                              style: TextStyle(
                                  color: darkModeOn
                                      ? darkModeTertiaryColor
                                      : lightModeTertiaryColor,
                                  fontSize: 12),
                            )
                          ],
                        ),
                        content: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: Divider.createBorderSide(
                                      context,
                                      color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,)
                                  ),
                                  prefixIcon: const Icon(Icons.thumb_up_alt),
                                  labelText: 'Rating*',
                                ),
                                value: _ratingController.text.isEmpty
                                    ? null
                                    : _ratingController.text,
                                items: <String>['Satisfied', 'Dissatisfied']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: <Widget>[
                                        Icon(value == 'Satisfied'
                                            ? Icons.thumb_up
                                            : Icons.thumb_down),
                                        const SizedBox(width: 8),
                                        Text(value),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _ratingController.text = newValue!;
                                  });
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please select a rating';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Your Comment*',
                                    alignLabelWithHint: true,
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.multiline,
                                controller: _feedbackController,
                                minLines: 4,
                                maxLines: null,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please create your feedback.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Column(
                              children: [
                                Icon(Icons.check, color: darkModeGrassColor),
                                SizedBox(width: 10),
                                Text(
                                  'Submit',
                                  style: TextStyle(color: darkModeGrassColor),
                                )
                              ],
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (mounted) {
                                  Future<bool> Function() isConnected = ConnectivityService().isConnected;
                                  if (await isConnected()) {
                                    // ignore: use_build_context_synchronously
                                    await createFeedback(context, snapshot.data!.title);
                                  } else {
                                    // Show a message to the user
                                    mounted ? ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(children: [Icon(Icons.wifi_off, color: darkModeOn ? black : white),const SizedBox(width: 10,),const Flexible(child: Text('No internet connection. Please check your connection and try again.')),],),
                                        duration: const Duration(seconds: 5),
                                      ),
                                    ) : '';
                                  }
                                  mounted ? Navigator.of(context).pop() : '';
                                }
                              }
                            },
                          ),
                          TextButton(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.close,
                                  color: darkModeOn
                                    ? darkModeMaroonColor
                                    : lightModeMaroonColor,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Close',
                                  style: TextStyle(
                                    color: darkModeOn
                                      ? darkModeMaroonColor
                                      : lightModeMaroonColor),
                                )
                              ],
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      );
}
