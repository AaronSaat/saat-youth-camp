// lib/screens/login_screen3.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/app_colors.dart';
import 'main_screen.dart';
import 'check_secret_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveLoginData(
    String id,
    String username,
    String email,
    String role,
    String token,
    String gereja_id,
    String gereja_nama,
    String kelompok_id,
    String kelompok_nama,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', id);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    await prefs.setString('token', token);
    await prefs.setString('gereja_id', gereja_id);
    await prefs.setString('gereja_nama', gereja_nama);
    await prefs.setString('kelompok_id', kelompok_id);
    await prefs.setString('kelompok_nama', kelompok_nama);
    print('Login data saved:');
    print('id: $id');
    print('username: $username');
    print('email: $email');
    print('role: $role');
    print('token: $token');
    print('gereja_id: $gereja_id');
    print('gereja_nama: $gereja_nama');
    print('kelompok_id: $kelompok_id');
    print('kelompok_nama: $kelompok_nama');
  }

  void _login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await ApiService.loginUser(
        usernameController.text,
        passwordController.text,
      );
      print('Login response: $response');

      if (response['success'] == true) {
        await _saveLoginData(
          response['user']['id'].toString(),
          response['user']['username'],
          response['user']['email'],
          response['user']['role'],
          response['token'],
          response['user']['gereja']?['gereja_id']?.toString() ?? 'Null',
          response['user']['gereja']?['gereja_nama'] ?? 'Null',
          response['user']['kelompok']?['id']?.toString() ?? 'Null',
          response['user']['kelompok']?['nama_kelompok'] ?? 'Null',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        setState(() => errorMessage = response['message'] ?? 'Login gagal');
        showCustomSnackBar(context, errorMessage);
      }
    } catch (e) {
      setState(() => errorMessage = 'Terjadi kesalahan: $e');
      showCustomSnackBar(context, errorMessage);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background_login4.jpg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: SingleChildScrollView(
                  // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
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
                      Image.asset('assets/logos/syc2.png', height: 100),
                      const SizedBox(height: 40),

                      // Username
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.brown, width: 2),
                          ),
                          child: TextFormField(
                            controller: usernameController,
                            style: const TextStyle(color: AppColors.primary),
                            decoration: InputDecoration(
                              hintText: 'Username atau Email',
                              hintStyle: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w300,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              // prefixIcon: SvgPicture.asset(
                              //   'assets/icons/login/email.svg',
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
                      const SizedBox(height: 16),
                      // Password
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.brown, // Outline cokelat
                              width: 2,
                            ),
                          ),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: AppColors.primary),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w300,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: SvgPicture.asset(
                                  _obscurePassword
                                      ? 'assets/icons/login/hide_password.svg'
                                      : 'assets/icons/login/show_password.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: isLoading ? null : _login,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.brown1,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            alignment: Alignment.center,
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Daftar sekarang
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CheckSecretScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Daftar sekarang',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
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
          ),
        ],
      ),
    );
  }
}
