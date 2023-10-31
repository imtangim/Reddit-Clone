import 'package:flutter/material.dart';

class Errortext extends StatelessWidget {
  final String e;
  const Errortext({super.key, required this.e});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(e),
    );
  }
}
