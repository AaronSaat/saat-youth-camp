import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomCheckboxCard extends StatelessWidget {
  final String text;
  final String? value;
  final Color backgroundColor;
  final TextStyle? textStyle;

  const CustomCheckboxCard({
    Key? key,
    required this.text,
    this.value,
    this.backgroundColor = AppColors.brown1, // Default brown1
    this.textStyle = const TextStyle(fontSize: 16, color: Colors.white),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isYes = (value?.toLowerCase() == 'ya');

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom checkbox style icon
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child:
                    isYes
                        ? const Icon(Icons.check, size: 20, color: Colors.black)
                        : null,
              ),
            ),
            // Gunakan Expanded/Flexible hanya jika ingin teks mengambil sisa ruang.
            // Jika ingin teks hanya selebar kontennya, gunakan widget Text biasa.
            Expanded(child: Text(text, style: textStyle)),
          ],
        ),
      ),
    );
  }
}
