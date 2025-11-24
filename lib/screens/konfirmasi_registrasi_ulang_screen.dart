import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import 'konfirmasi_registrasi_ulang_success_screen.dart';
import '../widgets/custom_alert_dialog.dart';

class KonfirmasiRegistrasiUlangScreen extends StatefulWidget {
  final String? qrResult;
  final String? userId;
  final String? pembimbingId;
  final String? nama;
  final String? email;
  final String? kelompok;
  final String? role;
  final String metode;

  const KonfirmasiRegistrasiUlangScreen({
    super.key,
    this.qrResult,
    this.userId,
    this.pembimbingId,
    this.nama,
    this.email,
    this.kelompok,
    this.role,
    required this.metode,
  });

  @override
  State<KonfirmasiRegistrasiUlangScreen> createState() =>
      _KonfirmasiRegistrasiUlangScreenState();
}

class _KonfirmasiRegistrasiUlangScreenState
    extends State<KonfirmasiRegistrasiUlangScreen> {
  Map<String, dynamic>? _dataKonfirmasi;
  bool _isLoading = false;
  String? _errorMsg;
  bool get _fromQr => widget.qrResult != null && widget.qrResult!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    print("metode init: ${widget.metode}");
    if (_fromQr) {
      _fetchDataKonfirmasi();
    } else {
      // Data langsung dari parameter
      _dataKonfirmasi = {
        'user_id': widget.userId ?? '',
        'nama': widget.nama ?? '',
        'email': widget.email ?? '',
        'kelompok': widget.kelompok ?? '',
        'role': widget.role ?? '',
      };
    }
  }

  Future<void> _fetchDataKonfirmasi() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      String? secret;
      // Ambil secret dengan regex agar fleksibel
      final regex = RegExp(r'secret=([^&\s]+)');
      final match = regex.firstMatch(widget.qrResult!);
      if (match != null) {
        secret = match.group(1);
        print('Secret found by regex: $secret');
      } else {
        print('Secret not found by regex');
      }
      if (secret == null || secret.isEmpty) {
        setState(() {
          _errorMsg = 'Secret tidak ditemukan di QR.';
          _isLoading = false;
        });
        return;
      }
      // Dekripsi secret
      final decryptedSecret = decryptSecret(secret);
      final res = await ApiService().getDataKonfirmasi(
        context,
        decryptedSecret,
      );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
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
            child: Center(
              child:
                  _fromQr
                      ? (_isLoading
                          ? const CircularProgressIndicator()
                          : _errorMsg != null
                          ? Text(
                            _errorMsg!,
                            style: const TextStyle(color: Colors.red),
                          )
                          : _dataKonfirmasi == null
                          ? const Text('Data tidak ditemukan')
                          : _buildContent(context))
                      : _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
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
            style: const TextStyle(fontSize: 18, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Role: ${_dataKonfirmasi?['role'] ?? ''}',
            style: const TextStyle(fontSize: 16, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelompok: ${_dataKonfirmasi?['kelompok'] ?? ''}',
            style: const TextStyle(fontSize: 16, color: AppColors.primary),
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
                        onCancel: () => Navigator.of(context).pop(false),
                        onConfirm: () => Navigator.of(context).pop(true),
                      ),
                );
                if (confirm == true) {
                  try {
                    final body = {
                      'user_id': _dataKonfirmasi?['user_id']?.toString() ?? '',
                      'email': _dataKonfirmasi?['email'] ?? '',
                      'pk_id': widget.pembimbingId ?? '',
                      'via':
                          widget.metode == 'QR'
                              ? '1'
                              : widget.metode == 'Manual'
                              ? '2'
                              : widget.metode,
                    };
                    final result = await ApiService().postKonfirmasiDatang(
                      context,
                      body,
                    );
                    final isSuccess = (result['success'] == true);
                    final message = result['message'] ?? '';
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => KonfirmasiRegistrasiUlangSuccessScreen(
                              nama: _dataKonfirmasi?['nama'] ?? '',
                              namakelompok: _dataKonfirmasi?['kelompok'] ?? '',
                              isSuccess: isSuccess,
                              metode: widget.metode,
                              message: message,
                            ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => KonfirmasiRegistrasiUlangSuccessScreen(
                              nama: _dataKonfirmasi?['nama'] ?? '',
                              namakelompok: _dataKonfirmasi?['kelompok'] ?? '',
                              isSuccess: false,
                              metode: widget.metode,
                              message: 'Terjadi kesalahan saat konfirmasi.',
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
    );
  }
}

String decryptSecret(String encryptedBase64) {
  print("Decrypting secret...");
  final key = encrypt.Key.fromUtf8(
    'Ab3kLm9PqRstUv2XyZ01MnOpQr56StUv',
  ); // 32 karakter
  final iv = encrypt.IV.fromUtf8('Ab3kLm9PqRstUv2X'); // 16 karakter
  final encrypter = encrypt.Encrypter(
    encrypt.AES(key, mode: encrypt.AESMode.cbc),
  );
  try {
    final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);
    print("DECRYPTED: $decrypted");
    return decrypted;
  } catch (e) {
    print("DECRYPTED: error");
    return 'DECRYPT ERROR: ${e.toString()}';
  }
}
