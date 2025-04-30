import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

import '../widgets/custom_snackbar.dart';

class RegisterUserScreen extends StatefulWidget {
  final String email;

  const RegisterUserScreen({super.key, required this.email});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String resultMessage = '';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _registerUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() {
        resultMessage = 'Password dan konfirmasi tidak sama.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      resultMessage = '';
    });

    try {
      final response = await ApiService.registerUser(widget.email, username, password);

      if (response['status'] == 'success') {
        setState(() {
          resultMessage = 'Registrasi berhasil! Silakan login.';
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Registrasi Berhasil'),
              content: const Text(
                'Registrasi berhasil! Silakan cek email Anda lalu login menggunakan username / email dan password.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Setelah menekan OK, arahkan ke LoginScreen
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          resultMessage = response['message'] ?? 'Registrasi gagal.';
        });

        Future.delayed(Duration.zero, () {
          showCustomSnackBar(context, resultMessage);
        });
      }
    } catch (e) {
      setState(() {
        resultMessage = 'Terjadi kesalahan: $e';
      });

      Future.delayed(Duration.zero, () {
        showCustomSnackBar(context, resultMessage);
      });
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
          'Register New User',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Menjaga elemen-elemen di tengah vertikal
            children: [
              TextFormField(
                controller: TextEditingController(text: widget.email),
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
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                obscureText: _obscurePassword, // Menyembunyikan atau menampilkan password
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                obscureText: _obscureConfirmPassword, // Menyembunyikan atau menampilkan konfirmasi password
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Warna background
                  foregroundColor: Colors.white, // Warna teks
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Membuat sudut tombol melengkung
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Padding untuk tombol
                  elevation: 5, // Efek bayangan tombol
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(
                          color: Colors.white, // Warna indikator loading
                        )
                        : const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold, // Membuat teks lebih tebal
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
