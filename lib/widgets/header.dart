import 'package:flutter/material.dart';
import '../theme.dart';

/// Reusable dark gradient header (155deg) used across many screens.
class DarkHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final List<Widget> blobs;
  final Gradient? gradient;
  const DarkHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 28, 22, 36),
    this.blobs = const [],
    this.gradient,
  });
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(gradient: gradient ?? K.gHeader),
        child: Stack(children: [...blobs, child]),
      ),
    );
  }
}

/// Soft decorative circle blob for headers.
class Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double? top, left, right, bottom;
  const Blob(this.size, this.color, {super.key, this.top, this.left, this.right, this.bottom});
  @override
  Widget build(BuildContext context) => Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      );
}
