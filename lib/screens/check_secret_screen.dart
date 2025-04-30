// lib/screens/check_secret_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'direct_to_gmail_screen.dart';

// import '../widgets/custom_snackbar.dart';

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

        // Future.delayed(Duration.zero, () {
        //   showCustomSnackBar(context, resultMessage);
        // });
      }
    } catch (e) {
      setState(() {
        resultMessage = 'Terjadi kesalahan: $e';
      });

      // Future.delayed(Duration.zero, () {
      //   showCustomSnackBar(context, resultMessage);
      // });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Daftar Akun Baru',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: secretCodeController,
                decoration: InputDecoration(
                  labelText: 'Code',
                  prefixIcon: const Icon(Icons.vpn_key),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _checkSecret,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24), // sedikit lebih kecil
                    elevation: 5,
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                          : const Text('Verifikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
