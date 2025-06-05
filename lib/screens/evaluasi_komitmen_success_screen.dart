import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'evaluasi_komitmen_list_screen.dart';

class EvaluasiKomitmenSuccessScreen extends StatelessWidget {
  final String userId;
  final String type;
  final bool isSuccess;

  const EvaluasiKomitmenSuccessScreen({
    super.key,
    required this.userId,
    required this.type,
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
                      width: size.width * 0.5,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isSuccess
                          ? '$type berhasil disimpan!'
                          : '$type gagal disimpan.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => EvaluasiKomitmenListScreen(
                                  type: type,
                                  userId: userId,
                                ),
                          ),
                          (route) => false,
                        );
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
                            'Kembali ke List',
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
