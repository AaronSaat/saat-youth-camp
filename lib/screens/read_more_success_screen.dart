import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class ReadMoreSuccessScreen extends StatelessWidget {
  const ReadMoreSuccessScreen({super.key});

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
                      'assets/images/read_saved.png',
                      width: size.width * 0.6,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Progress bacaan hari ini berhasil disimpan!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
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
                            'Kembali ke Dashboard',
                            style: TextStyle(
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
    );
  }
}
