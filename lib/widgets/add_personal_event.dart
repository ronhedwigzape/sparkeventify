import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_event_calendar/models/user.dart' as model;
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_personal_event_methods.dart';
import 'package:student_event_calendar/resources/firestore_user_methods.dart';
import 'package:student_event_calendar/services/firebase_notifications.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';
import 'package:student_event_calendar/widgets/cspc_spinner.dart';
import 'package:student_event_calendar/widgets/search_user_delegate.dart';
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
  FireStoreUserMethods userMethods = FireStoreUserMethods();
  Future<model.User?> currentUser = AuthMethods().getCurrentUserDetails();
  List<model.User> invitedUsers = [];
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
                        SnackBar(content: Text('New image is uploaded!'));
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
                        SnackBar(content: Text('New document is uploaded!'));
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
  Future<model.User?> _showSearch(BuildContext context, List<model.User> users) async {
    return await showSearch(
      context: context,
      delegate: SearchUserDelegate(users),
    );
  }

  void _showUserSearch(BuildContext context) async {
    List<model.User> users = await userMethods.getAllInvitableUsers();
    model.User? selectedUser = await _showSearch(context, users);
    if (selectedUser != null) {
      setState(() {
        invitedUsers.add(selectedUser);
      });
    }
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
          _personalEventVenueController.text.isNotEmpty) {
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
        
        // Null safety check for currentUser
        String? uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          // Add the personal event to the database
          String response = await FireStorePersonalEventMethods().postPersonalEvent(
              _personalEventTitleController.text,
              _imageFile,
              _personalEventDescriptionsController.text,
              uid,
              _documentFile,
              startDatePart,
              endDatePart,
              startTime12,
              endTime12,
              _personalEventVenueController.text,
              _personalEventTypeController.text,
              'Upcoming',
              false);

          // After the event is created, send a notification to each invited user.
          for (var user in invitedUsers) {
            String message = 'You have been invited to the event "${_personalEventTitleController.text}" '
                            'which will take place from ${_startDateController.text} ${_startTimeController.text} '
                            'to ${_endDateController.text} ${_endTimeController.text} at ${_personalEventVenueController.text}. '
                            'Event details: ${_personalEventDescriptionsController.text}';
            await FirebaseNotificationService().sendNotificationToUser(
              uid, user.uid!, 'Event Invitation', message
            );
          }

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
          // Handle the case when uid is null
          print('User is not logged in');
        }
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
          return const Center(child: CSPCFadeLoader());
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
                  elevation: 0,
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
                      darkModeOn ? darkModeTertiaryColor : lightModeTertiaryColor,
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
                                                  Text(value, style: TextStyle(color: darkModeOn ? lightColor : darkColor),),
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
                                      child: TextFieldInput(
                                        textEditingController:
                                            _personalEventVenueController,
                                        labelText: 'Venue*',
                                        textInputType: TextInputType.text,
                                      )
                                    )],
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Flexible(
                                  child: TextFormField(
                                    style: TextStyle(color: darkModeOn ? lightColor : darkColor),
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
                                const SizedBox(height: 20,),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_to_queue, size: 15,),
                                        SizedBox(width: 5,),
                                        Text('Invite User/s'),
                                      ],
                                    ),
                                    onPressed: () => _showUserSearch(context),
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                // New widget to display the invited users
                                ...invitedUsers.map((user) => ListTile(
                                  title: Text(user.profile?.fullName ?? 'Unknown'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: red,),
                                    onPressed: () {
                                      setState(() {
                                        invitedUsers.remove(user);
                                      });
                                    },
                                  ),
                                )).toList(),
                                const SizedBox(height: 20.0),
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
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(darkModeOn ? darkColor : lightColor),
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
                                const SizedBox(height: 20.0)
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
}
