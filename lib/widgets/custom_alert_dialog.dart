import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? cancelText; // ubah jadi nullable
  final String confirmText;
  final VoidCallback? onCancel; // ubah jadi nullable
  final VoidCallback onConfirm;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    this.cancelText, // tidak required
    required this.confirmText,
    this.onCancel, // tidak required
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(title, style: TextStyle(color: AppColors.brown1, fontWeight: FontWeight.bold)),
      content: Text(content, style: TextStyle(color: AppColors.brown1, fontWeight: FontWeight.w400)),
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: Text(cancelText!),
          ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.brown1, foregroundColor: AppColors.secondary),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

// Cara penggunaan:
// showDialog(
//   context: context,
//   builder: (context) => CustomAlertDialog(
//     title: 'Judul',
//     content: 'Isi pesan',
//     cancelText: 'Batal',
//     confirmText: 'OK',
//     onCancel: () => Navigator.of(context).pop(),
//     onConfirm: () {
//       // aksi konfirmasi
//       Navigator.of(context).pop();
//     },
//   ),
// );
