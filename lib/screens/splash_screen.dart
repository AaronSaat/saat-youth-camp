import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:syc/screens/detail_acara_screen.dart';
import 'package:syc/screens/list_evaluasi_screen.dart';
import 'package:syc/screens/pengumuman_list_screen.dart';
import 'package:syc/utils/global_variables.dart';
import 'package:syc/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart'
    show canLaunchUrl, LaunchMode, launchUrl;
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'package:path_provider/path_provider.dart';

class SplashScreen extends StatefulWidget {
  final bool fromNotification;
  final String? tujuan;
  final int? id;

  const SplashScreen({
    Key? key,
    this.fromNotification = false,
    this.tujuan,
    this.id,
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
  bool _isCheckingVersion = false;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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
    // final prefs = await SharedPreferences.getInstance();
    // final getToken = prefs.getString('token');

    final getToken = await secureStorage.read(key: 'token');
    print('Data token from secure storage: $getToken');

    if (getToken != null && getToken.isNotEmpty) {
      setState(() => _isCheckingToken = true); // <-- Mulai loading
      final isValid = await ApiService.validateToken(context, token: getToken);
      setState(() => _isCheckingToken = false); // <-- Selesai loading
      if (isValid) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role') ?? '';
        final userId = prefs.getString('id') ?? '';
        print('Role from SharedPreferences: $role');
        print('User ID from SharedPreferences: $userId');
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
        } else if (widget.tujuan == 'acara_list') {
          // reminder acara dan evaluasi
          // ke MainScreen > Daftar Acara
          setState(() {
            GlobalVariables.currentIndex = 1;
          });
          print('Navigating to Main Screen > Daftar Acara');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );

          print('Navigating to Detail Acara');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => DetailAcaraScreen(
                    id: widget.id?.toString() ?? '',
                    userId: userId.toString(),
                  ),
            ),
          );
        } else if (widget.tujuan == 'evaluasi_list') {
          // evaluasi keseluruhan
          // Pertama ke MainScreen > Profile
          setState(() {
            GlobalVariables.currentIndex = 4;
          });
          print('Navigating to Main Screen > Profile');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
          if (role.toLowerCase().trim() == 'peserta') {
            // Setelah MainScreen dipush, lanjut ke EvaluasiListScreen
            print('Navigating to Evaluasi List Screen');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) =>
                        ListEvaluasiScreen(userId: userId?.toString() ?? ''),
              ),
            );
          } else {
            showCustomSnackBar(
              context,
              'Daftar evaluasi hanya tersedia untuk peserta dan pembina gereja',
            );
          }
        } else if (widget.tujuan == 'dashboard') {
          // komitmen
          // ke MainScreen
          print('Navigating to Main Screen');
          setState(() {
            GlobalVariables.currentIndex = 0;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
          if (role.toLowerCase().trim() == 'peserta') {
            showCustomSnackBar(
              context,
              'Klik pada kartu reminder komitmen di halaman dashboard',
            );
          } else {
            showCustomSnackBar(
              context,
              'Komitmen hanya tersedia untuk peserta',
            );
          }
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
    var localVersion = info.version;
    // var localVersion = '1.0.3'; // Hardcode versi lokal sesuai pubspec.yaml
    // Hapus build metadata jika ada (misal "1.0.0+12")
    localVersion = localVersion.split('+').first;

    final response = await ApiService.getCheckVersion(context);
    final latestVersionRaw = response['latest_version'] ?? localVersion;
    final latestVersion = latestVersionRaw.split('+').first;
    final minimumVersionRaw = response['minimum_version'] ?? localVersion;
    final minimumVersion = minimumVersionRaw.split('+').first;

    print(
      'CEK VERSI: local=$localVersion latest=$latestVersion minimum=$minimumVersion',
    );

    bool isLocalVersionValid(
      String localVersion,
      String latestVersion,
      String minimumVersion,
    ) {
      List<int> parseVersion(String v) =>
          v.split('.').map((s) => int.tryParse(s) ?? 0).toList();

      int compareVersions(List<int> a, List<int> b) {
        final maxLen = a.length > b.length ? a.length : b.length;
        for (var i = 0; i < maxLen; i++) {
          final ai = i < a.length ? a[i] : 0;
          final bi = i < b.length ? b[i] : 0;
          if (ai < bi) return -1;
          if (ai > bi) return 1;
        }
        return 0;
      }

      final a = parseVersion(localVersion);
      final latest = parseVersion(latestVersion);
      final minimum = parseVersion(minimumVersion);

      final cmpWithMin = compareVersions(a, minimum);
      final cmpWithLatest = compareVersions(a, latest);

      // localVersion harus >= minimumVersion (cmpWithMin >= 0)
      // localVersion harus <= latestVersion (cmpWithLatest <= 0)
      return (cmpWithMin >= 0) && (cmpWithLatest <= 0);
    }

    // Force update if below minimum_version or below latest (update available)
    if (!isLocalVersionValid(localVersion, latestVersion, minimumVersion)) {
      // Hapus semua data SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('SharedPreferences cleared due to version mismatch.');
      await secureStorage.deleteAll();
      print('Secure storage cleared due to version mismatch.');

      // Hapus semua file gambar yang sudah didownload lokal (misal di direktori cache/app)
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
                content: const Text(
                  'Versi aplikasi terbaru tersedia. Silakan update aplikasi untuk melanjutkan.',
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      String url;
                      if (Theme.of(ctx).platform == TargetPlatform.iOS) {
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
            child: Container(color: AppColors.backgroundSplash),
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
                      color: AppColors.primary,
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
                      color: AppColors.primary,
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
