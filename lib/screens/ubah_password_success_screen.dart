import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/app_colors.dart';
import '../utils/global_variables.dart';
import 'login_screen.dart';
import 'ubah_password_screen.dart';

class UbahPasswordSuccessScreen extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final String userId;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  const UbahPasswordSuccessScreen({
    super.key,
    required this.isSuccess,
    required this.message,
    required this.userId,
  });

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('Shared prefs cleared on password change.');
    await secureStorage.deleteAll();
    print('Secure storage cleared on password change.');

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

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    // reset
    GlobalVariables.currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, 'reload');
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        isSuccess
                            ? 'assets/images/verified_success.png'
                            : 'assets/images/verified_fail.png',
                        width: size.width * 0.6,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          if (isSuccess) {
                            await _logout(context);
                          } else {
                            // Kembali ke UbahPasswordScreen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        UbahPasswordScreen(userId: userId),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.brown1,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isSuccess
                                  ? 'Kembali ke Halaman Login'
                                  : 'Kembali',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
