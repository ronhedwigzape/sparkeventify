import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// Function to pick an image from the specified source
pickImage(ImageSource source) async {
  final ImagePicker picker = ImagePicker();

  XFile? file = await picker.pickImage(source: source);

  if (file != null) {
    return await file.readAsBytes();
  } else {
    if (kDebugMode) {
      print('No Image Selected');
    }
    return null;
  }
}

// Function to pick a document file
Future<Uint8List?> pickDocument() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'],
  );

  if (result != null) {
    PlatformFile file = result.files.first;

    if (kIsWeb) {
      // In Flutter web, the path is always null
      return file.bytes;
    } else {
      // While in Android or iOS, you can access the path
      return File(file.path!).readAsBytes();
    }
  } else {
    if (kDebugMode) {
      print('No Document Selected');
    }
    return null; // No file selected
  }
}
