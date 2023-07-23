import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/user.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

import '../providers/darkmode_provider.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescriptionsController =
      TextEditingController();
  final TextEditingController _eventVenueController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  final TextEditingController _eventParticipantsController =
      TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  Future<User> currentUser = AuthMethods().getUserDetails();
  Uint8List? _documentFile;
  Uint8List? _imageFile;
  bool _isLoading = false;

  void _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Upload an Image'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.camera),
                    SizedBox(width: 10),
                    Text('Take a photo'),
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.camera);
                  if (file != null) {
                    _imageFile = file;
                    const SnackBar snackBar =
                        SnackBar(content: Text('Image is uploaded!'));
                    ScaffoldMessenger.of(_scaffoldMessengerKey.currentContext!)
                        .showSnackBar(snackBar);
                  }
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.image_rounded),
                    SizedBox(width: 10),
                    Text('Choose from gallery'),
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.gallery);
                  if (file != null) {
                    _imageFile = file;
                    const SnackBar snackBar =
                        SnackBar(content: Text('Image is uploaded!'));
                    ScaffoldMessenger.of(_scaffoldMessengerKey.currentContext!)
                        .showSnackBar(snackBar);
                  }
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.cancel),
                    SizedBox(width: 10),
                    Text('Cancel'),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _selectDocument(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Upload a Document'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.file_present_rounded),
                    SizedBox(width: 10),
                    Text('Choose from files'),
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickDocument();
                  if (file != null) {
                    _documentFile = file;
                    const SnackBar snackBar =
                        SnackBar(content: Text('Document is uploaded!'));
                    ScaffoldMessenger.of(_scaffoldMessengerKey.currentContext!)
                        .showSnackBar(snackBar);
                  }
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.cancel),
                    SizedBox(width: 10),
                    Text('Cancel'),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _post() async {
    if (kDebugMode) {
      print('Post function started!');
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (kDebugMode) {
        print('Trying to add event...');
      }
      String currentUser = await AuthMethods().getCurrentUserUid();
      // Check if all required parameters are not null
      if (_eventTypeController.text.isNotEmpty &&
          _eventTitleController.text.isNotEmpty &&
          _eventDescriptionsController.text.isNotEmpty &&
          _eventDateController.text.isNotEmpty &&
          _eventTimeController.text.isNotEmpty &&
          _eventParticipantsController.text.isNotEmpty) {
        // Get the date and time from the text controllers
        String pickedDate = _eventDateController.text;
        String pickedTime = _eventTimeController.text;
        // Convert picked date (yyyy-mm-dd) to DateTime
        DateTime pickedDateTime = DateTime.parse(pickedDate);
        // Get only the date part as a DateTime object
        DateTime datePart = DateTime(
            pickedDateTime.year, pickedDateTime.month, pickedDateTime.day);
        // Parse 12-hour format time string to DateTime
        DateFormat time12Format = DateFormat('h:mm a');
        DateTime parsedTime12 = time12Format.parse(pickedTime);
        // Split the participants string into a list
        Map<String, List<dynamic>> participants =
            _eventParticipantsController.text.split(', ') as Map<String, List<dynamic>>;
        // Add the event to the database
        String response = await FireStoreEventMethods().postEvent(
            _eventTitleController.text,
            _imageFile,
            _eventDescriptionsController.text,
            currentUser,
            _documentFile,
            datePart,
            parsedTime12,
            participants,
            _eventVenueController.text,
            _eventTypeController.text,
            'Upcoming');
        if (kDebugMode) {
          print('Add Event Response: $response');
        }
        // Check if the response is a success or a failure
        if (response == 'Success') {
          onPostSuccess();
        } else {
          onPostFailure(response);
        }
        return response;
      } else {
        if (kDebugMode) {
          print('Complete all required parameters!');
        }
        setState(() {
          _isLoading = false;
        });
        // Show a snackbar if the image and document are not loaded
        mounted
            ? showSnackBar('Please complete the required fields.*', context)
            : '';
      }
    } catch (err) {
      if (kDebugMode) {
        print('Error caught: $err');
      }
      setState(() {
        _isLoading = false;
      });
      return err.toString();
    }
  }

  void onPostSuccess() {
    setState(() {
      _isLoading = false;
    });
    showSnackBar('Post uploaded successfully', context);
    clearInputs();
  }

  void onPostFailure(String message) {
    setState(() {
      _isLoading = false;
    });
    showSnackBar(message, context);
  }

  void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void clearInputs() {
    setState(() {
      _imageFile = null;
      _documentFile = null;
      _eventTypeController.clear();
      _eventTitleController.clear();
      _eventDescriptionsController.clear();
      _eventVenueController.clear();
      _eventDateController.clear();
      _eventTimeController.clear();
      _eventParticipantsController.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _eventTypeController.dispose();
    _eventTitleController.dispose();
    _eventDescriptionsController.dispose();
    _eventVenueController.dispose();
    _eventDateController.dispose();
    _eventTimeController.dispose();
    _eventParticipantsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return FutureBuilder<User>(
      future: currentUser,
      builder: (context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          User? currentUser = snapshot.data;
          return currentUser?.userType == 'Admin'
              ? ScaffoldMessenger(
                  key: _scaffoldMessengerKey,
                  child: Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'Post an Announcement',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.event),
                                    labelText: 'Select announcement type*',
                                  ),
                                  value: _eventTypeController.text.isEmpty
                                      ? null
                                      : _eventTypeController.text,
                                  items: <String>['Academic', 'Non-academic']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(Icons.check),
                                          const SizedBox(width: 10),
                                          Text(value),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _eventTypeController.text = newValue!;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: IconButton(
                                  onPressed: () => _selectImage(context),
                                  icon: const Icon(Icons.add_a_photo),
                                  tooltip: 'Add a photo',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: IconButton(
                                  onPressed: () => _selectDocument(context),
                                  icon: const Icon(Icons.file_present_rounded),
                                  tooltip: 'Add a document',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(children: [
                            Flexible(
                              child: TextFieldInput(
                                textEditingController: _eventTitleController,
                                labelText: 'Title*',
                                textInputType: TextInputType.text,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Flexible(
                              child: TextFieldInput(
                                textEditingController: _eventVenueController,
                                labelText: 'Venue (Optional)',
                                textInputType: TextInputType.text,
                              ),
                            )
                          ]),
                          const SizedBox(height: 10.0),
                          TextFieldInput(
                            textEditingController: _eventDescriptionsController,
                            labelText: 'Description*',
                            textInputType: TextInputType.text,
                          ),
                          const SizedBox(height: 10.0),
                          Row(children: [
                            Flexible(
                              child: TextFieldInput(
                                textEditingController: _eventDateController,
                                labelText: 'Select Date*',
                                textInputType: TextInputType.datetime,
                                isDate: true,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Flexible(
                              child: TextFieldInput(
                                textEditingController: _eventTimeController,
                                labelText: 'Select Time*',
                                textInputType: TextInputType.datetime,
                                isTime: true,
                              ),
                            )
                          ]),
                          const SizedBox(height: 10.0),
                          TextFieldInput(
                            textEditingController: _eventParticipantsController,
                            labelText:
                                'Participants* (Students, Teacher, etc.) Separate Participants with a comma (,)',
                            textInputType: TextInputType.text,
                          ),
                          const SizedBox(height: 10.0),
                          // participants (Checkbox that adds to a local array of participants)
                          Center(
                            child: InkWell(
                              onTap: _post,
                              child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  decoration: ShapeDecoration(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                    ),
                                    color: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
                                  ),
                                  child: _isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  lightColor),
                                        ))
                                      : const Text(
                                          'Create a New Announcement',
                                          style: TextStyle(
                                            color: lightColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox();
        }
      },
    );
  }
}
