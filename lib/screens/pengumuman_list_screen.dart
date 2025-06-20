// lib/screens/login_screen3.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/app_colors.dart';
import 'main_screen.dart';
import 'check_secret_screen.dart';
import 'pengumuman_detail_screen.dart';

class PengumumanListScreen extends StatefulWidget {
  const PengumumanListScreen({super.key});

  @override
  State<PengumumanListScreen> createState() => _PengumumanListScreenState();
}

class _PengumumanListScreenState extends State<PengumumanListScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_pengumuman.jpg',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    automaticallyImplyLeading: false,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 128.0),
                      child: Center(
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/images/event.jpg',
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    'Pengumuman ${index + 1}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Ini adalah deskripsi pengumuman ${index + 1}.',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                PengumumanDetailScreen(),
                                      ),
                                    );
                                  },
                                ),
                                if (index < 9)
                                  const Divider(
                                    color: AppColors.grey2,
                                    height: 2,
                                  ),
                              ],
                            );
                          },
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
