import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import 'daftar_acara_screen.dart';
import 'detail_acara_screen.dart';
import 'form_komitmen_screen.dart';
import 'profil_screen.dart';

import '/widgets/custom_arrow_button.dart';

import 'package:syc/utils/app_colors.dart';

import 'read_more_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _email = '';
  bool isPanitia = false;
  ScrollController _komitmenController = ScrollController();
  ScrollController _evaluasiController = ScrollController();
  int _currentKomitmenPage = 0;
  int _currentEvaluasiPage = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _dataBrm = [];

  @override
  void initState() {
    super.initState();
    loadUsername();
    loadBrm();

    _komitmenController.addListener(() {
      double itemWidth = 160;
      setState(() {
        _currentKomitmenPage = (_komitmenController.offset / itemWidth).round();
      });
    });
    _evaluasiController.addListener(() {
      double itemWidth = 110;
      setState(() {
        _currentEvaluasiPage = (_evaluasiController.offset / itemWidth).round();
      });
    });
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? 'No Email';
    final role = prefs.getString('role');
    setState(() {
      _email = email;
      isPanitia = (role == 'Panitia');
    });
  }

  Future<void> loadBrm() async {
    setState(() => _isLoading = true);
    try {
      final brm = await ApiService.getBrmToday(context);
      setState(() {
        final dataBrm = brm['data_brm'];
        if (dataBrm != null && dataBrm is Map<String, dynamic>) {
          _dataBrm = [dataBrm];
        } else {
          _dataBrm = [];
        }
        print('Data BRM: $_dataBrm');
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToKomitmen(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => const EvaluasiKomitmenFormScreen()),
    // );
  }

  void _navigateToEvaluasi(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => const EvaluasiKomitmenFormScreen()),
    // );
  }

  @override
  void dispose() {
    _komitmenController.dispose();
    _evaluasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _dataBrm;
    print('Data BRM Test: $data');
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_dashboard.jpg',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Image.asset(
                                'assets/buttons/hamburger_white.png',
                                height: 48,
                                width: 48,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/texts/hello.png',
                                  height: 96,
                                ),
                                Text(
                                  _email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Bible Reading Movement
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Text(
                            //   'Bible Reading Movement',
                            //   style: TextStyle(
                            //     fontSize: 20,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // const SizedBox(height: 12),
                            _isLoading
                                ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 32,
                                    ),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),
                                )
                                : InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const ReadMoreScreen(
                                              userId: '80',
                                            ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    height: 180,
                                    padding: const EdgeInsets.only(
                                      left: 24,
                                      right: 24,
                                      bottom: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (_dataBrm.isNotEmpty) ...[
                                            Row(
                                              children: [
                                                Text(
                                                  'Bacaan Hari Ini',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  DateFormatter.ubahTanggal(
                                                    _dataBrm[0]['tanggal'],
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _dataBrm[0]['passage'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ] else ...[
                                            const Text(
                                              "Tidak ada data BRM hari ini",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Komitmen
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Konten Acara',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                CircleButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const DaftarAcaraScreen(),
                                      ),
                                    );
                                  },
                                  icon: Icons.arrow_forward,
                                  iconColor: Colors.black,
                                  backgroundColor: AppColors.primary.withAlpha(
                                    30,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              height: 160,
                              child: ListView.builder(
                                controller: _komitmenController,
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: _komitmenCard(
                                      context,
                                      'Konten ${index + 1}',
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width:
                                        _currentKomitmenPage == index ? 12 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color:
                                          _currentKomitmenPage == index
                                              ? AppColors.primary
                                              : Colors.grey,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  // Kotak Kuning di atas scroll
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Card Kotak Kuning',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _komitmenCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () => _navigateToKomitmen(context),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment, size: 40, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String name, int current, int total) {
    double percent = current / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: Colors.white24,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(
          '$current / $total',
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}
