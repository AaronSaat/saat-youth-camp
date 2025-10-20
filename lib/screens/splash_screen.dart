import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:syc/screens/pengumuman_list_screen.dart';
import 'package:url_launcher/url_launcher.dart'
    show canLaunchUrl, LaunchMode, launchUrl;

import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SplashScreen extends StatefulWidget {
  final bool fromNotification;
  final String? tujuan;
  final int? id;
  final int? userId;

  const SplashScreen({
    Key? key,
    this.fromNotification = false,
    this.tujuan,
    this.id,
    this.userId,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgFadeController;
  late AnimationController _logoMoveController;
  late AnimationController _textFadeController;

  late Animation<double> _bgFadeAnimation;
  late Animation<Offset> _logoPositionAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;

  bool _isCheckingToken = false;
  bool _isCheckingVersion = false; // Tambahkan ini

  @override
  void initState() {
    print('SplashScreen initState called [navigating]');
    super.initState();

    _bgFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bgFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _bgFadeController, curve: Curves.easeOut),
    );

    _logoMoveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoPositionAnimation = Tween<Offset>(
      begin: Offset.zero,
      // end: const Offset(0, -1.25),
      end: const Offset(0, -0.9),
    ).animate(
      CurvedAnimation(parent: _logoMoveController, curve: Curves.easeInOut),
    );
    _logoScaleAnimation = Tween<double>(
      begin: 1.0,
      // end: 0.55,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _logoMoveController, curve: Curves.easeInOut),
    );

    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _textFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeOut),
    );

    // Cek versi dulu sebelum cek token
    _checkAll();
  }

  Future<void> _checkAll() async {
    setState(() => _isCheckingVersion = true);
    await getCheckVersion();
    setState(() => _isCheckingVersion = false);

    // Lanjut cek token (existing code)
    final prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('token');

    if (getToken != null && getToken.isNotEmpty) {
      setState(() => _isCheckingToken = true); // <-- Mulai loading
      final isValid = await ApiService.validateToken(context, token: getToken);
      setState(() => _isCheckingToken = false); // <-- Selesai loading
      if (isValid) {
        print('Navigating CEK TOKEN: VALID');
        if (widget.tujuan == 'pengumuman_list') {
          // Pertama ke MainScreen
          print('Navigating to Main Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
          // Setelah MainScreen dipush, lanjut ke PengumumanListScreen
          print('Navigating to Pengumuman List Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const PengumumanListScreen(),
            ),
          );
        } else {
          print('Navigating to Main Screen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        print('Navigating CEK TOKEN: TIDAK VALID');
        // lakukan animasi
        await _bgFadeController.forward();
        await Future.wait([
          _logoMoveController.forward(),
          _textFadeController.forward(),
        ]);
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const LoginScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 200),
            ),
          );
        }
      }
    } else {
      // Token tidak ada, langsung lakukan animasi
      print('Navigating CEK TOKEN: TOKEN TIDAK ADA');
      await _bgFadeController.forward();
      await Future.wait([
        _logoMoveController.forward(),
        _textFadeController.forward(),
      ]);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 200),
          ),
        );
      }
    }
  }

  Future<void> getCheckVersion() async {
    setState(() => _isCheckingVersion = true); // Mulai loading versi
    final info = await PackageInfo.fromPlatform();
    final localVersion = info.version;
    // final localVersion = "${info.version}+${info.buildNumber}";
    // final localVersion = "1.0.0+12";

    final response = await ApiService.getCheckVersion(context);
    final latestVersion = response['latest_version'] ?? localVersion;
    print('CEK VERSI: $localVersion vs $latestVersion');

    if (localVersion != latestVersion) {
      // Hapus semua data SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('SharedPreferences cleared due to version mismatch.');

      // Hapus semua file gambar yang sudah didownload lokal (misal di direktori cache/app)
      // (Contoh: hapus semua file di direktori temporary dan application documents)
      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
        final appDocDir = await getApplicationDocumentsDirectory();
        if (await appDocDir.exists()) {
          await appDocDir.delete(recursive: true);
        }
        print('Local files cleared due to version mismatch.');
      } catch (e) {
        print('Gagal menghapus file lokal: $e');
      }

      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Update Tersedia'),
                content: Text(
                  'Versi aplikasi terbaru tersedia. Silakan update aplikasi untuk melanjutkan.',
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      String url;
                      if (Theme.of(context).platform == TargetPlatform.iOS) {
                        url =
                            response['update_url_ios'] ??
                            'https://apps.apple.com/id/app/saat-youth-camp/id6751375478';
                      } else {
                        url =
                            response['update_url_android'] ??
                            'https://play.google.com/store/apps/details?id=com.sttsaat.sycapp';
                      }
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                      // Jangan tutup dialog, biarkan user tetap di sini
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
        );
      }
      setState(() => _isCheckingVersion = false);
      return; // Stop proses, user harus update dan buka ulang aplikasi
    }
    setState(() => _isCheckingVersion = false);
  }

  @override
  void dispose() {
    _bgFadeController.dispose();
    _logoMoveController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FadeTransition(
            opacity: _bgFadeAnimation,
            child: Container(color: AppColors.primary),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animasi
                SlideTransition(
                  position: _logoPositionAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.4,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/logos/redeemed_text.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Loading saat cek versi atau cek token
                if (_isCheckingVersion || _isCheckingToken) ...[
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isCheckingVersion
                        ? "Memeriksa versi aplikasi..."
                        : "Memeriksa akun...",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
