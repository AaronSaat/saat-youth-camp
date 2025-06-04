import 'package:flutter/material.dart';

class CustomSliderCard extends StatelessWidget {
  final String text;
  final double value;
  final double max;

  const CustomSliderCard({Key? key, required this.text, required this.value, this.max = 6}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color cardColor = const Color(0xFF8D6E63); // Example brown1

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${value.toStringAsFixed(1)} dari ${max.toInt()}',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
