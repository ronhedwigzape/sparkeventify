import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/layouts/admin_screen_layout.dart';
import 'package:student_event_calendar/layouts/client_screen_layout.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/services/connectivity_service.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';
import 'package:student_event_calendar/widgets/cspc_background.dart';
import 'package:student_event_calendar/widgets/cspc_spinner.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';
import '../providers/darkmode_provider.dart';
import '../utils/global.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
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

  void _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
        final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
          return SimpleDialog(
            title: Text('Upload an Image', style: TextStyle(color: darkModeOn ? lightColor : darkColor,),),
            children: [
              !kIsWeb
                  ? SimpleDialogOption(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.camera),
                          const SizedBox(width: 10),
                          Text('Take a photo', style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
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
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.image_rounded),
                    const SizedBox(width: 10),
                    Text('Choose from ${kIsWeb ? 'files' : 'gallery'}', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
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
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.cancel),
                    const SizedBox(width: 10),
                    Text('Cancel', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
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
          final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
          return SimpleDialog(
            title: Text('Upload a Document', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.file_present_rounded),
                    const SizedBox(width: 10),
                    Text('Choose from files', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
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
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.cancel),
                    const SizedBox(width: 10),
                    Text('Cancel', style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
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

  _post(String userType) async {
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
        DateTime startDatePart = DateTime(startDate.year, startDate.month, startDate.day);
        DateTime endDatePart = DateTime(endDate.year, endDate.month, endDate.day);
        // Parse 12-hour format time string to DateTime
        DateFormat time12Format = DateFormat('h:mm a');
        DateTime startTime12 = time12Format.parse(pickedStartTime);
        DateTime endTime12 = time12Format.parse(pickedEndTime);
        // Add the event to the database
        String response = await FireStoreEventMethods().postEvent(
            _eventTitleController.text,
            _imageFile,
            _eventDescriptionsController.text,
            FirebaseAuth.instance.currentUser!.uid,
            _documentFile,
            startDatePart,
            endDatePart,
            startTime12,
            endTime12,
            selectedParticipants,
            _eventVenueController.text,
            _eventTypeController.text,
            'Upcoming',
            userType
          );
        if (kDebugMode) {
          print('Add Event Response: $response');
        }
        // Check if the response is a success or a failure
        if (response == 'Success') {
          onPostSuccess(userType);
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


  void onPostSuccess(String userType) {
    setState(() {
      _isLoading = false;
    });
    if (userType == 'Officer') {
      showSnackBar('Post sent for approval successfully!', context);
    } else {
      showSnackBar('Post uploaded successfully!', context);
    }
    if (!kIsWeb) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ClientScreenLayout()));
    } else {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AdminScreenLayout()));
    }
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
      _eventTypeController.clear();
      _eventTitleController.clear();
      _eventDescriptionsController.clear();
      _eventVenueController.clear();
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
      borderSide: Divider.createBorderSide(
          context,
        color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor
      ),
    );
    return FutureBuilder<model.User?>(
      future: currentUser,
      builder: (context, AsyncSnapshot<model.User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CSPCFadeLoader());
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
                      body: Stack(
                        children: [
                          Positioned.fill(
                            child: CSPCBackground(height: MediaQuery.of(context).size.height),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [
                                  darkModeOn ? darkColor.withOpacity(0.0) : lightColor.withOpacity(0.0),
                                  darkModeOn ? darkColor : lightColor,
                                ],
                                stops: const [
                                  0.0,
                                  1.0
                                ]
                              ),
                            ),
                          ),
                          Center(
                            child: SingleChildScrollView(
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: kIsWeb ? (width > webScreenSize ? width * 0.2 : 0) : 0),
                                child: Padding(
                                  padding: const EdgeInsets.all(kIsWeb ? 8.0 : 2),
                                  child: Card(
                                    color: darkModeOn ? darkColor : lightColor,
                                    child: Padding(
                                      padding: kIsWeb ? const EdgeInsets.all(30.0) : const EdgeInsets.symmetric(horizontal: 5),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          kIsWeb ? Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons.post_add,
                                                    color: darkModeOn ? lightColor : darkColor,
                                                    size: kIsWeb ? 40 : 25,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Post an Announcement',
                                                    style: TextStyle(
                                                      fontSize: kIsWeb ? 32.0 : 24.0,
                                                      fontWeight: FontWeight.bold,
                                                      color: darkModeOn ? lightColor : darkColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ) : const SizedBox.shrink(),
                                        !kIsWeb ? const SizedBox(height: 10) : const SizedBox.shrink(),
                                         Flexible(
                                             child: Padding(
                                               padding: const EdgeInsets.symmetric(vertical: 8.0),
                                               child: Text(
                                                 'Instructions: Please fill up the required* details correctly and then post the announcement. Only one image and document can be selected. For document, only .pdf files can be uploaded. For image it can be .jpg or .png',
                                                 style: TextStyle(
                                                   fontSize: 15.0,
                                                     color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor
                                                 ),
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
                                                        labelText: '${kIsWeb ? 'Select announcement type' : 'Type'}*',
                                                        border: OutlineInputBorder(
                                                          borderSide: Divider.createBorderSide(
                                                            context,
                                                            color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,)
                                                        ),
                                                      ),
                                                      value: _eventTypeController.text.isEmpty
                                                          ? null
                                                          : _eventTypeController.text,
                                                      items: <String>['Academic', 'Non-academic']
                                                          .map((String value) {
                                                        return DropdownMenuItem<String>(
                                                          value: value,
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(value, style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
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
                                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                    child: IconButton(
                                                      onPressed: () => _selectImage(context),
                                                      icon: const Icon(Icons.add_a_photo),
                                                      tooltip: 'Add a photo',
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                    child: IconButton(
                                                      onPressed: () => _selectDocument(context),
                                                      icon: const Icon(Icons.file_present_rounded),
                                                      tooltip: 'Add a document',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ),
                                          const SizedBox(height: 10.0),
                                          kIsWeb ? Flexible(
                                            child: Row(children: [
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
                                                  labelText: 'Venue*',
                                                  textInputType: TextInputType.text,
                                                )
                                              )
                                            ]),
                                          ): Flexible(
                                            fit: FlexFit.loose,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                              Expanded(
                                                child: TextFieldInput(
                                                  textEditingController: _eventTitleController,
                                                  labelText: 'Title*',
                                                  textInputType: TextInputType.text,
                                                ),
                                              ),
                                            ]),
                                          ),
                                          !kIsWeb ? const SizedBox(height: 10.0) : const SizedBox.shrink(),
                                          !kIsWeb ? Flexible(
                                            fit: FlexFit.loose,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Expanded(
                                                flex: 2,
                                                child: TextFieldInput(
                                                  textEditingController: _eventVenueController,
                                                  labelText: 'Venue*',
                                                  textInputType: TextInputType.text,
                                                )
                                              )],
                                            ),
                                          ) : const SizedBox.shrink(),
                                          const SizedBox(height: 10.0),
                                          Flexible(
                                            child: TextFormField(
                                              style: TextStyle(color: darkModeOn ? lightColor : darkColor),
                                              controller: _eventDescriptionsController,
                                              decoration: InputDecoration(
                                                  labelText: 'Description*',
                                                  alignLabelWithHint: true,
                                                  border: outlineBorder,
                                                  focusedBorder: outlineBorder,
                                                  enabledBorder: outlineBorder,
                                                  contentPadding: const EdgeInsets.all(12),
                                              ),
                                              textCapitalization: TextCapitalization.sentences,
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
                                                  startTextEditingController: _startDateController,
                                                  endTextEditingController: _endDateController,
                                                  isDateRange: true,
                                                  labelText: 'Event Date',
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
                                                  startTextEditingController: _startTimeController,
                                                  endTextEditingController: _endTimeController,
                                                  isTimeRange: true,
                                                  labelText: 'Event Time',
                                                  textInputType: TextInputType.datetime,
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
                                                    Flexible(
                                                        child: Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(10.0),
                                                              child: Text(
                                                                  'Participants*',
                                                                  style: TextStyle(
                                                                      color: darkModeOn ? lightColor : darkColor,
                                                                      fontSize: kIsWeb ? 28 : 24,
                                                                      fontWeight: FontWeight.bold
                                                                  )),
                                                            ))),
                                                    Flexible(
                                                        child: Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Text(
                                                                  'Check all the type of participants that will be involved.',
                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                    color: darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor
                                                                  )),
                                                            ))),
                                                    // participants (Checkbox that adds to a local array of participants)
                                                    kIsWeb ? Flexible(
                                                      fit: FlexFit.loose,
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          Expanded(child: _buildParticipant('Program', programParticipants)),
                                                          Expanded(child: _buildParticipant('Department', departmentParticipants)),
                                                        ],
                                                      ),
                                                    ) : Flexible(
                                                      fit: FlexFit.loose,
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            _buildParticipant('Program', programParticipants),
                                                            _buildParticipant('Department', departmentParticipants),
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
                                                  await _post(currentUser!.userType!);
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
                                                  : const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.post_add, color: lightColor),
                                                      SizedBox(width: 10),
                                                      Text(
                                                          'Create a New Announcement',
                                                          style: TextStyle(
                                                            color: lightColor,
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

  _buildParticipant(String type, List<String> participants) {
    final darkModeOn = Provider.of<DarkModeProvider>(context).darkMode;
    return kIsWeb ? Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            type,
            style: TextStyle(fontSize: kIsWeb ? 20 : 12, fontWeight: FontWeight.bold, color: darkModeOn ? lightColor : darkColor,),
          ),
        ), ...participants.map(
              (participant) => CheckboxListTile(
            activeColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
            checkColor: darkModeOn ? darkColor : lightColor,
            title: Text(participant, style: TextStyle(color: darkModeOn ? lightColor : darkColor)),
            value: selectedParticipants[type.toLowerCase()]?.contains(participant),
            onChanged: (bool? value) {
              setState(() {
                String? dept = programDepartmentMap[participant];
                if (value!) {
                  selectedParticipants[type.toLowerCase()]?.add(participant);
                  if (type.toLowerCase() == 'program'
                      && !selectedParticipants['department']!.contains(dept)) {
                    selectedParticipants['department']?.add(dept!);
                  }
                } else {
                  selectedParticipants[type.toLowerCase()]?.remove(participant);
                  if (type.toLowerCase() == 'program'
                      && selectedParticipants['program']!
                        .where((program) => programDepartmentMap[program] == dept)
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
                      if (!selectedParticipants['program']!.contains(program)) {
                        selectedParticipants['program']?.add(program);
                      }
                    }
                  } else {
                    for (var program in associatedPrograms) {
                      if (selectedParticipants['program']!.contains(program)) {
                        selectedParticipants['program']?.remove(program);
                      }
                    }
                  }
                }
              });
            },
          ),
        ).toList(),
      ],
    ) : Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            type,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkModeOn ? lightColor : darkColor,),
          ),
        ),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: participants.map(
                (participant) => CheckboxListTile(
              activeColor: darkModeOn ? darkModePrimaryColor : lightModePrimaryColor,
              checkColor: darkModeOn ? darkColor : lightColor,
              title: Text(participant, style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
              value: selectedParticipants[type.toLowerCase()]?.contains(participant),
              onChanged: (bool? value) {
                setState(() {
                  String? dept = programDepartmentMap[participant];
                  if (value!) {
                    selectedParticipants[type.toLowerCase()]?.add(participant);
                    if (type.toLowerCase() == 'program'
                        && !selectedParticipants['department']!.contains(dept)) {
                      selectedParticipants['department']?.add(dept!);
                    }
                  } else {
                    selectedParticipants[type.toLowerCase()]?.remove(participant);
                    if (type.toLowerCase() == 'program'
                        && selectedParticipants['program']!
                          .where((program) => programDepartmentMap[program] == dept)
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
                        if (!selectedParticipants['program']!.contains(program)) {
                          selectedParticipants['program']?.add(program);
                        }
                      }
                    } else {
                      for (var program in associatedPrograms) {
                        if (selectedParticipants['program']!.contains(program)) {
                          selectedParticipants['program']?.remove(program);
                        }
                      }
                    }
                  }
                });
              },
            ),
          ).toList(),
        ),
      ],
    );
  }
}

