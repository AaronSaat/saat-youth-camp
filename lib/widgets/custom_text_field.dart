import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final int maxLines;
  final Color? labelColor;
  final Color? textColor;
  final Color? fillColor;
  final bool enabled;
  final Widget? suffixIcon;
  final double? labelFontSize;
  final TextStyle? labelTextStyle;
  final TextStyle? inputTextStyle;
  final TextStyle? hintTextStyle;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
    this.labelColor,
    this.textColor,
    this.fillColor,
    this.enabled = true,
    this.suffixIcon,
    this.labelFontSize,
    this.labelTextStyle,
    this.inputTextStyle,
    this.hintTextStyle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              labelTextStyle ??
              TextStyle(
                fontSize: labelFontSize ?? 18,
                fontWeight: FontWeight.bold,
                color: labelColor ?? Colors.black,
              ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          style: inputTextStyle ?? TextStyle(color: textColor ?? Colors.black),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                hintTextStyle ?? TextStyle(color: textColor ?? Colors.black),
            filled: true,
            fillColor: fillColor ?? Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
