import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

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

pickDocument() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg'],
  );

  if (result != null) {
    PlatformFile platformFile = result.files.first;
    File file = File(platformFile.path!);
    return file;
  } else {
    if (kDebugMode) {
      print('No Document Selected');
    }
    return null;
  }
}