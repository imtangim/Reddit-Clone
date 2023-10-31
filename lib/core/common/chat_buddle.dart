import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool leftOrRight;
  const ChatBubble(
      {super.key, required this.message, required this.leftOrRight});

  @override
  Widget build(BuildContext context) {
    
    BorderRadiusGeometry all = BorderRadius.circular(20);

    return Container(
      // margin: EdgeInsets.only(left: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: all, //leftOrRight ? left : right,
        color: Colors.blue,
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
