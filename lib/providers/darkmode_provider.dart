import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DarkModeProvider with ChangeNotifier {
  final String key = "darkMode";
  late bool _darkMode;
  bool get darkMode => _darkMode;

  DarkModeProvider() {
    _darkMode = false;
    _loadFromFirebase();
  }

  toggleTheme() {
    _darkMode = !_darkMode;
    _saveToFirebase();
    notifyListeners();
  }


// Load the dark mode setting from Firebase
  _loadFromFirebase() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if(snapshot.exists){
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if(data.containsKey(key)){
          _darkMode = data[key] ?? false;
        } else{
          if (kDebugMode) {
            print('$key does not exist on this document');
          }
        }
      }
      else{
        if (kDebugMode) {
          print('Document does not exist');
        }
      }
      notifyListeners();
    }
    else {
      if (kDebugMode) {
        print('User not authenticated');
      }
    }
  }


  // Save the dark mode setting to Firebase
  _saveToFirebase() async {
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({key: _darkMode});
  }
}
