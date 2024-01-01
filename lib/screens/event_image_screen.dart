import 'package:flutter/material.dart';

class EventImageScreen extends StatelessWidget {
  final String imageUrl;
  final String title;

  const EventImageScreen({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: imageUrl.isNotEmpty ? Image.network(imageUrl) : Text('No image available'),
      ),
    );
  }
}