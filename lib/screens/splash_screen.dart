import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart'; // Import LoginScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Set delay selama 2 detik, lalu arahkan ke LoginScreen dengan transisi slide up
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Animasi slide up
            const begin = Offset(0.0, 1.0); // Mulai di bawah
            const end = Offset.zero; // Selesai di posisi normal
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.png'), // Path ke gambar
            fit: BoxFit.cover, // Agar gambar menutupi seluruh layar
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gambar logo aplikasi
              const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/images/logo_stt_saat.png')),
              const SizedBox(height: 16),
              const Text(
                'SYC App 2024',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
