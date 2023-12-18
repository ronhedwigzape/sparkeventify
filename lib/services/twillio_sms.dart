import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class TwillioSmsService {
  
  Future<String?> sendSMS(String to, String body) async {
    var twillioAccountSid = "ACad034839ccef3d2399c059c1c4861506";
    var twillioAuthToken = "cf35b4cde52903e879dd8d540f5d0ca3";
    var twillioPhoneNumber = "your_twilio_phone_number";
    var authn = 'Basic ${base64Encode(utf8.encode('$twillioAccountSid:$twillioAuthToken'))}';

    var url = 'https://api.twilio.com/2010-04-01/Accounts/$twillioAccountSid/Messages.json';

    var response = await http.post(
      Uri.parse(url), // parse to Uri
      headers: {'Authorization': authn},
      body: {'To': '+$to', 'From': twillioPhoneNumber, 'Body': body}, 
    );

    if (kDebugMode) {
      print('Response status: ${response.statusCode}');
    }
    if (kDebugMode) {
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (kDebugMode) {
        return 'Message sent successfully.';
      }
    } else {
      if (kDebugMode) {
        return 'Failed to send message. Status code: ${response.statusCode}.';
      }
    }
    return null;
  }

}
