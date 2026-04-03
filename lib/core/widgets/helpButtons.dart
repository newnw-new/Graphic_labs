import 'package:flutter/material.dart';

class HelpButtons extends StatelessWidget {
  final VoidCallback? onClear;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final IconData clearIcon;
  final IconData backIcon;
  final IconData forwardIcon;
  final Widget child;

  const HelpButtons({
    super.key,
    this.onClear,
    this.onBack,
    this.onForward,
    this.clearIcon = Icons.delete,
    this.backIcon = Icons.arrow_back,
    this.forwardIcon = Icons.arrow_forward,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Row(
          children: [
            IconButton(onPressed: onClear, icon: Icon(clearIcon)),
            const SizedBox(width: 8),
            IconButton(onPressed: onBack, icon: Icon(backIcon)),
            const SizedBox(width: 8),
            IconButton(onPressed: onForward, icon: Icon(forwardIcon)),
          ],
        ),
      ],
    );
  }
}