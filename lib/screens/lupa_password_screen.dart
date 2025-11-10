import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/screens/login_screen.dart';
import 'package:syc/widgets/custom_alert_dialog.dart';
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  Timer? _cooldownTimer;
  int _cooldownRemaining = 0;
  final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  bool get _isEmailValid => _emailRegex.hasMatch(emailController.text.trim());
  bool get _canSubmit =>
      !isLoading &&
      _cooldownRemaining == 0 &&
      emailController.text.trim().isNotEmpty &&
      _isEmailValid;

  @override
  void initState() {
    super.initState();
    // update button state when email input changes
    emailController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
    // restore cooldown if previously started
    _loadCooldownFromPrefs();
  }

  void validateEmail() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    if (emailController.text.isEmpty ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
      setState(() {
        isLoading = false;
        errorMessage = 'Masukkan email yang valid';
      });
      showCustomSnackBar(context, errorMessage);
      return;
    }

    try {
      final response = await ApiService.checkEmail(emailController.text);

      if (response['success'] == true) {
        // persist that we sent a reset (so cooldown survives navigation)
        _saveLastSentTimestamp();
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => CustomAlertDialog(
                title: 'Informasi',
                content:
                    'Silakan cek email Anda (${emailController.text}) untuk instruksi perubahan password.',
                confirmText: 'Login',
                onConfirm: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
        );
      } else {
        // untuk security, tetap tampilkan pesan sama meski email tidak terdaftar
        // persist timestamp as well to prevent immediate resubmit
        _saveLastSentTimestamp();
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => CustomAlertDialog(
                title: 'Informasi',
                content:
                    'Silakan cek email Anda (${emailController.text}) untuk instruksi perubahan password.',
                confirmText: 'Login',
                onConfirm: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
        );
      }
    } catch (e) {
      // persist timestamp to avoid resubmit spam even on error path
      _saveLastSentTimestamp();
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => CustomAlertDialog(
              title: 'Informasi',
              content:
                  'Silakan cek email Anda untuk instruksi perubahan password.',
              confirmText: 'Login',
              onConfirm: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
      );
    }
    setState(() => isLoading = false);
    // start cooldown to prevent spam clicks
    if ((_cooldownTimer?.isActive ?? false) == false) {
      _startCooldown();
    }
  }

  Future<void> _saveLastSentTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'forgot_password_last_sent',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // ignore prefs errors
    }
  }

  Future<void> _clearLastSentTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('forgot_password_last_sent');
    } catch (e) {
      // ignore
    }
  }

  Future<void> _loadCooldownFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? ts = prefs.getInt('forgot_password_last_sent');
      if (ts == null) return;
      final elapsed = DateTime.now().millisecondsSinceEpoch - ts;
      const cooldownMs = 60 * 1000;
      final remainingMs = cooldownMs - elapsed;
      if (remainingMs > 0) {
        final seconds = (remainingMs / 1000).ceil();
        _startCooldown(seconds);
      }
    } catch (e) {
      // ignore
    }
  }

  void _startCooldown([int seconds = 60]) {
    if ((_cooldownTimer?.isActive ?? false) || seconds <= 0) return;
    setState(() {
      _cooldownRemaining = seconds;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownRemaining -= 1;
        if (_cooldownRemaining <= 0) {
          _cooldownRemaining = 0;
          timer.cancel();
          // clear persisted timestamp when cooldown finishes
          _clearLastSentTimestamp();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_login.jpg',
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
                        padding: const EdgeInsets.only(
                          bottom: 16.0,
                          left: 16.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Lupa Password',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16.0,
                          left: 16.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Masukkan email Anda yang digunakan saat pendaftaran SAAT Youth Camp untuk menerima link reset password.',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.brown, width: 2),
                          ),
                          child: TextFormField(
                            controller: emailController,
                            style: const TextStyle(color: AppColors.primary),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: const TextStyle(
                                color: AppColors.primary,
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
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: _canSubmit ? validateEmail : null,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  _canSubmit
                                      ? AppColors.brown1
                                      : AppColors.brown1.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            alignment: Alignment.center,
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : (_cooldownRemaining > 0)
                                    ? Text(
                                      'Kirim lagi dalam ${_cooldownRemaining}s',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                    : const Text(
                                      'Kirim Email Reset Password',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    emailController.dispose();
    super.dispose();
  }
}
