import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CircleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? iconColor;
  final double size;
  final double padding;
  final Color? backgroundColor;

  const CircleButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
    this.iconColor = Colors.black,
    this.size = 40,
    this.padding = 8,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(color: backgroundColor ?? AppColors.primary.withAlpha(20), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: size - padding * 2),
      ),
    );
  }
}
