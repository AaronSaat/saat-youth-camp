// lib/screens/login_screen3.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart'
    as timeago
    show IdMessages, format, setLocaleMessages;
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class PengumumanDetailScreen extends StatefulWidget {
  final String tanggal;
  final String judul;
  final String deskripsi;
  final String id;
  final String userId;
  final bool read;

  const PengumumanDetailScreen({
    super.key,
    required this.tanggal,
    required this.judul,
    required this.deskripsi,
    required this.id,
    required this.userId,
    required this.read,
  });

  @override
  State<PengumumanDetailScreen> createState() => _PengumumanDetailScreenState();
}

class _PengumumanDetailScreenState extends State<PengumumanDetailScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    timeago.setLocaleMessages('id', timeago.IdMessages());
    super.initState();

    // Kirim data jika pengumuman belum dibaca
    if (!widget.read) {
      initAll();
    }
  }

  Future<void> initAll() async {
    setState(() => _isLoading = true);
    try {
      final pengumumanData = {
        "user_id": int.parse(widget.userId),
        "pengumuman_id": int.parse(widget.id),
      };
      print('Submitting answers: $pengumumanData');
      // Kirim ke API
      try {
        await ApiService.postPengumumanMarkRead(context, pengumumanData);
        if (mounted) {
          // showCustomSnackBar(context, "Jawaban evaluasi berhasil dikirim.");
          print('Pengumuman marked as read successfully');
        }
      } catch (e) {
        if (mounted) {
          // showCustomSnackBar(
          //   context,
          //   "Gagal mengirim jawaban evaluasi. Silakan coba lagi.",
          // );
          print('Error marking pengumuman as read');
        }
      }
    } catch (e) {}
    if (!mounted) return;
    setState(() => _isLoading = false);
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
        // resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
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
                            AppBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              leading: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  Navigator.pop(context, 'reload');
                                },
                              ),
                              automaticallyImplyLeading: false,
                            ),
                            Expanded(
                              child: Center(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // ClipRRect(
                                        //   borderRadius: BorderRadius.circular(16),
                                        //   child: Image.asset(
                                        //     'assets/images/event.jpg',
                                        //     width:
                                        //         MediaQuery.of(
                                        //           context,
                                        //         ).size.width *
                                        //         0.8,
                                        //     height: 200,
                                        //     fit: BoxFit.cover,
                                        //   ),
                                        // ),
                                        const SizedBox(height: 24),
                                        Text(
                                          widget.judul,
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          timeago.format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(
                                                    widget.tanggal.toString(),
                                                  ) *
                                                  1000,
                                            ),
                                            locale: 'id',
                                          ),
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),

                                        // Use flutter_html to render HTML content
                                        // Add flutter_html to your pubspec.yaml dependencies
                                        // import 'package:flutter_html/flutter_html.dart'; at the top
                                        Html(
                                          data: widget.deskripsi,
                                          style: {
                                            "body": Style(
                                              color: AppColors.primary,
                                              fontSize: FontSize(16),
                                              fontWeight: FontWeight.w400,
                                              textAlign: TextAlign.left,
                                            ),
                                          },
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
