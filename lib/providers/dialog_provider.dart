import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DialogProvider with ChangeNotifier {
  bool _dialogShown = false;

  DialogProvider() {
    _loadDialogShown();
  }

  bool get dialogShown => _dialogShown;

  Future<void> _loadDialogShown() async {
    final prefs = await SharedPreferences.getInstance();
    _dialogShown = prefs.getBool('dialogShown') ?? false;
    notifyListeners();
  }

  Future<void> setDialogShown(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('dialogShown', value);
    _dialogShown = value;
    notifyListeners();
  }
}
