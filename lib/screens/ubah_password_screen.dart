import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syc/screens/ubah_password_success_screen.dart';
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/app_colors.dart';

class UbahPasswordScreen extends StatefulWidget {
  final String userId;

  const UbahPasswordScreen({super.key, required this.userId});

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  bool isPasswordBaruValid = false;
  bool isPasswordKonfirmasiValid = false;
  String passwordBaruError = '';
  String passwordKonfirmasiError = '';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordSekarangController =
      TextEditingController();
  final TextEditingController passwordBaruController = TextEditingController();
  final TextEditingController passwordKonfirmasiController =
      TextEditingController();
  bool _obscurePasswordSekarang = true;
  bool _obscurePasswordBaru = true;
  bool _obscurePasswordKonfirmasi = true;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  void validatePasswordToApi() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    // Validasi password baru dan konfirmasi
    if (!isPasswordBaruValid) {
      setState(() {
        isLoading = false;
        errorMessage = 'Password baru tidak valid';
      });
      showCustomSnackBar(context, errorMessage);
      return;
    }
    if (!isPasswordKonfirmasiValid) {
      setState(() {
        isLoading = false;
        errorMessage = 'Password konfirmasi tidak sesuai';
      });
      showCustomSnackBar(context, errorMessage);
      return;
    }
    try {
      final response = await ApiService().ubahPassword(
        widget.userId,
        passwordSekarangController.text,
        passwordBaruController.text,
      );
      if (!mounted) return;
      print('response ubah password: $response');
      setState(() => isLoading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => UbahPasswordSuccessScreen(
                isSuccess: response['success'] == true,
                message:
                    response['message'] ??
                    (response['success'] == true
                        ? 'Password berhasil diubah!'
                        : 'Gagal mengubah password.'),
                userId: widget.userId,
              ),
        ),
      );
    } catch (e) {
      print('e ubah password: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => UbahPasswordSuccessScreen(
                isSuccess: false,
                message: 'Gagal mengubah password.',
                userId: widget.userId,
              ),
        ),
      );
    }
  }

  void validatePasswordBaru() {
    final password = passwordBaruController.text;
    final hasMinLength = password.length >= 8;
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    setState(() {
      isPasswordBaruValid = hasMinLength && hasNumber;
      passwordBaruError = '';
      if (!hasMinLength) {
        passwordBaruError = 'Panjang minimal 8 karakter';
      } else if (!hasNumber) {
        passwordBaruError = 'Password harus mengandung minimal 1 angka';
      }
    });
    // Setelah password baru valid, cek konfirmasi juga
    validatePasswordKonfirmasi();
  }

  void validatePasswordKonfirmasi() {
    final password = passwordBaruController.text;
    final konfirmasi = passwordKonfirmasiController.text;
    setState(() {
      isPasswordKonfirmasiValid =
          password == konfirmasi && konfirmasi.isNotEmpty;
      passwordKonfirmasiError = '';
      if (konfirmasi.isNotEmpty && password != konfirmasi) {
        passwordKonfirmasiError = 'Password konfirmasi tidak sama';
      }
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
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ubah Password',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                            controller: passwordSekarangController,
                            obscureText: _obscurePasswordSekarang,
                            style: const TextStyle(color: AppColors.primary),
                            decoration: InputDecoration(
                              hintText: 'Password Sekarang',
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
                                  _obscurePasswordSekarang
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
                                    _obscurePasswordSekarang =
                                        !_obscurePasswordSekarang;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                            controller: passwordBaruController,
                            obscureText: _obscurePasswordBaru,
                            style: const TextStyle(color: AppColors.primary),
                            onChanged: (val) => validatePasswordBaru(),
                            decoration: InputDecoration(
                              hintText: 'Password Baru',
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
                                  _obscurePasswordBaru
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
                                    _obscurePasswordBaru =
                                        !_obscurePasswordBaru;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Syarat password baru selalu muncul
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPasswordBaruValid &&
                                        passwordBaruController.text.isNotEmpty
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                color:
                                    isPasswordBaruValid &&
                                            passwordBaruController
                                                .text
                                                .isNotEmpty
                                        ? Colors.green
                                        : AppColors.accent,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Password minimal 8 karakter dan mengandung minimal 1 angka',
                                  style: TextStyle(
                                    color:
                                        isPasswordBaruValid &&
                                                passwordBaruController
                                                    .text
                                                    .isNotEmpty
                                            ? Colors.green
                                            : AppColors.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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
                            controller: passwordKonfirmasiController,
                            obscureText: _obscurePasswordKonfirmasi,
                            style: const TextStyle(color: AppColors.primary),
                            onChanged: (val) => validatePasswordKonfirmasi(),
                            decoration: InputDecoration(
                              hintText: 'Password Konfirmasi',
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
                                  _obscurePasswordKonfirmasi
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
                                    _obscurePasswordKonfirmasi =
                                        !_obscurePasswordKonfirmasi;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Syarat konfirmasi password selalu muncul
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPasswordKonfirmasiValid &&
                                        passwordKonfirmasiController
                                            .text
                                            .isNotEmpty
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                color:
                                    isPasswordKonfirmasiValid &&
                                            passwordKonfirmasiController
                                                .text
                                                .isNotEmpty
                                        ? Colors.green
                                        : AppColors.accent,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                passwordKonfirmasiController.text.isEmpty
                                    ? 'Konfirmasi password harus sama'
                                    : (isPasswordKonfirmasiValid
                                        ? 'Password konfirmasi sesuai'
                                        : 'Password konfirmasi tidak sama'),
                                style: TextStyle(
                                  color:
                                      isPasswordKonfirmasiValid &&
                                              passwordKonfirmasiController
                                                  .text
                                                  .isNotEmpty
                                          ? Colors.green
                                          : AppColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap:
                              isLoading ||
                                      passwordSekarangController.text.isEmpty ||
                                      passwordBaruController.text.isEmpty ||
                                      passwordKonfirmasiController
                                          .text
                                          .isEmpty ||
                                      !isPasswordBaruValid ||
                                      !isPasswordKonfirmasiValid
                                  ? null
                                  : validatePasswordToApi,
                          child: Opacity(
                            opacity:
                                (!isLoading &&
                                        passwordSekarangController
                                            .text
                                            .isNotEmpty &&
                                        passwordBaruController
                                            .text
                                            .isNotEmpty &&
                                        passwordKonfirmasiController
                                            .text
                                            .isNotEmpty &&
                                        isPasswordBaruValid &&
                                        isPasswordKonfirmasiValid)
                                    ? 1.0
                                    : 0.5,
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
                                        'Ubah Password',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
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
}
