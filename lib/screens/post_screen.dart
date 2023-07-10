import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/user.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';
import 'package:student_event_calendar/widgets/text_field_input.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionsController = TextEditingController();
  final TextEditingController _eventVenueController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  final TextEditingController _eventParticipantsController = TextEditingController();
  final TextEditingController _eventStatusController = TextEditingController();
  Future<User> currentUser = AuthMethods().getUserDetails();
  Uint8List? _documentFile;
  Uint8List? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _eventTypeController.dispose();
    _eventNameController.dispose();
    _eventDescriptionsController.dispose();
    _eventVenueController.dispose();
    _eventDateController.dispose();
    _eventTimeController.dispose();
    _eventParticipantsController.dispose();
    _eventStatusController.dispose(); 
  }
  
  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Upload Image'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _imageFile = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _imageFile = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _selectDocument(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Upload Document'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose Files'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickDocument();
                  setState(() {
                    _documentFile = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancel'),
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
      if (_imageFile != null && _documentFile != null) {
        String response = await FireStoreEventMethods().addEvent(
            'Test Event',
            _imageFile!,
            'Test Event Description',
            currentUser,
            _documentFile!,
            DateTime.now().toString(),
            ['Test Attendee 1', 'Test Attendee 2'],
            'Test Location',
            'Test Event Type',
            'Pending');

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
          print('imageFile or documentFile is null!');
        }
        setState(() {
          _isLoading = false;
        });

        // Show a snackbar if the image and document are not loaded
        mounted
            ? showSnackBar('Please upload an image and a document.', context)
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
    clearImage();
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

  void clearImage() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              ? Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Post an Event/Announcement',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                       Row(
                         children: [
                           Expanded(
                             child: DropdownButton<String>(
                                hint: const Text('Select event/announcement type'),
                                value: _eventTypeController.text.isEmpty ? null : _eventTypeController.text,
                                items: <String>['Academic', 'Non-academic']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),  
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _eventTypeController.text = newValue!;
                                  });
                                }
                              ),
                           ),
                            IconButton(
                              onPressed: () => _selectImage(context),
                              icon: const Icon(Icons.add_a_photo),
                              tooltip: 'Add a photo',
                            ),
                            IconButton(
                              onPressed: () => _selectDocument(context),
                              icon: const Icon(Icons.file_present_rounded),
                              tooltip: 'Add a document',
                            ),
                         ],
                       ),
                        const SizedBox(height: 10.0),
                        TextFieldInput(
                          textEditingController: _eventNameController,
                          hintText: 'Event Name',
                          textInputType: TextInputType.text,
                        ),
                        const SizedBox(height: 10.0),
                        TextFieldInput(
                          textEditingController: _eventDescriptionsController,
                          hintText: 'Event Description',
                          textInputType: TextInputType.text,
                        ),
                        const SizedBox(height: 10.0),
                        TextFieldInput(
                          textEditingController: _eventVenueController,
                          hintText: 'Event Venue',
                          textInputType: TextInputType.text,
                        ),
                        const SizedBox(height: 10.0),
                        TextFieldInput(
                          textEditingController: _eventDateController,
                          hintText: 'Event Date',
                          textInputType: TextInputType.datetime,
                        ),
                        const SizedBox(height: 10.0),
                        TextFieldInput(
                          textEditingController: _eventTimeController,
                          hintText: 'Event Time',
                          textInputType: TextInputType.datetime,
                        ),
                        const SizedBox(height: 10.0),
                        TextFieldInput(
                          textEditingController: _eventParticipantsController,
                          hintText: 'Event Participants',
                          textInputType: TextInputType.text,
                        ),
                        const SizedBox(height: 10.0),
                        TextFieldInput(
                          textEditingController: _eventStatusController,
                          hintText: 'Event Status',
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                decoration: const ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  color: blueColor,
                                ),
                                child: _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                whiteColor),
                                      ))
                                    : const Text(
                                        'Create a New Announcement',
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox();
        }
      },
    );
  }
}
