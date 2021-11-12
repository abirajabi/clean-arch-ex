import 'package:flutter/material.dart';

class MessageDisplay extends StatelessWidget {
  final String message;

  MessageDisplay({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Third of the size of the screen
      height: MediaQuery.of(context).size.height / 3,
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            message,
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
