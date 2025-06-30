import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  bool isSuccess = false,
}) {
  if (!context.mounted) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger == null) return;
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: AppColors.black1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppColors.brown1,
          onPressed: () {
            scaffoldMessenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  });
}

/// Cara penggunaan:
/// 
/// showCustomSnackBar(context, 'Pesan berhasil!', isSuccess: true);
/// showCustomSnackBar(context, 'Terjadi kesalahan', isSuccess: false);