import 'package:flutter/material.dart';
import 'package:syc/utils/app_colors.dart';

class CustomNotFound extends StatelessWidget {
  final String text;
  final Color textColor;
  final String imagePath;
  final VoidCallback? onBack;
  final String? backText;

  const CustomNotFound({
    super.key,
    required this.text,
    required this.textColor,
    required this.imagePath,
    this.onBack,
    this.backText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 200, height: 200),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: textColor),
          ),
          const SizedBox(height: 16),
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.brown1,
                    borderRadius: BorderRadius.circular(64),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    backText ?? 'Kembali',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
