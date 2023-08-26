import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

Future<void> sendSMS(String to, String from, String body) async {
  var twillioAccountSid = dotenv.env['TWILLIO_ACCOUNT_SID']!;
  var twillioAuthToken = dotenv.env['TWILLIO_AUTH_TOKEN']!;
  var authn = 'Basic ${base64Encode(utf8.encode('$twillioAccountSid:$twillioAuthToken'))}';

  var url = 'https://api.twilio.com/2010-04-01/Accounts/$twillioAccountSid/Messages.json';

  var response = await http.post(url as Uri,
    headers: {'Authorization': authn},
    body: {'To': '+$to', 'From': '+$from', 'Body': body},
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    if (kDebugMode) {
      print('Message sent successfully.');
    }
  } else {
    if (kDebugMode) {
      print('Failed to send message. Status code: ${response.statusCode}.');
    }
  }
}
