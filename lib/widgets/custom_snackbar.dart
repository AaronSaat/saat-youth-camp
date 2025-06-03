import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  bool isSuccess = false,
}) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w300,
          fontSize: message.length <= 30 ? 14 : 12,
        ),
      ),
      duration: const Duration(seconds: 8),
      backgroundColor: isSuccess ? AppColors.accent : AppColors.black1,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: AppColors.brown1,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
