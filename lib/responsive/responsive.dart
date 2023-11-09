import 'package:flutter/material.dart';

class ResponsiveScreen extends StatelessWidget {
  final Widget child;
  const ResponsiveScreen({super.key,required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:const  BoxConstraints(
        maxWidth: 600,
        
      ),
      child: child,
    );
  }
}
