import 'package:flutter/material.dart';

class ColorPage extends StatelessWidget {
  final Color color;

  ColorPage(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}
