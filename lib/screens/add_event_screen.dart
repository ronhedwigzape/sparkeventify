import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/models/user.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  Future<User> currentUser = AuthMethods().getUserDetails();
  Uint8List? documentFile;
  Uint8List? _imageFile;
  bool _isLoading = false;

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
                    documentFile = file;
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

  post() async {
    if (kDebugMode) {
      print('post function started');
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (kDebugMode) {
        print('trying to add event');
      }
      String currentUser = await AuthMethods().getCurrentUserUid();
      if (_imageFile != null && documentFile != null) {
        String response = await FireStoreEventMethods().addEvent(
            'Test Event',
            _imageFile!,
            'Test Event Description',
            currentUser,
            documentFile!,
            DateTime.now().toString(),
            'Test Event Type',
            'Pending');

        if (kDebugMode) {
          print('addEvent response: $response');
        }

        // Check if the widget is still in the widget tree
        if (response == 'Success') {
          onPostSuccess();
        } else {
          onPostFailure(response);
        }

        return response;
      } else {
        if (kDebugMode) {
          print('imageFile or documentFile is null');
        }
        setState(() {
          _isLoading = false;
        });
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
          return currentUser?.userType == 'Admin' || currentUser?.userType == 'Staff'
              ? Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => _selectImage(context),
                          icon: const Icon(Icons.upload),
                        ),
                        TextButton(
                            onPressed: () => _selectDocument(context),
                            style: TextButton.styleFrom(
                              foregroundColor: whiteColor,
                              backgroundColor: blueColor,
                            ),
                            child: const Text('Pick Document')),
                        Center(
                          child: InkWell(
                            onTap: post,
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
                                        'Post',
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
