import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CspcLogo extends StatelessWidget {
  const CspcLogo({super.key, required this.height, });
  final double height;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data != null) {
            return Image.memory(
              snapshot.data as Uint8List,
              height: height.toDouble(),
            );
          } else {
            return const Text('Error loading image');
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<Uint8List> loadImage() async {
    try {
      final byteData = await rootBundle.load('assets/images/cspc_logo.png');
      return byteData.buffer.asUint8List();
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print('Error loading image: $e');
        print('Stacktrace: $stacktrace');
      }
      return Uint8List(0); 
    }
  }
}
