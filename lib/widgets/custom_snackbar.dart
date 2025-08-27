import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

DateTime? _lastSnackBarTime;

void showCustomSnackBar(
  BuildContext context,
  String message, {
  bool isSuccess = false,
  Duration duration = const Duration(seconds: 5),
  bool showDismissButton = true,
  bool showAppIcon = false, // true untuk menampilkan app icon di kiri
}) {
  // Batasi agar snackbar hanya muncul sekali dalam 3 detik
  final now = DateTime.now();
  if (_lastSnackBarTime != null &&
      now.difference(_lastSnackBarTime!) < const Duration(seconds: 3)) {
    return;
  }
  _lastSnackBarTime = now;

  if (!context.mounted) return;
  final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
  if (scaffoldMessenger == null) return;
  scaffoldMessenger.showSnackBar(
    SnackBar(
      content:
          showDismissButton
              ? Row(
                children: [
                  if (showAppIcon) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.asset(
                        'assets/logos/appicon5.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showAppIcon) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.asset(
                        'assets/logos/appicon5.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ],
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      duration: duration,
      backgroundColor: AppColors.black1,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      action:
          showDismissButton
              ? SnackBarAction(
                label: 'Tutup',
                textColor: AppColors.brown1,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                },
              )
              : null,
    ),
  );
}

/// Cara penggunaan:
/// 
/// showCustomSnackBar(
///   context,
///   'Pesan berhasil!',
///   isSuccess: true,
///   duration: Duration(seconds: 3),
///   showDismissButton: false,
///   showAppIcon: true, // tampilkan app icon di kiri