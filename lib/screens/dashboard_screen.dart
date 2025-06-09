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
  Map<String, String> _dataUser = {};

  @override
  void initState() {
    _isLoading = true;
    super.initState();
    loadUserData();
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

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      'email',
      'role',
      'token',
      'gereja_id',
      'gereja_nama',
      'kelompok_id',
      'kelompok_nama',
    ];
    final Map<String, String> userData = {};
    for (final key in keys) {
      userData[key] = prefs.getString(key) ?? '';
    }
    if (!mounted) return;
    setState(() {
      _dataUser = userData;
    });
  }

  Future<void> loadBrm() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final brm = await ApiService.getBrmToday(context);
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _navigateToKomitmen(BuildContext context) {
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
    final userId = _dataUser['id'] ?? '-';
    final email = _dataUser['email'] ?? '-';
    final username = _dataUser['username'] ?? '-';

    final data = _dataBrm;
    print('Data BRM Test: $data');
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_dashboard.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 96.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/texts/hello.png', height: 72),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bible Reading Movement
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              : _dataBrm.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/data_not_found.png',
                                      height: 100,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      "Gagal memuat data bacaan :(",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.brown1,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              ReadMoreScreen(userId: userId),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Container(
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
                                              Text(
                                                'Bacaan Hari Ini',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                ),
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
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary,
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(16),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          _dataBrm.isNotEmpty
                                              ? DateFormatter.ubahTanggal(
                                                _dataBrm[0]['tanggal'],
                                              )
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Komitmen
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.grey1, // abu-abu muda
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Acara Hari Ini',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.brown1,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
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
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 160,
                              child: ListView.builder(
                                controller: _komitmenController,
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: GestureDetector(
                                      onTap: () => _navigateToKomitmen(context),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              height: 160,
                                              width: 160,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(16),
                                                      topLeft: Radius.circular(
                                                        16,
                                                      ),
                                                      bottomLeft:
                                                          Radius.circular(16),
                                                    ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Konten ${index + 1}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -5,
                                              right: -5,
                                              child: Card(
                                                color: AppColors.secondary,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                    ),
                                                elevation: 0,
                                                child: const SizedBox(
                                                  width: 48,
                                                  height: 36,
                                                  child: Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Yellow card / card kuning dengan megaphone di atasnya
                    Stack(
                      children: [
                        Container(
                          height: 140,
                          decoration: BoxDecoration(color: AppColors.secondary),
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 16,
                            bottom: 16,
                          ),
                          child: Row(
                            children: [
                              // Left column with 2 texts
                              Column(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Pengumuman',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          'Cek info terbaru di sini!',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: -15,
                          right: -12,
                          child: Image.asset(
                            'assets/images/megaphone.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
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
