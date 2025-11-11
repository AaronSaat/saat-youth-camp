// ini global function untuk auto logout kalo token expired

// jangan lupa di declare
// import '/utils/api_helper.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../screens/login_screen.dart';

final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

Future<void> handleUnauthorized(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print('SharedPreferences cleared due to unauthorized access.');
  await secureStorage.deleteAll();
  print('Secure storage cleared due to unauthorized access.');

  // Hapus semua file gambar yang sudah didownload lokal (misal di direktori cache/app)
  // (Contoh: hapus semua file di direktori temporary dan application documents)
  try {
    final tempDir = await getTemporaryDirectory();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    if (await appDocDir.exists()) {
      await appDocDir.delete(recursive: true);
    }
    print('Local files cleared due to version mismatch.');
  } catch (e) {
    print('Gagal menghapus file lokal: $e');
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}
