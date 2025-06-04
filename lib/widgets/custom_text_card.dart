import 'package:flutter/material.dart';
import 'package:syc/utils/app_colors.dart';

class CustomTextCard extends StatelessWidget {
  final String text;
  final String value;
  final Color backgroundColor;

  const CustomTextCard({
    Key? key,
    required this.text,
    required this.value,
    this.backgroundColor = AppColors.brown1, // Default brown color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Text(
                value.isEmpty ? '(Tidak ada komentar)' : value,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
