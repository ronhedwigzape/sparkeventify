import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

Future<String> uploadFileToStorage(String childName, File file) async {
  Reference ref = _storage.ref().child(childName).child(_auth.currentUser!.uid);
  String id = DateTime.now().millisecondsSinceEpoch.toString();
  ref = ref.child(id);
  // Determine the MIME type of the file
  String mimeType = lookupMimeType(file.path)!;
  // Create metadata with the correct contentType
  SettableMetadata metadata = SettableMetadata(contentType: mimeType);
  // Upload the file with the metadata
  UploadTask uploadTask = ref.putFile(file, metadata);
  TaskSnapshot snap = await uploadTask;
  String downloadUrl = await snap.ref.getDownloadURL();
  return downloadUrl;
}

Future<String> uploadImageToStorage(
    String childName, Uint8List file, bool isPost) async {
  Reference ref =
      _storage.ref().child(childName).child(_auth.currentUser!.uid);
  if (isPost) {
    String id = const Uuid().v1();
    ref = ref.child(id);
  }
  UploadTask uploadTask = ref.putData(file);
  TaskSnapshot snap = await uploadTask;
  String downloadUrl = await snap.ref.getDownloadURL();
  return downloadUrl;
  }
}
