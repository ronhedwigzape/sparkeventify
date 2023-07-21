import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/services.dart';

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
    allowedExtensions: ['pdf', 'doc', 'xls', 'ppt', 'txt'],
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

Future<Uint8List> downloadFile(String url) async {
  http.Response response = await http.get(Uri.parse(url));
  final bytes = response.bodyBytes;
  return bytes;
}

String? getFileExtension(Uint8List uint8list){
  String? mimeStr = lookupMimeType('', headerBytes: uint8list);
  return extensionFromMime(mimeStr!);
}


Future<void> downloadAndOpenFile(String url, String fileName) async {
  // Download file data
  Uint8List fileData;
  String? fileExtension;

  try {
    fileData = await downloadFile(url);
    fileExtension = getFileExtension(fileData);
  } on PlatformException {
    throw ("Can't download or decode file data");
  }

  if(fileExtension == null) {
    throw ("Can't determine the file extension");
  }

  if (kIsWeb) {
    // Flutter web code to trigger a download
    final base64 = base64Encode(fileData);
    final anchor = html.AnchorElement(
        href: 'data:application/octet-stream;base64,$base64'
    )..setAttribute('download', '$fileName.$fileExtension')
      ..click();
  } else {
    // Android/IOS code to store the file in temp directory and open it
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/$fileName.$fileExtension').writeAsBytes(fileData);

    try {
      OpenFile.open(file.path);
    } on PlatformException {
      throw ('Could not open file at ${file.path}');
    }
  }
}