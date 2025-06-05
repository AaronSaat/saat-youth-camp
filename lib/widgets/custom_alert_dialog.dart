import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.cancelText,
    required this.confirmText,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          Colors.white, // Ganti sesuai warna background yang diinginkan
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.brown1, // Warna judul
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          color: AppColors.brown1, // Warna konten
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent, // Warna teks tombol cancel
          ),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                AppColors.brown1, // Warna background tombol confirm
            foregroundColor: AppColors.secondary, // Warna teks tombol confirm
          ),
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
