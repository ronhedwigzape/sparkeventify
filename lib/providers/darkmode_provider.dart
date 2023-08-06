import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// A class that changes and notifies listeners about theme changes
class DarkModeProvider with ChangeNotifier {
  // The key string for the Firebase Firestore document
  final String key = "darkMode";

  // Declaration of a boolean that will store the state of the theme, default is false
  late bool _darkMode;

  // A public getter for _darkMode
  bool get darkMode => _darkMode;

  // Constructor
  DarkModeProvider() {
    _darkMode = false;
    // Load the theme setting from Firebase
    _loadFromFirebase();
  }

  // Method to toggle the theme
  toggleTheme() {
    // Reverse the current state
    _darkMode = !_darkMode;
    // Save the new setting to Firebase
    _saveToFirebase();
    // Notify all listeners
    notifyListeners();
  }

  // Method to load the theme setting from Firebase
  _loadFromFirebase() async {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    // If the user is authenticated
    if(currentUser != null) {
      // Get the current user's document from Firebase
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

      // If the document exists
      if(snapshot.exists){
        // Get the data from the document
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        // If the document contains the theme key
        if(data.containsKey(key)){
          // Update the theme state with the saved value
          _darkMode = data[key] ?? false;
        } else {
          // If the document does not contain the key, print a debug message
          if (kDebugMode) {
            print('$key does not exist on this document');
          }
        }
      }
      else {
        // If the document does not exist, print a debug message
        if (kDebugMode) {
          print('Document does not exist');
        }
      }
      // Notify all listeners, When you call notifyListeners() in the toggleTheme() and _loadFromFirebase() methods, it's telling any widgets that are listening to this DarkModeProvider that the _darkMode value has changed.
      notifyListeners();
    }
    else {
      // If the user is not authenticated, print a debug message
      if (kDebugMode) {
        print('User not authenticated');
      }
    }
  }

  // Method to save the current theme setting to Firebase
  _saveToFirebase() async {
    // Save the current theme setting to the current user's document in Firebase
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({key: _darkMode});
  }
}
