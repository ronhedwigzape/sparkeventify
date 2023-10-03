import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/event.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/resources/storage_methods.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';
import '../providers/darkmode_provider.dart';
import '../utils/global.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({Key? key, required this.eventSnap}) : super(key: key);

  final Event eventSnap;
  @override
  State<EditEventScreen> createState() => EditEventScreenState();
}

class EditEventScreenState extends State<EditEventScreen> {
  final _eventTypeController = TextEditingController();
  final _eventTitleController = TextEditingController();
  final _eventDescriptionsController = TextEditingController();
  final _eventVenueController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  Future<model.User?> currentUser = AuthMethods().getCurrentUserDetails();
  Uint8List? _documentFile;
  Uint8List? _imageFile;
  bool _isLoading = false;
  List<String> programParticipants = [
    'BSCS',
    'BSIT',
    'BSN',
    'BSM',
    'BSEE',
    'BSME',
    'BSCE'
  ];
  List<String> departmentParticipants = [
    'CCS',
    'CHS',
    'CEA',
  ];
  Map<String, dynamic> selectedParticipants = {
    'program': [],
    'department': [],
  };

  // List all associated program for departments
  Map<String, String> programDepartmentMap = {
    'BSCS': 'CCS',
    'BSIT': 'CCS',
    'BSN': 'CHS',
    'BSM': 'CHS',
    'BSME': 'CEA',
    'BSEE': 'CEA',
    'BSCE': 'CEA',
  };

  @override
  void initState() {
    super.initState();
    _eventTypeController.text = widget.eventSnap.type;
    _eventTitleController.text = widget.eventSnap.title;
    _eventDescriptionsController.text = widget.eventSnap.description;
    _eventVenueController.text = widget.eventSnap.venue!;
    _startDateController.text =
        DateFormat('yyyy-MM-dd').format(widget.eventSnap.startDate);
    _endDateController.text =
        DateFormat('yyyy-MM-dd').format(widget.eventSnap.endDate);
    _startTimeController.text =
        DateFormat('h:mm a').format(widget.eventSnap.startTime);
    _endTimeController.text =
        DateFormat('h:mm a').format(widget.eventSnap.endTime);
    selectedParticipants['program'] = widget.eventSnap.participants!['program'];
    selectedParticipants['department'] =
        widget.eventSnap.participants!['department'];
  }

  void _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Upload an Image'),
            children: [
              !kIsWeb
                  ? SimpleDialogOption(
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
                          ScaffoldMessenger.of(
                                  _scaffoldMessengerKey.currentContext!)
                              .showSnackBar(snackBar);
                        }
                      },
                    )
                  : const SizedBox.shrink(),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.image_rounded),
                    SizedBox(width: 10),
                    Text('Choose from ${kIsWeb ? 'files' : 'gallery'}'),
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.gallery);
                  if (file != null) {
                    _imageFile = file;
                    const SnackBar snackBar =
                        SnackBar(content: Text('New image is uploaded!'));
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
                        SnackBar(content: Text('New document is uploaded!'));
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

  setEventCancellation(DateTime startDate, DateTime endDate) async {
    try {
      return await FireStoreEventMethods().updateEventStatus(
          widget.eventSnap.id, true, null, startDate, endDate, null);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  isEventMoved() async {}

  _update() async {
    if (kDebugMode) {
      print('Post function started!');
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (kDebugMode) {
        print('Trying to update event...');
      }
      // Check if all required parameters are not null
      if (_eventTypeController.text.isNotEmpty &&
          _eventTitleController.text.isNotEmpty &&
          _startDateController.text.isNotEmpty &&
          _endDateController.text.isNotEmpty &&
          _startTimeController.text.isNotEmpty &&
          _endTimeController.text.isNotEmpty &&
          _eventDescriptionsController.text.isNotEmpty &&
          _eventVenueController.text.isNotEmpty &&
          selectedParticipants.isNotEmpty) {
        // Get the date and time from the text controllers
        String pickedStartDate = _startDateController.text;
        String pickedEndDate = _endDateController.text;
        String pickedStartTime = _startTimeController.text;
        String pickedEndTime = _endTimeController.text;
        // Convert picked date (yyyy-mm-dd) to DateTime
        DateTime startDate = DateTime.parse(pickedStartDate);
        DateTime endDate = DateTime.parse(pickedEndDate);
        // Get only the date part as a DateTime object
        DateTime startDatePart =
            DateTime(startDate.year, startDate.month, startDate.day);
        DateTime endDatePart =
            DateTime(endDate.year, endDate.month, endDate.day);
        // Parse 12-hour format time string to DateTime
        DateFormat time12Format = DateFormat('h:mm a');
        DateTime startTime12 = time12Format.parse(pickedStartTime);
        DateTime endTime12 = time12Format.parse(pickedEndTime);

        // If the image is not null, upload it to storage and get the URL
        String imageUrl = widget.eventSnap.image!;
        if (_imageFile != null && imageUrl.isEmpty) {
          imageUrl = await StorageMethods()
              .uploadImageToStorage('images', _imageFile!, true);
        }

        // Update the image if there is a image url already
        if (imageUrl.startsWith('https://firebasestorage.googleapis.com') &&
            _imageFile is Uint8List &&
            _imageFile != Uint8List(0) &&
            _imageFile != null) {
          imageUrl = await StorageMethods()
              .uploadImageToStorage('images', _imageFile!, true);
          // create delete current image method here
        }

        // If the document is not null, upload it to storage and get the URL
        String documentUrl = widget.eventSnap.document!;
        if (_documentFile != null && documentUrl.isEmpty) {
          documentUrl = await StorageMethods()
              .uploadFileToStorage('documents', _documentFile!);
        }

        // Update the document if there is a document url already
        if (documentUrl.startsWith('https://firebasestorage.googleapis.com') &&
            _documentFile is Uint8List &&
            _documentFile != Uint8List(0) &&
            _documentFile != null) {
          documentUrl = await StorageMethods()
              .uploadFileToStorage('documents', _documentFile!);
          // create delete current document method here
        }

        Event event = Event(
          id: widget.eventSnap.id,
          title: _eventTitleController.text,
          image: imageUrl,
          description: _eventDescriptionsController.text,
          createdBy: widget.eventSnap.createdBy,
          document: documentUrl,
          participants: selectedParticipants,
          venue: _eventVenueController.text,
          startDate: startDatePart,
          endDate: endDatePart,
          startTime: startTime12,
          endTime: endTime12,
          type: _eventTypeController.text,
          status: widget.eventSnap.status, // TODO: change this
          dateUpdated: DateTime.now(),
          datePublished: widget.eventSnap.datePublished,
        );

        // Add the event to the database
        String response = await FireStoreEventMethods()
            .updateEvent(widget.eventSnap.id, event);

        await FireStoreEventMethods().updateEventStatus(
            widget.eventSnap.id, false, false, startDate, endDate, null);

        if (kDebugMode) {
          print('Update Event Response: $response');
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
        print('Error caught: ${err.toString() + err.runtimeType.toString()}');
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
    Navigator.pop(context);
    showSnackBar('Event updated successfully!', context);
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

  // Disposing after changing
  @override
  void dispose() {
    super.dispose();
    _eventTypeController.dispose();
    _eventTitleController.dispose();
    _eventDescriptionsController.dispose();
    _eventVenueController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    final width = MediaQuery.of(context).size.width;

    final outlineBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context,
          color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor),
    );
    return FutureBuilder<model.User?>(
      future: currentUser,
      builder: (context, AsyncSnapshot<model.User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
                  color: darkModeOn
                      ? darkModePrimaryColor
                      : lightModePrimaryColor));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          model.User? currentUser = snapshot.data;
          return currentUser?.userType != 'Student'
              ? ScaffoldMessenger(
                  key: _scaffoldMessengerKey,
                  child: GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                    child: Scaffold(
                      appBar: AppBar(
                        title: Text(
                          'Edit ${widget.eventSnap.type == 'Academic' ? 'Announcement' : 'Event'}',
                          style: TextStyle(
                            color: darkModeOn ? white : black,
                          ),
                        ),
                        backgroundColor: darkModeOn ? darkColor : lightColor,
                        iconTheme: IconThemeData(
                          color: darkModeOn ? white : black,
                        ),
                      ),
                      body: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: kIsWeb
                                    ? (width > webScreenSize ? width * 0.2 : 0)
                                    : 0),
                            child: Padding(
                              padding: const EdgeInsets.all(kIsWeb ? 8.0 : 2),
                              child: Card(
                                color: darkModeOn ? darkColor : lightColor,
                                child: Padding(
                                  padding: kIsWeb
                                      ? const EdgeInsets.all(30.0)
                                      : const EdgeInsets.symmetric(
                                          horizontal: 5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: darkModeOn
                                                    ? lightColor
                                                    : darkColor,
                                                size: kIsWeb ? 40 : 25,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'Update "${widget.eventSnap.title}"',
                                                  style: TextStyle(
                                                    fontSize:
                                                        kIsWeb ? 32.0 : 24.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: darkModeOn
                                                        ? lightColor
                                                        : darkColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Instructions: Please edit the required* details correctly and then update the announcement.',
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: darkModeOn
                                                        ? darkModeTertiaryColor
                                                        : lightModeTertiaryColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                decoration:
                                                    const InputDecoration(
                                                  prefixIcon: Icon(Icons.event),
                                                  labelText:
                                                      '${kIsWeb ? 'Select announcement type' : 'Type'}*',
                                                ),
                                                value: _eventTypeController
                                                        .text.isEmpty
                                                    ? widget.eventSnap.type
                                                    : _eventTypeController.text,
                                                items: <String>[
                                                  'Academic',
                                                  'Non-academic'
                                                ].map((String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(value),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _eventTypeController.text =
                                                        newValue!;
                                                  });
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                              child: IconButton(
                                                onPressed: () =>
                                                    _selectImage(context),
                                                icon: Icon(
                                                  Icons.add_a_photo,
                                                  color: widget.eventSnap.image!
                                                          .isNotEmpty
                                                      ? (darkModeOn ? white : black)
                                                      : (darkModeOn
                                                          ? darkModeSecondaryColor
                                                          : lightModeSecondaryColor),
                                                ),
                                                tooltip: 'Add a photo',
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                              child: IconButton(
                                                onPressed: () =>
                                                    _selectDocument(context),
                                                icon: Icon(
                                                  Icons.file_present_rounded,
                                                  color: widget.eventSnap
                                                          .document!.isNotEmpty
                                                      ? (darkModeOn ? white : black)
                                                      : (darkModeOn
                                                          ? darkModeSecondaryColor
                                                          : lightModeSecondaryColor),
                                                ),
                                                tooltip: 'Add a document',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Flexible(
                                        child: Row(children: [
                                          Flexible(
                                            child: TextFieldInput(
                                              textEditingController:
                                                  _eventTitleController,
                                              labelText: 'Title*',
                                              textInputType: TextInputType.text,
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          Flexible(
                                            child:
                                                DropdownButtonFormField<String>(
                                              decoration: const InputDecoration(
                                                prefixIcon:
                                                    Icon(Icons.location_pin),
                                                labelText:
                                                    '${kIsWeb ? 'Select venue' : 'Venue'}*',
                                              ),
                                              value: _eventVenueController
                                                      .text.isEmpty
                                                  ? widget.eventSnap.venue
                                                  : _eventVenueController.text,
                                              items: <String>[
                                                'Gymnasium',
                                                'Auditorium'
                                              ].map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(value),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _eventVenueController.text =
                                                      newValue!;
                                                });
                                              },
                                            ),
                                          )
                                        ]),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Flexible(
                                        child: TextFormField(
                                          controller:
                                              _eventDescriptionsController,
                                          decoration: InputDecoration(
                                            labelText: 'Description*',
                                            alignLabelWithHint: true,
                                            border: outlineBorder,
                                            focusedBorder: outlineBorder,
                                            enabledBorder: outlineBorder,
                                            contentPadding:
                                                const EdgeInsets.all(12),
                                          ),
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          keyboardType: TextInputType.multiline,
                                          minLines: 4,
                                          maxLines: null,
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Flexible(
                                        child: Row(children: [
                                          Flexible(
                                            child: TextFieldInput(
                                              startTextEditingController:
                                                  _startDateController,
                                              endTextEditingController:
                                                  _endDateController,
                                              isDateRange: true,
                                              labelText: 'Event Date',
                                              textInputType:
                                                  TextInputType.datetime,
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          Flexible(
                                            child: TextFieldInput(
                                              startTextEditingController:
                                                  _startTimeController,
                                              endTextEditingController:
                                                  _endTimeController,
                                              isTimeRange: true,
                                              labelText: 'Event Time',
                                              textInputType:
                                                  TextInputType.datetime,
                                            ),
                                          )
                                        ]),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Flexible(
                                                    child: Center(
                                                        child: Padding(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Text('Participants*',
                                                      style: TextStyle(
                                                          fontSize:
                                                              kIsWeb ? 28 : 24,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ))),
                                                Flexible(
                                                    child: Center(
                                                        child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Check all the type of participants that will be involved.',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: darkModeOn
                                                              ? darkModeTertiaryColor
                                                              : lightModeTertiaryColor)),
                                                ))),
                                                // participants (Checkbox that adds to a local array of participants)
                                                kIsWeb
                                                    ? Flexible(
                                                        fit: FlexFit.loose,
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                                child: _buildParticipant(
                                                                    'Program',
                                                                    programParticipants)),
                                                            Expanded(
                                                                child: _buildParticipant(
                                                                    'Department',
                                                                    departmentParticipants)),
                                                          ],
                                                        ),
                                                      )
                                                    : Flexible(
                                                        fit: FlexFit.loose,
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              _buildParticipant(
                                                                  'Program',
                                                                  programParticipants),
                                                              _buildParticipant(
                                                                  'Department',
                                                                  departmentParticipants),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Center(
                                        child: InkWell(
                                          onTap: () async {
                                            bool isConnected = await ConnectivityService().isConnected();
                                            if (isConnected) {
                                              await _update();
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
                                          child: Container(
                                              width: double.infinity,
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16.0),
                                              decoration: ShapeDecoration(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5.0)),
                                                ),
                                                color: darkModeOn
                                                    ? darkModePrimaryColor
                                                    : lightModePrimaryColor,
                                              ),
                                              child: _isLoading
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              lightColor),
                                                    ))
                                                  : Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.update,
                                                        color: lightColor,
                                                      ),
                                                      const SizedBox(width: 10.0),
                                                      Text(
                                                          'Update ${widget.eventSnap.type == 'Academic' ? 'announcement' : 'event'}',
                                                          style: const TextStyle(
                                                            color: lightColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    ],
                                                  )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox();
        }
      },
    );
  }

  _buildParticipant(String type, List<String> participants) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return kIsWeb
        ? Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  type,
                  style: const TextStyle(
                      fontSize: kIsWeb ? 20 : 12, fontWeight: FontWeight.bold),
                ),
              ),
              ...participants
                  .map(
                    (participant) => CheckboxListTile(
                      activeColor: darkModeOn
                          ? darkModePrimaryColor
                          : lightModePrimaryColor,
                      checkColor: darkModeOn ? darkColor : lightColor,
                      title: Text(participant),
                      value: selectedParticipants[type.toLowerCase()]
                          ?.contains(participant),
                      onChanged: (bool? value) {
                        setState(() {
                          String? dept = programDepartmentMap[participant];
                          if (value!) {
                            selectedParticipants[type.toLowerCase()]
                                ?.add(participant);
                            if (type.toLowerCase() == 'program' &&
                                !selectedParticipants['department']!
                                    .contains(dept)) {
                              selectedParticipants['department']?.add(dept!);
                            }
                          } else {
                            selectedParticipants[type.toLowerCase()]
                                ?.remove(participant);
                            if (type.toLowerCase() == 'program' &&
                                selectedParticipants['program']!
                                    .where((program) =>
                                        programDepartmentMap[program] == dept)
                                    .isEmpty) {
                              selectedParticipants['department']?.remove(dept);
                            }
                          }
                          if (type.toLowerCase() == 'department') {
                            var associatedPrograms = programDepartmentMap.entries
                                .where((entry) => entry.value == participant)
                                .map((entry) => entry.key)
                                .toList();
                            if (value) {
                              for (var program in associatedPrograms) {
                                if (!selectedParticipants['program']!
                                    .contains(program)) {
                                  selectedParticipants['program']?.add(program);
                                }
                              }
                            } else {
                              for (var program in associatedPrograms) {
                                if (selectedParticipants['program']!
                                    .contains(program)) {
                                  selectedParticipants['program']
                                      ?.remove(program);
                                }
                              }
                            }
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ],
          )
        : Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  type,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: participants
                    .map(
                      (participant) => CheckboxListTile(
                        activeColor: darkModeOn
                            ? darkModePrimaryColor
                            : lightModePrimaryColor,
                        checkColor: darkModeOn ? darkColor : lightColor,
                        title: Text(participant),
                        value: selectedParticipants[type.toLowerCase()]
                            ?.contains(participant),
                        onChanged: (bool? value) {
                          setState(() {
                            String? dept = programDepartmentMap[participant];
                            if (value!) {
                              selectedParticipants[type.toLowerCase()]
                                  ?.add(participant);
                              if (type.toLowerCase() == 'program' &&
                                  !selectedParticipants['department']!
                                      .contains(dept)) {
                                selectedParticipants['department']?.add(dept!);
                              }
                            } else {
                              selectedParticipants[type.toLowerCase()]
                                  ?.remove(participant);
                              if (type.toLowerCase() == 'program' &&
                                  selectedParticipants['program']!
                                      .where((program) =>
                                          programDepartmentMap[program] == dept)
                                      .isEmpty) {
                                selectedParticipants['department']
                                    ?.remove(dept);
                              }
                            }
                            if (type.toLowerCase() == 'department') {
                              var associatedPrograms = programDepartmentMap
                                  .entries
                                  .where((entry) => entry.value == participant)
                                  .map((entry) => entry.key)
                                  .toList();
                              if (value) {
                                for (var program in associatedPrograms) {
                                  if (!selectedParticipants['program']!
                                      .contains(program)) {
                                    selectedParticipants['program']?.add(program);
                                  }
                                }
                              } else {
                                for (var program in associatedPrograms) {
                                  if (selectedParticipants['program']!
                                      .contains(program)) {
                                    selectedParticipants['program']
                                        ?.remove(program);
                                  }
                                }
                              }
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          );
  }
}
