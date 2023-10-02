import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_personal_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';
import '../providers/darkmode_provider.dart';
import '../utils/global.dart';

class AddPersonalEvent extends StatefulWidget {
  const AddPersonalEvent({super.key});

  @override
  State<AddPersonalEvent> createState() => _AddPersonalEventState();
}

class _AddPersonalEventState extends State<AddPersonalEvent> {
  final _personalEventTypeController = TextEditingController();
  final _personalEventTitleController = TextEditingController();
  final _personalEventDescriptionsController = TextEditingController();
  final _personalEventVenueController = TextEditingController();
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
  List<String> courseParticipants = [
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
  Map<String, List<String>> selectedParticipants = {
    'course': [],
    'department': [],
  };

  // List all associated course for departments
  Map<String, String> courseDepartmentMap = {
    'BSCS': 'CCS',
    'BSIT': 'CCS',
    'BSN': 'CHS',
    'BSM': 'CHS',
    'BSME': 'CEA',
    'BSEE': 'CEA',
    'BSCE': 'CEA',
  };

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
        print('Trying to add personal event...');
      }
      // Check if all required parameters are not null
      if (_personalEventTypeController.text.isNotEmpty &&
          _personalEventTitleController.text.isNotEmpty &&
          _startDateController.text.isNotEmpty &&
          _endDateController.text.isNotEmpty &&
          _startTimeController.text.isNotEmpty &&
          _endTimeController.text.isNotEmpty &&
          _personalEventDescriptionsController.text.isNotEmpty &&
          _personalEventVenueController.text.isNotEmpty &&
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
        // Add the personal event to the database
        String response = await FireStorePersonalEventMethods().postPersonalEvent(
            _personalEventTitleController.text,
            _imageFile,
            _personalEventDescriptionsController.text,
            FirebaseAuth.instance.currentUser!.uid,
            _documentFile,
            startDatePart,
            endDatePart,
            startTime12,
            endTime12,
            selectedParticipants,
            _personalEventVenueController.text,
            _personalEventTypeController.text,
            'Upcoming');
        if (kDebugMode) {
          print('Add Personal Event Response: $response');
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
    Navigator.pop(context);
    showSnackBar('Your event uploaded successfully', context);
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

  // Clears input field
  void clearInputs() {
    setState(() {
      _imageFile = null;
      _documentFile = null;
      _personalEventTypeController.clear();
      _personalEventTitleController.clear();
      _personalEventDescriptionsController.clear();
      _personalEventVenueController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _startTimeController.clear();
      _endTimeController.clear();
      selectedParticipants.forEach((key, value) {
        selectedParticipants[key] = [];
      });
    });
  }

  // Disposing after changing
  @override
  void dispose() {
    super.dispose();
    _personalEventTypeController.dispose();
    _personalEventTitleController.dispose();
    _personalEventDescriptionsController.dispose();
    _personalEventVenueController.dispose();
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
          return currentUser!.userType == 'Student' ? ScaffoldMessenger(
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
                  title: Row(
                    children: [
                      Icon(
                        Icons.post_add,
                        color: darkModeOn
                            ? lightColor
                            : darkColor,
                        size: kIsWeb ? 40 : 25,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        'Add Personal Event',
                        style: TextStyle(
                          color: darkModeOn ? lightColor : darkColor,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor:
                      darkModeOn ? darkModeSecondaryColor : lightModeSecondaryColor,
                  iconTheme: IconThemeData(
                    color: darkModeOn ? lightColor : darkColor,
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
                                : const EdgeInsets.symmetric(horizontal: 5),
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
                                        Text(
                                          'Make your own event',
                                          style: TextStyle(
                                            fontSize: kIsWeb ? 32.0 : 24.0,
                                            fontWeight: FontWeight.bold,
                                            color: darkModeOn
                                                ? lightColor
                                                : darkColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      'Please provide the necessary details correctly and then make your personal event. Only one image and document can be selected. For document, only .pdf files can be uploaded. For image it can be .jpg or .png',
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          color: darkModeOn
                                              ? darkModeTertiaryColor
                                              : lightModeTertiaryColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.event),
                                            labelText:
                                                '${kIsWeb ? 'Select announcement type' : 'Type'}*',
                                            border: OutlineInputBorder(
                                                borderSide:
                                                    Divider.createBorderSide(
                                              context,
                                              color: darkModeOn
                                                  ? darkModeTertiaryColor
                                                  : lightModeTertiaryColor,
                                            )),
                                          ),
                                          value:
                                              _personalEventTypeController.text.isEmpty
                                                  ? null
                                                  : _personalEventTypeController.text,
                                          items: <String>[
                                            'Academic',
                                            'Non-academic'
                                          ].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(value),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _personalEventTypeController.text =
                                                  newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: IconButton(
                                          onPressed: () =>
                                              _selectImage(context),
                                          icon: const Icon(Icons.add_a_photo),
                                          tooltip: 'Add a photo',
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: IconButton(
                                          onPressed: () =>
                                              _selectDocument(context),
                                          icon: const Icon(
                                              Icons.file_present_rounded),
                                          tooltip: 'Add a document',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    Expanded(
                                      child: TextFieldInput(
                                        textEditingController:
                                            _personalEventTitleController,
                                        labelText: 'Title*',
                                        textInputType: TextInputType.text,
                                      ),
                                    ),
                                  ]),
                                ),
                                const SizedBox(height: 10.0),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                      flex: 2,
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              const Icon(Icons.location_pin),
                                          labelText:
                                              '${kIsWeb ? 'Select venue' : 'Venue'}*',
                                          border: OutlineInputBorder(
                                              borderSide:
                                                  Divider.createBorderSide(
                                            context,
                                            color: darkModeOn
                                                ? darkModeTertiaryColor
                                                : lightModeTertiaryColor,
                                          )),
                                        ),
                                        value:
                                            _personalEventVenueController.text.isEmpty
                                                ? null
                                                : _personalEventVenueController.text,
                                        items: <String>[
                                          'Gymnasium',
                                          'Auditorium'
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(value),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _personalEventVenueController.text =
                                                newValue!;
                                          });
                                        },
                                      ),
                                    )],
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Flexible(
                                  child: TextFormField(
                                    controller: _personalEventDescriptionsController,
                                    decoration: InputDecoration(
                                      labelText: 'Description*',
                                      alignLabelWithHint: true,
                                      border: outlineBorder,
                                      focusedBorder: outlineBorder,
                                      enabledBorder: outlineBorder,
                                      contentPadding: const EdgeInsets.all(12),
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
                                        labelText: 'Personal Event Date',
                                        textInputType: TextInputType.datetime,
                                      ),
                                    ),
                                  ]),
                                ),
                                const SizedBox(height: 10.0),
                                Flexible(
                                child: Row(children: [ 
                                  Flexible(
                                    child: TextFieldInput(
                                      startTextEditingController:
                                          _startTimeController,
                                      endTextEditingController:
                                          _endTimeController,
                                      isTimeRange: true,
                                      labelText: 'Personal Event Time',
                                      textInputType: TextInputType.datetime,
                                    ))
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
                                                    fontSize: kIsWeb ? 28 : 24,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ))),
                                          Flexible(
                                              child: Center(
                                                  child: Padding(
                                            padding: const EdgeInsets.all(8.0),
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
                                                              'Course',
                                                              courseParticipants)),
                                                      Expanded(
                                                          child: _buildParticipant(
                                                              'Department',
                                                              departmentParticipants)),
                                                    ],
                                                  ),
                                                )
                                              : Flexible(
                                                  fit: FlexFit.loose,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        _buildParticipant(
                                                            'Course',
                                                            courseParticipants),
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
                                          color: darkModeOn ? lightColor : darkColor,
                                        ),
                                        child: _isLoading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(lightColor),
                                              ))
                                            : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add_circle,
                                                  color: darkModeOn ? darkColor : lightColor,
                                                ),
                                                const SizedBox(width: 10.0),
                                                Text(
                                                    'Create your personal event',
                                                    style: TextStyle(
                                                      color: darkModeOn ? darkColor : lightColor,
                                                      fontWeight: FontWeight.bold,
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
          ) : const SizedBox.shrink();
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
                          String? dept = courseDepartmentMap[participant];
                          if (value!) {
                            selectedParticipants[type.toLowerCase()]
                                ?.add(participant);
                            if (type.toLowerCase() == 'course' &&
                                !selectedParticipants['department']!
                                    .contains(dept)) {
                              selectedParticipants['department']?.add(dept!);
                            }
                          } else {
                            selectedParticipants[type.toLowerCase()]
                                ?.remove(participant);
                            if (type.toLowerCase() == 'course' &&
                                selectedParticipants['course']!
                                    .where((course) =>
                                        courseDepartmentMap[course] == dept)
                                    .isEmpty) {
                              selectedParticipants['department']?.remove(dept);
                            }
                          }
                          if (type.toLowerCase() == 'department') {
                            var associatedCourses = courseDepartmentMap.entries
                                .where((entry) => entry.value == participant)
                                .map((entry) => entry.key)
                                .toList();
                            if (value) {
                              for (var course in associatedCourses) {
                                if (!selectedParticipants['course']!
                                    .contains(course)) {
                                  selectedParticipants['course']?.add(course);
                                }
                              }
                            } else {
                              for (var course in associatedCourses) {
                                if (selectedParticipants['course']!
                                    .contains(course)) {
                                  selectedParticipants['course']
                                      ?.remove(course);
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
                            String? dept = courseDepartmentMap[participant];
                            if (value!) {
                              selectedParticipants[type.toLowerCase()]
                                  ?.add(participant);
                              if (type.toLowerCase() == 'course' &&
                                  !selectedParticipants['department']!
                                      .contains(dept)) {
                                selectedParticipants['department']?.add(dept!);
                              }
                            } else {
                              selectedParticipants[type.toLowerCase()]
                                  ?.remove(participant);
                              if (type.toLowerCase() == 'course' &&
                                  selectedParticipants['course']!
                                      .where((course) =>
                                          courseDepartmentMap[course] == dept)
                                      .isEmpty) {
                                selectedParticipants['department']
                                    ?.remove(dept);
                              }
                            }
                            if (type.toLowerCase() == 'department') {
                              var associatedCourses = courseDepartmentMap
                                  .entries
                                  .where((entry) => entry.value == participant)
                                  .map((entry) => entry.key)
                                  .toList();
                              if (value) {
                                for (var course in associatedCourses) {
                                  if (!selectedParticipants['course']!
                                      .contains(course)) {
                                    selectedParticipants['course']?.add(course);
                                  }
                                }
                              } else {
                                for (var course in associatedCourses) {
                                  if (selectedParticipants['course']!
                                      .contains(course)) {
                                    selectedParticipants['course']
                                        ?.remove(course);
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
