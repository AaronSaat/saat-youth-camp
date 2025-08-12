// lib/screens/login_screen3.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

import 'dart:convert';
import '../services/api_service.dart';
import 'konfirmasi_registrasi_ulang_success_screen.dart';
import '../widgets/custom_alert_dialog.dart';

class KonfirmasiRegistrasiUlangScreen extends StatefulWidget {
  final String qrResult;

  const KonfirmasiRegistrasiUlangScreen({super.key, required this.qrResult});

  @override
  State<KonfirmasiRegistrasiUlangScreen> createState() =>
      _KonfirmasiRegistrasiUlangScreenState();
}

class _KonfirmasiRegistrasiUlangScreenState
    extends State<KonfirmasiRegistrasiUlangScreen> {
  Map<String, dynamic>? _dataKonfirmasi;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchDataKonfirmasi();
  }

  Future<void> _fetchDataKonfirmasi() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      // Ambil secret dari link QR
      final uri = Uri.tryParse(widget.qrResult);
      String? secret;
      if (uri != null &&
          uri.queryParameters.isEmpty &&
          uri.pathSegments.isNotEmpty) {
        final last = uri.pathSegments.last;
        if (last.contains('=')) {
          secret = last.split('=').last;
        } else {
          secret = last;
        }
      } else if (uri != null && uri.queryParameters.containsKey('s')) {
        secret = uri.queryParameters['s'];
      } else if (widget.qrResult.contains('s=')) {
        secret = widget.qrResult.split('s=').last;
      }
      if (secret == null || secret.isEmpty) {
        setState(() {
          _errorMsg = 'Secret tidak ditemukan di QR.';
          _isLoading = false;
        });
        return;
      }
      final res = await ApiService.getDataKonfirmasi(context, secret);
      if (res['success'] == true && res['data'] != null) {
        setState(() {
          _dataKonfirmasi = Map<String, dynamic>.from(res['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = res['message'] ?? 'Data tidak ditemukan.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal mengambil data konfirmasi.';
        _isLoading = false;
      });
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
              _isLoading
                  ? const CircularProgressIndicator()
                  : _errorMsg != null
                  ? Text(_errorMsg!, style: const TextStyle(color: Colors.red))
                  : _dataKonfirmasi == null
                  ? const Text('Data tidak ditemukan')
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
                          'Nama: ${_dataKonfirmasi?['nama'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Role: ${_dataKonfirmasi?['role'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelompok: ${_dataKonfirmasi?['kelompok'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => CustomAlertDialog(
                                      title: 'Konfirmasi',
                                      content:
                                          'Apakah Anda yakin ingin melakukan konfirmasi kehadiran?',
                                      cancelText: 'Batal',
                                      confirmText: 'Yakin',
                                      onCancel:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      onConfirm:
                                          () => Navigator.of(context).pop(true),
                                    ),
                              );
                              if (confirm == true) {
                                try {
                                  final body = {
                                    'user_id':
                                        _dataKonfirmasi?['user_id']
                                            .toString() ??
                                        '',
                                    'email': _dataKonfirmasi?['email'] ?? '',
                                  };
                                  final result =
                                      await ApiService.postKonfirmasiDatang(
                                        context,
                                        body,
                                      );
                                  final isSuccess = (result['success'] == true);
                                  if (!mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (
                                            context,
                                          ) => KonfirmasiRegistrasiUlangSuccessScreen(
                                            nama:
                                                _dataKonfirmasi?['nama'] ?? '',
                                            namakelompok:
                                                _dataKonfirmasi?['kelompok'] ??
                                                '',
                                            isSuccess: isSuccess,
                                          ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (
                                            context,
                                          ) => KonfirmasiRegistrasiUlangSuccessScreen(
                                            nama:
                                                _dataKonfirmasi?['nama'] ?? '',
                                            namakelompok:
                                                _dataKonfirmasi?['kelompok'] ??
                                                '',
                                            isSuccess: false,
                                          ),
                                    ),
                                  );
                                }
                              }
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
