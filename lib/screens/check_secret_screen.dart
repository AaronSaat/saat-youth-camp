// lib/screens/check_secret_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'direct_to_gmail_screen.dart';
import 'login_screen.dart';
import '../utils/app_colors.dart';

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
      final response = await ApiService.checkSecret(emailController.text, secretCodeController.text);

      if (response['status'] == 'success') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DirectToGmailScreen()));
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DirectToGmailScreen()));
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Syc?',
                  style: TextStyle(
                    fontFamily: "Cogley",
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: UnderlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: secretCodeController,
                  decoration: const InputDecoration(labelText: 'Kode Rahasia', border: UnderlineInputBorder()),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _checkSecret,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      elevation: 5,
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Verifikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sudah Punya Akun? ',
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16, color: AppColors.primary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
