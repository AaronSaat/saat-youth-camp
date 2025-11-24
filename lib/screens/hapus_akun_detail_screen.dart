// lib/screens/login_screen3.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/api_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syc/screens/hapus_akun_detail_success_screen.dart';
import 'package:timeago/timeago.dart'
    as timeago
    show IdMessages, setLocaleMessages;
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HapusAkunDetailScreen extends StatefulWidget {
  final String userId;
  final String nama;

  const HapusAkunDetailScreen({
    super.key,
    required this.userId,
    required this.nama,
  });

  @override
  State<HapusAkunDetailScreen> createState() => _HapusAkunDetailScreenState();
}

class _HapusAkunDetailScreenState extends State<HapusAkunDetailScreen> {
  bool _isLoading = false;
  bool _isChecked = false;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> _onSubmit() async {
    setState(() => _isLoading = true);
    try {
      final hapusAkunData = {
        "user_id": int.parse(widget.userId),
        "agree": _isChecked ? 1 : 0,
      };
      print('Submitting hapus akun: $hapusAkunData');
      try {
        final result = await ApiService().postHapusAkun(context, hapusAkunData);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => HapusAkunDetailSuccessScreen(
                  name: widget.nama,
                  isSuccess: result['success'] == true,
                ),
          ),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print('SharedPreferences cleared due to account deletion.');
        await secureStorage.deleteAll();
        print('Secure storage cleared due to account deletion.');
        // hapus temp dir dan app documents (hati-hati: ini menghapus file yang mungkin penting)
        try {
          final tempDir = await getTemporaryDirectory();
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
            debugPrint('Temporary directory deleted: ${tempDir.path}');
          }
        } catch (e) {
          debugPrint('Failed to delete temporary directory: $e');
        }

        try {
          final appDocDir = await getApplicationDocumentsDirectory();
          if (await appDocDir.exists()) {
            // jika Anda ingin lebih hati-hati, hapus hanya subfolder tertentu
            await appDocDir.delete(recursive: true);
            debugPrint('Application documents deleted: ${appDocDir.path}');
          }
        } catch (e) {
          debugPrint('Failed to delete application documents: $e');
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => HapusAkunDetailSuccessScreen(
                  name: widget.nama,
                  isSuccess: false,
                ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    timeago.setLocaleMessages('id', timeago.IdMessages());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, 'reload');
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () {
              Navigator.pop(context, 'reload');
            },
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
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 24),
                                        Center(
                                          child: Column(
                                            children: [
                                              Text(
                                                'Penghapusan Akun',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                widget.nama,
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Dengan menghapus akun, data berikut akan dihapus permanen oleh sistem:\n\n'
                                          '1. Informasi akun pengguna terkait dengan aplikasi SAAT Youth Camp (username dan password)\n'
                                          '2. Progres bacaan harian pengguna dan catatannya\n'
                                          '3. Foto profil pengguna\n'
                                          '4. Progres membaca pengumuman oleh pengguna\n\n'
                                          'Berikut data yang tidak dihapus di sistem:\n\n'
                                          '1. Progres jawaban evaluasi oleh peserta\n'
                                          '2. Progres jawaban komitmen oleh peserta\n\n'
                                          'Data yang telah dihapus tidak dapat dipulihkan. Anda perlu melakukan pendaftaran kembali menggunakan email dan secret code untuk menggunakan aplikasi SAAT Youth Camp.\n',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 14,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text:
                                                    'Jika ada pertanyaan, silakan hubungi email support: ',
                                              ),
                                              WidgetSpan(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    final Uri
                                                    emailLaunchUri = Uri(
                                                      scheme: 'mailto',
                                                      path:
                                                          'webteam@seabs.ac.id',
                                                    );
                                                    await launchUrl(
                                                      emailLaunchUri,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'webteam@seabs.ac.id',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      decoration:
                                                          TextDecoration
                                                              .underline,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _isChecked,
                                              onChanged: (val) {
                                                setState(() {
                                                  _isChecked = val ?? false;
                                                });
                                              },
                                              activeColor: AppColors.accent,
                                            ),
                                            const Expanded(
                                              child: Text(
                                                'Saya setuju dan memahami konsekuensi penghapusan akun.',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.accent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: GestureDetector(
                                            onTap:
                                                _isLoading || !_isChecked
                                                    ? () {
                                                      showCustomSnackBar(
                                                        context,
                                                        'Silakan centang checkbox persetujuan terlebih dahulu',
                                                      );
                                                    }
                                                    : _onSubmit,
                                            child: Container(
                                              width: double.infinity,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color:
                                                    _isChecked
                                                        ? AppColors.brown1
                                                        : AppColors.brown1
                                                            .withAlpha(70),
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                              ),
                                              alignment: Alignment.center,
                                              child:
                                                  _isLoading
                                                      ? const CircularProgressIndicator(
                                                        color: Colors.white,
                                                      )
                                                      : Text(
                                                        'Hapus Akun ${widget.nama}',
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: TextStyle(
                                                          color:
                                                              _isChecked
                                                                  ? Colors.white
                                                                  : AppColors
                                                                      .grey4,
                                                          fontSize:
                                                              ('Hapus Akun ${widget.nama}')
                                                                          .length >
                                                                      50
                                                                  ? 10.0
                                                                  : (('Hapus Akun ${widget.nama}')
                                                                              .length >
                                                                          30
                                                                      ? 12.0
                                                                      : 16.0),
                                                          fontWeight:
                                                              FontWeight.w500,
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
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
