import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to upload a file to storage and return the download URL
  Future<String> uploadFileToStorage(String childName, Uint8List file) async {
    Reference ref = _storage
        .ref()
        .child(childName)
        .child(_auth.currentUser!.uid)
        .child(DateTime.now().millisecondsSinceEpoch.toString());

    // Upload the Uint8List data with putData method
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snap = await uploadTask.whenComplete(() => null);
    String downloadUrl = await snap.ref.getDownloadURL();

    return downloadUrl;
  }

  // Method to upload an image to storage and return the download URL
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    Reference ref = _storage.ref().child(childName).child(_auth.currentUser!.uid);

    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();

    return downloadUrl;
  }

  // Method to delete a file from storage
  Future<void> deleteFileFromStorage(String filePath) async {
    Reference ref = _storage.ref(filePath);
    await ref.delete();
  }

  // Method to delete an image from storage
  Future<void> deleteImageFromStorage(String filePath) async {
    Reference ref = _storage.ref(filePath);
    await ref.delete();
  }
  
}
