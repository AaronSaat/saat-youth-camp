import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class KonfirmasiRegistrasiUlangSuccessScreen extends StatelessWidget {
  final String nama;
  final String namakelompok;
  final bool isSuccess;
  final String metode; // 'QR' atau 'Manual'
  final String message;

  const KonfirmasiRegistrasiUlangSuccessScreen({
    super.key,
    required this.nama,
    required this.namakelompok,
    required this.isSuccess,
    // this.metode = 'QR',
    required this.metode,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print("metode success screen: $metode");

    return Scaffold(
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isSuccess
                              ? 'Registrasi ulang berhasil!'
                              : 'Registrasi ulang gagal.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                isSuccess ? AppColors.green : AppColors.accent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSuccess
                              ? 'Silakan minta peserta untuk refresh halaman edit profil atau login kembali ke aplikasi.'
                              : message,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nama: $nama',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelompok: $namakelompok',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        if (metode.toLowerCase() == 'manual') {
                          Navigator.pop(context);
                          Navigator.pop(context, 'reload');
                        } else {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context, 'reload');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.brown1,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Kembali',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
    );
  }
}
