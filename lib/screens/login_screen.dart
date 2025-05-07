// lib/screens/login_screen.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:syc/utils/app_colors.dart';

import '../services/api_service.dart';

import 'check_secret_screen.dart';
import 'main_screen.dart';

import '../widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true; // untuk show password

  bool isLoading = false;
  String errorMessage = '';

  // Fungsi untuk menyimpan data di SharedPreferences
  Future<void> _saveLoginData(
    String username,
    String email,
    String role,
    String token,
    String gereja,
    String kelompok,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    await prefs.setString('token', token);
    await prefs.setString('gereja', gereja);
    await prefs.setString('kelompok', kelompok);
  }

  // Fungsi untuk login
  void _login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await ApiService.loginUser(usernameController.text, passwordController.text);

      if (response['status'] == 'success') {
        await _saveLoginData(
          response['user']['username'],
          response['user']['email'],
          response['user']['role'],
          response['token'],
          response['user']['gereja'],
          response['user']['kelompok'],
        );

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Login gagal';
        });

        Future.delayed(Duration.zero, () {
          showCustomSnackBar(context, errorMessage);
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });

      Future.delayed(Duration.zero, () {
        showCustomSnackBar(context, errorMessage);
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: AppColors.primary,
      //   centerTitle: true,
      //   title: const Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Syc',
                  style: TextStyle(
                    fontFamily: "Cogley",
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username atau Email',
                    // prefixIcon: Icon(Icons.person),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    // prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.primary),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const UnderlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
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
                            : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Belum Punya Akun? ',
                      style: TextStyle(
                        fontWeight: FontWeight.w300, // light font
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckSecretScreen()));
                      },
                      child: const Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // bold font
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
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
