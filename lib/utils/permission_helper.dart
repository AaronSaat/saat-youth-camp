import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PermissionHelper {
  static Future<bool> requestPhotosPermission(BuildContext context) async {
    if (Platform.isIOS) {
      return await _requestiOSPhotosPermission(context);
    } else {
      return await _requestAndroidPhotosPermission(context);
    }
  }

  static Future<bool> _requestiOSPhotosPermission(BuildContext context) async {
    PermissionStatus status = await Permission.photos.status;

    // iOS: Limited access juga dianggap "berhasil"
    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.photos.request();
      // iOS: Limited atau granted keduanya OK
      if (status.isGranted || status.isLimited) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(context);
      return false;
    }

    return false;
  }

  static Future<bool> _requestAndroidPhotosPermission(
    BuildContext context,
  ) async {
    PermissionStatus status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.photos.request();
      if (status.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(context);
      return false;
    }

    return false;
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Diperlukan'),
          content: Text(
            Platform.isIOS
                ? 'Aplikasi memerlukan akses ke foto. Buka Pengaturan > Privasi & Keamanan > Foto > SYC App.'
                : 'Aplikasi memerlukan akses ke galeri foto. Silakan buka Pengaturan untuk memberikan izin.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
          ],
        );
      },
    );
  }
}
