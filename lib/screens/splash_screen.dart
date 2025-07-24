import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

  @override
  void initState() {
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

    Future.delayed(const Duration(seconds: 2), () async {
      final prefs = await SharedPreferences.getInstance();
      final getToken = prefs.getString('token');

      if (getToken != null && getToken.isNotEmpty) {
        setState(() => _isCheckingToken = true); // <-- Mulai loading
        final isValid = await ApiService.validateToken(
          context,
          token: getToken,
        );
        setState(() => _isCheckingToken = false); // <-- Selesai loading
        if (isValid) {
          print('CEK TOKEN: VALID');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        } else {
          print('CEK TOKEN: TIDAK VALID');
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
        print('CEK TOKEN: TOKEN TIDAK ADA');
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
    });
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
                // Loading hanya saat cek token
                if (_isCheckingToken) ...[
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
                  const Text(
                    "Memeriksa akun...",
                    style: TextStyle(
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
