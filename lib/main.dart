import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:student_event_calendar/platforms/admin.dart';
import 'package:student_event_calendar/platforms/client.dart';

void main() {
  kIsWeb ? runApp(const Admin()) : runApp(const Client());
}
