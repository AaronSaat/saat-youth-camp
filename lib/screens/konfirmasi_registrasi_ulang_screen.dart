// lib/screens/login_screen3.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

import 'dart:convert';

class KonfirmasiRegistrasiUlangScreen extends StatefulWidget {
  final String jsonContent;

  const KonfirmasiRegistrasiUlangScreen({super.key, required this.jsonContent});

  @override
  State<KonfirmasiRegistrasiUlangScreen> createState() =>
      _KonfirmasiRegistrasiUlangScreenState();
}

class _KonfirmasiRegistrasiUlangScreenState
    extends State<KonfirmasiRegistrasiUlangScreen> {
  Map<String, dynamic>? _decoded;

  @override
  void initState() {
    super.initState();
    try {
      _decoded =
          widget.jsonContent.isNotEmpty ? jsonDecode(widget.jsonContent) : null;
      print('Decoded QR:');
      print(_decoded);
    } catch (e) {
      print('Error decoding QR: $e');
      _decoded = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child:
              _decoded == null
                  ? const Text('QR tidak valid atau format salah')
                  : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Konfirmasi Registrasi Ulang',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Nama: ${_decoded?['nama'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Role: ${_decoded?['role'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelompok: ${_decoded?['kelompok_nama'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              // Lakukan aksi konfirmasi di sini
                              print('Data konfirmasi:');
                              print(_decoded);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.brown1,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Konfirmasi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
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
    );
  }
}
