// lib/screens/check_secret_screen.dart

import 'package:flutter/material.dart';
import 'package:syc/screens/check_secret_success_screen.dart.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

import 'login_screen.dart';

class CheckSecretScreen extends StatefulWidget {
  const CheckSecretScreen({super.key});

  @override
  State<CheckSecretScreen> createState() => _CheckSecretScreenState();
}

class _CheckSecretScreenState extends State<CheckSecretScreen> {
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  bool isEmailValid = true;
  final TextEditingController secretCodeController = TextEditingController();

  bool isLoading = false;
  String resultMessage = '';

  bool get _isEmailValidNow => _validateEmail(emailController.text.trim());
  bool get _hasSecret => secretCodeController.text.trim().isNotEmpty;
  bool get _canSubmit => !isLoading && _isEmailValidNow && _hasSecret;

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(_onEmailFocusChange);
    // update button state when inputs change
    emailController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
    secretCodeController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    emailFocusNode.removeListener(_onEmailFocusChange);
    emailFocusNode.dispose();
    emailController.dispose();
    secretCodeController.dispose();
    super.dispose();
  }

  void _onEmailFocusChange() {
    if (!emailFocusNode.hasFocus) {
      // Cek validasi email saat user tidak mengetik (unfocus)
      setState(() {
        isEmailValid = _validateEmail(emailController.text);
      });
    }
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    return emailRegex.hasMatch(email);
  }

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
          MaterialPageRoute(builder: (_) => const CheckSecretSuccessScreen()),
        );
      } else if ((response['success'] == false &&
          response['message'] ==
              'Email sudah terdaftar, silakan login menggunakan email/username dan password Anda.')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CheckSecretSuccessScreen()),
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
                          builder: (context) => CheckSecretSuccessScreen(),
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
          Positioned(
            child: Image.asset(
              'assets/images/background_secret.jpg',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/logos/redeemed_text.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 72),
                      // Email
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: TextFormField(
                                controller: emailController,
                                focusNode: emailFocusNode,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!emailFocusNode.hasFocus &&
                                emailController.text.isNotEmpty &&
                                !isEmailValid)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12.0,
                                  top: 2.0,
                                ),
                                child: Text(
                                  'Email tidak valid',
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Secret Code
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: TextFormField(
                            controller: secretCodeController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Kode Rahasia',
                              hintStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              // prefixIcon: SvgPicture.asset(
                              //   'assets/icons/login/secret_code.svg',
                              //   width: 24,
                              //   height: 24,
                              //   colorFilter: const ColorFilter.mode(
                              //     AppColors.primary,
                              //     BlendMode.srcIn,
                              //   ),
                              // ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Login Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: _canSubmit ? _checkSecret : null,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  _canSubmit ? Colors.white : AppColors.grey4,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            alignment: Alignment.center,
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      color: AppColors.brown1,
                                    )
                                    : Text(
                                      'Check Secret',
                                      style: TextStyle(
                                        color:
                                            _canSubmit
                                                ? AppColors.brown1
                                                : Colors.white.withAlpha(60),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 16),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      //   child: GestureDetector(
                      //     onTap: () {},
                      //     child: Container(
                      //       width: double.infinity,
                      //       height: 50,
                      //       decoration: BoxDecoration(
                      //         color: Colors.transparent,
                      //         borderRadius: BorderRadius.circular(32),
                      //         border: Border.all(color: Colors.white, width: 2),
                      //       ),
                      //       alignment: Alignment.center,
                      //       child:
                      //           isLoading
                      //               ? const CircularProgressIndicator(
                      //                 color: Colors.white,
                      //               )
                      //               : const Text(
                      //                 'Sudah Punya Akun? Login disini',
                      //                 style: TextStyle(
                      //                   color: Colors.white,
                      //                   fontSize: 14,
                      //                   fontWeight: FontWeight.w500,
                      //                 ),
                      //               ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 24),
                      // Login Saja
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Row(
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
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
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
