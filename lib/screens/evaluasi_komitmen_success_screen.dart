import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'evaluasi_komitmen_list_screen.dart';

class EvaluasiKomitmenSuccessScreen extends StatelessWidget {
  final String userId;
  final String type;
  final bool isSuccess;

  const EvaluasiKomitmenSuccessScreen({super.key, required this.userId, required this.type, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/images/background_email.png', width: size.width, height: size.height, fit: BoxFit.cover),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      isSuccess ? '$type berhasil disimpan!' : '$type gagal disimpan.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? Colors.green : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => EvaluasiKomitmenListScreen(
                                  type: type,
                                  userId: userId, // Ganti dengan userId yang sesuai jika tersedia di context
                                ),
                          ),
                          (route) => false,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            // ga ke refresh
                            // Navigator.pushAndRemoveUntil(
                            //   context,
                            //   MaterialPageRoute(builder: (_) => EvaluasiKomitmenListScreen(type: type, userId: '')),
                            //   (route) => false,
                            // );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(color: AppColors.brown1, borderRadius: BorderRadius.circular(32)),
                            alignment: Alignment.center,
                            child: const Text(
                              'Kembali ke List',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
