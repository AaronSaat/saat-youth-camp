import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:syc/screens/catatan_harian_screen.dart';
import 'dart:convert' show jsonDecode;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:syc/screens/konfirmasi_registrasi_ulang_screen.dart'
    show KonfirmasiRegistrasiUlangScreen;
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_snackbar.dart';
import '../services/api_service.dart';

class ScanQrScreen extends StatefulWidget {
  final String namakelompok;
  const ScanQrScreen({Key? key, required this.namakelompok}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _hasScanned = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    setState(() {
      controller = ctrl;
    });
    controller?.scannedDataStream.listen((scanData) {
      if (!_hasScanned) {
        setState(() {
          result = scanData;
          _hasScanned = true;
        });
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      if (!context.mounted) return;
      showCustomSnackBar(
        context,
        'No Permission | Buka setting aplikasi dan izinkan akses kamera',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < 400 ||
                MediaQuery.of(context).size.height < 400)
            ? 200.0
            : 300.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrasi Ulang Peserta Kelompok ${widget.namakelompok}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.pop(context, 'reload'),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.brown,
                  borderRadius: 12,
                  borderLength: 32,
                  borderWidth: 8,
                  cutOutSize: scanArea,
                ),
                onPermissionSet:
                    (ctrl, p) => _onPermissionSet(context, ctrl, p),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child:
                    result != null
                        ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (result != null) ...[
                                  _buildDecodedResultWidget(
                                    result,
                                    widget.namakelompok,
                                    context,
                                  ),
                                ],
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () async {
                                    await controller?.resumeCamera();
                                    setState(() {
                                      result = null;
                                      _hasScanned = false;
                                    });
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
                                      'Scan Lagi',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : const Text(
                          'Arahkan kamera ke QR peserta',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDecodedResultWidget(
  Barcode? result,
  String kelompokWidget,
  BuildContext context,
) {
  if (result == null) return const SizedBox();
  try {
    final data = result.code;
    print('QR Data: $data');
    String? secret;
    // Ambil secret dengan regex agar fleksibel dan tidak terpotong karakter base64
    final regex = RegExp(r'secret=([^&\s]+)');
    final match = regex.firstMatch(data ?? '');
    if (match != null) {
      secret = match.group(1);
      print('Secret found by regex: $secret');
    } else {
      print('Secret not found by regex');
    }

    if (secret == null || secret.isEmpty) {
      throw Exception('Secret tidak ditemukan di QR.');
    }

    // Handle karakter + dan spasi pada secret agar base64 valid
    secret = Uri.decodeComponent(secret).replaceAll(' ', '+');

    // Dekripsi secret
    print('SecretAAA: $secret');
    final decryptedSecret = decryptSecret(secret);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text(
        //   'Encrypted Secret: $secret',
        //   style: const TextStyle(fontSize: 12, color: Colors.grey),
        // ),
        // const SizedBox(height: 4),
        // Text(
        //   'Decrypted Secret: $decryptedSecret',
        //   style: const TextStyle(fontSize: 14, color: Colors.green),
        // ),
        // const SizedBox(height: 16),
        // ...existing code for API call and display...
        FutureBuilder<Map<String, dynamic>>(
          future:
              (() async {
                final res = await ApiService.getDataKonfirmasi(
                  context,
                  decryptedSecret!,
                );
                if (res['success'] == true && res['data'] != null) {
                  return Map<String, dynamic>.from(res['data']);
                } else {
                  throw Exception(res['message'] ?? 'Data tidak ditemukan.');
                }
              })(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            // else if (snapshot.hasError) {
            //   return Text(
            //     snapshot.error.toString(),
            //     style: const TextStyle(color: Colors.red),
            //   );
            // }
            else if (!snapshot.hasData) {
              return const Text('Data tidak ditemukan');
            }
            final dataKonfirmasi = snapshot.data!;
            print('Data Konfirmasi: $dataKonfirmasi');
            final nama = dataKonfirmasi['nama'] ?? '';
            final kelompok = dataKonfirmasi['kelompok'] ?? '';
            final role = dataKonfirmasi['role'] ?? '';
            final kelompokSama =
                kelompokWidget.trim().toLowerCase() ==
                kelompok.trim().toLowerCase();
            final statusDatang = dataKonfirmasi['status_datang']?.toString();
            // Cek jika kelompok tidak sama
            if (!kelompokSama) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'QR User ditemukan!',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nama: $nama',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: $role',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelompok: $kelompok',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.grey3,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Kelompok tidak sesuai!',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }

            // Cek jika response 401 (unauthorized), tampilkan pesan error dari API
            if (dataKonfirmasi['success'] == 'false') {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'QR User ditemukan!',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nama: $nama',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: $role',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelompok: $kelompok',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.grey3,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dataKonfirmasi['message'] ?? 'Unauthorized',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }

            // Jika bisa konfirmasi
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'QR User ditemukan!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nama: $nama',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Role: $role',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelompok: $kelompok',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => KonfirmasiRegistrasiUlangScreen(
                              qrResult: data ?? '',
                              metode: 'QR',
                            ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.brown1,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Konfirmasi Registrasi Ulang',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  } catch (e) {
    return const Text('QR tidak valid atau format salah');
  }
}

// Fungsi untuk mendekripsi secret (AES-256-CBC)
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
