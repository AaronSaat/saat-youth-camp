// lib/screens/check_secret_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'direct_to_gmail_screen.dart';
import '../utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'login_screen.dart';

class CheckSecretScreen extends StatefulWidget {
  const CheckSecretScreen({super.key});

  @override
  State<CheckSecretScreen> createState() => _CheckSecretScreenState();
}

class _CheckSecretScreenState extends State<CheckSecretScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController secretCodeController = TextEditingController();

  bool isLoading = false;
  String resultMessage = '';

  Future<void> _checkSecret() async {
    setState(() {
      isLoading = true;
      resultMessage = '';
    });

    try {
      final response = await ApiService.checkSecret(
        emailController.text,
        secretCodeController.text,
      );

      if (response['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DirectToGmailScreen()),
        );
      } else {
        setState(() {
          resultMessage = response['message'] ?? 'Secret code tidak valid';
        });

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Terima Kasih!'),
                content: const Text(
                  'Silakan cek email Anda untuk melanjutkan proses pendaftaran.\nJika Anda belum menerima email dari System Aplikasi SYC atau mengalami kesulitan, silakan menghubungi panitia SYC.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DirectToGmailScreen(),
                        ),
                      );
                    },
                    child: const Text('Lanjut'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      setState(() {
        resultMessage = 'Terjadi kesalahan: $e';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background_login3.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            'assets/logos/story_saat.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Image.asset('assets/logos/syc.png', height: 100),
                      const SizedBox(height: 40),
                      // Email
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: emailController,
                          style: const TextStyle(color: AppColors.primary),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(
                              color: AppColors.primary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            prefixIcon: SvgPicture.asset(
                              'assets/icons/login/email.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Secret Code
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: secretCodeController,
                          style: const TextStyle(color: AppColors.primary),
                          decoration: InputDecoration(
                            hintText: 'Kode Rahasia',
                            hintStyle: const TextStyle(
                              color: AppColors.primary,
                            ),
                            border: const UnderlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            prefixIcon: SvgPicture.asset(
                              'assets/icons/login/secret_code.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Login Button
                      GestureDetector(
                        onTap: isLoading ? null : _checkSecret,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/buttons/button1.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child:
                              isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Check Secret',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Login Saja
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Sudah Punya Akun? ',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     GestureDetector(
                      //       onTap: () {
                      //         Navigator.pushReplacement(
                      //           context,
                      //           MaterialPageRoute(builder: (context) => const DirectToGmailScreen()),
                      //         );
                      //       },
                      //       child: const Text(
                      //         'Check Gmail',
                      //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
