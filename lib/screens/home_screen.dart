import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_event_calendar/resources/auth_methods.dart';
import 'package:student_event_calendar/resources/firestore_event_methods.dart';
import 'package:student_event_calendar/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_event_calendar/utils/file_pickers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<String> currentUser = AuthMethods().getCurrentUserType();
  File? documentFile;
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
                  File? file = await pickDocument();
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
            '2021-10-10 10:10:10',
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
        return 'imageFile or documentFile is null';
      }
    } catch (err) {
      if (kDebugMode) {
        print('error caught: $err');
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
    return FutureBuilder<String>(
      future: currentUser,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          String? currentUserType = snapshot.data;
          return currentUserType == 'Admin' || currentUserType == 'Student'
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
