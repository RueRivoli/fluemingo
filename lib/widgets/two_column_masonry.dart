import 'package:flutter/material.dart';

/// Lays children out in two side-by-side columns by alternating index
/// (even → left, odd → right).
///
/// The columns are independent, so a shorter card never forces a vertical
/// gap to keep rows aligned — cards stack tightly within each column and the
/// two columns are intentionally *not* aligned to each other.
///
/// Children are expected to carry their own bottom spacing
/// (`VocabularyItemCard` already has a 12px bottom margin).
class TwoColumnMasonry extends StatelessWidget {
  final List<Widget> children;

  /// Horizontal gap between the two columns.
  final double spacing;

  const TwoColumnMasonry({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final left = <Widget>[];
    final right = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      (i.isEven ? left : right).add(children[i]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: left,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: right,
          ),
        ),
      ],
    );
  }
}
