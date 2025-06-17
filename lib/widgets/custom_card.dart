import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconBackgroundColor;
  final bool showCheckIcon;

  const CustomCard({
    Key? key,
    required this.text,
    required this.icon,
    required this.onTap,
    Color? iconBackgroundColor,
    this.showCheckIcon = false,
  }) : iconBackgroundColor = showCheckIcon ? Colors.green : (iconBackgroundColor ?? AppColors.brown1),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    double setHeight = text.length > 50 ? 100 : 70;
    double setwidth = text.length > 50 ? 100 : 70;
    if (text.length > 50) {
      // Tipe Stack untuk text panjang
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              height: setHeight,
              margin: const EdgeInsets.only(top: 8, bottom: 8, left: 32),
              decoration: BoxDecoration(
                color: AppColors.grey3,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 32), // Placeholder for icon space
                  Expanded(
                    child: ListTile(title: Text(text, style: const TextStyle(color: Colors.black, fontSize: 16))),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 25,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(color: iconBackgroundColor, shape: BoxShape.circle),
                child: Icon(
                  showCheckIcon ? Icons.check : icon,
                  color: Colors.white,
                  size: (showCheckIcon || icon == Icons.arrow_outward_rounded) ? 64 : 48,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Tipe Stack untuk text pendek
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              height: setHeight,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.grey3,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(70),
                  bottomLeft: Radius.circular(70),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Container(
                      decoration: BoxDecoration(color: iconBackgroundColor, shape: BoxShape.circle),
                      child: Icon(
                        showCheckIcon ? Icons.check : icon,
                        color: Colors.white,
                        size: (showCheckIcon || icon == Icons.arrow_outward_rounded) ? 64 : 48,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(text, style: const TextStyle(color: Colors.black, fontSize: 16)),
                      onTap: onTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
