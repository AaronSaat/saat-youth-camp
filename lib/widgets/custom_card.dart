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
    this.iconBackgroundColor = AppColors.brown1,
    this.showCheckIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 70,
          margin: const EdgeInsets.symmetric(vertical: 8),
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
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    showCheckIcon ? Icons.check : icon,
                    color: Colors.white,
                    size:
                        (showCheckIcon || icon == Icons.arrow_outward_rounded)
                            ? 64
                            : 48,
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text(
                    text,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
