// lib/screens/login_screen3.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart'
    as timeago
    show IdMessages, format, setLocaleMessages;

import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/app_colors.dart';
import 'main_screen.dart';
import 'check_secret_screen.dart';

class PengumumanDetailScreen extends StatefulWidget {
  final String tanggal;
  final String judul;
  final String deskripsi;

  const PengumumanDetailScreen({
    super.key,
    required this.tanggal,
    required this.judul,
    required this.deskripsi,
  });

  @override
  State<PengumumanDetailScreen> createState() => _PengumumanDetailScreenState();
}

class _PengumumanDetailScreenState extends State<PengumumanDetailScreen> {
  bool isLoading = false;

  @override
  void initState() {
    timeago.setLocaleMessages('id', timeago.IdMessages());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Positioned(
          //   child: Image.asset(
          //     'assets/images/background_pengumuman.jpg',
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //     fit: BoxFit.fill,
          //   ),
          // ),
          SafeArea(
            child: Padding(
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
                        Navigator.of(context).pop();
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ClipRRect(
                              //   borderRadius: BorderRadius.circular(16),
                              //   child: Image.asset(
                              //     'assets/images/event.jpg',
                              //     width:
                              //         MediaQuery.of(context).size.width * 0.8,
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
                                  DateTime.parse(widget.tanggal),
                                  locale: 'id',
                                ),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                widget.deskripsi.replaceAll(
                                  RegExp(r'<[^>]*>'),
                                  '',
                                ),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.left,
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
    );
  }
}
