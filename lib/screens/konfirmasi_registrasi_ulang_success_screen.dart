import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'list_evaluasi_screen.dart';

class KonfirmasiRegistrasiUlangSuccessScreen extends StatelessWidget {
  final String nama;
  final String namakelompok;
  final bool isSuccess;

  const KonfirmasiRegistrasiUlangSuccessScreen({
    super.key,
    required this.nama,
    required this.namakelompok,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                      'assets/images/answer_saved.png',
                      width: size.width * 0.6,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isSuccess
                          ? 'Registrasi ulang berhasil!\nSilakan minta peserta untuk login kembali ke aplikasi.'
                          : 'Registrasi ulang gagal.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black1,
                      ),
                      textAlign: TextAlign.center,
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
                        Navigator.pop(context);
                        Navigator.pop(context, 'reload');
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
