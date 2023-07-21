import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

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
  Uint8List fileData = await downloadFile(url);

  String? fileExtension = getFileExtension(fileData);

  if(fileExtension == null)
  {
    throw ("Can't determine the file extension");
  }

  // Get the temporary directory.
  final tempDir = await getTemporaryDirectory();

  // Write the file.
  File file = await File('${tempDir.path}/$fileName.$fileExtension').writeAsBytes(fileData);

  // Open file with the native viewer
  OpenFile.open(file.path);
}
