import "package:flutter/material.dart";

// Vertical Spacer
class VerticalSpacer extends StatelessWidget {
  const VerticalSpacer([this.height = 8.0, Key? key]) : super(key: key);
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

// Horizontal Spacer
class HorizontalSpacer extends StatelessWidget {
  const HorizontalSpacer([this.width = 8.0, Key? key]) : super(key: key);
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
