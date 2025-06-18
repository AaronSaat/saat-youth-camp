import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_not_found.dart';
import '../widgets/custom_pin_textfield.dart';
import 'bible_reading_list_screen.dart';
import 'daftar_acara_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'package:syc/utils/app_colors.dart';

import 'detail_acara_screen.dart';
import 'bible_reading_more_screen.dart';
import 'evaluasi_komitmen_list_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, String> _dataUser = {};
  List<Map<String, dynamic>> _dataBrm = [];

  // progress
  Map<String, List<bool>> _komitmenDoneMap = {};
  Map<String, Map<String, int>> _komitmenSummaryMap = {};
  Map<String, List<bool>> _evaluasiDoneMap = {};
  Map<String, Map<String, int>> _evaluasiSummaryMap = {};

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    setState(() => _isLoading = true);
    try {
      await loadUserData();
      await loadProgresKomitmenAnggota();
      await loadProgresEvaluasiAnggota();
      await loadBrm();
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      'nama',
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

  Future<void> loadProgresKomitmenAnggota() async {
    try {
      final komitmenList = await ApiService.getKomitmen(context);
      _komitmenDoneMap = {};
      _komitmenSummaryMap = {};
      final userId = _dataUser['id'] ?? '';
      List<bool> progress = List.filled(komitmenList.length, false);
      for (int i = 0; i < progress.length; i++) {
        try {
          final result = await ApiService.getKomitmenByPesertaByDay(context, userId, i + 1);
          if (result['success'] == true) {
            progress[i] = true;
          }
        } catch (e) {
          // ignore error, keep as false
        }
      }
      _komitmenDoneMap[userId] = progress;
      // Hitung jumlah true/false
      int done = progress.where((e) => e).length;
      int notDone = progress.length - done;
      _komitmenSummaryMap[userId] = {'done': done, 'notDone': notDone};
      print('Progress Komitmen Map: \n$_komitmenDoneMap');
      print('Summary Komitmen Map: \n$_komitmenSummaryMap');
    } catch (e) {
      print('❌ Gagal memuat progress komitmen: $e');
    }
  }

  Future<void> loadProgresEvaluasiAnggota() async {
    if (!mounted) return;
    try {
      final acaraList = await ApiService.getAcara(context);
      _evaluasiDoneMap = {};
      _evaluasiSummaryMap = {};
      final userId = _dataUser['id'] ?? '';
      List<bool> progress = List.filled(acaraList.length, false);
      for (int i = 0; i < progress.length; i++) {
        try {
          final result = await ApiService.getEvaluasiByPesertaByAcara(context, userId, i + 1);
          if (result['success'] == true) {
            progress[i] = true;
          }
        } catch (e) {
          // ignore error, keep as false
        }
      }
      _evaluasiDoneMap[userId] = progress;
      // Hitung jumlah true/false
      int done = progress.where((e) => e).length;
      int notDone = progress.length - done;
      _evaluasiSummaryMap[userId] = {'done': done, 'notDone': notDone};
      print('Progress evaluasi Map: \n$_evaluasiDoneMap');
      print('Summary evaluasi Map: \n$_evaluasiSummaryMap');
    } catch (e) {
      // Use a logging framework or handle error appropriately
      if (!mounted) return;
    }
  }

  Future<void> loadBrm() async {
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
        // print('Data BRM: $_dataBrm');
        _isLoading = false;
      });
    } catch (e) {}
  }

  Future<void> logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = _dataUser['id'] ?? '';
    final gereja = _dataUser['gereja_nama'] ?? '';
    final kelompok = _dataUser['kelompok_nama'] ?? '';
    final role = _dataUser['role'] ?? '';
    final name = _dataUser['nama'] ?? '';

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_profile.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => initAll(),
              color: AppColors.brown1,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 96, left: 24.0, right: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          // Align(
                          //   alignment: Alignment.topRight,
                          //   child: Image.asset(
                          //     'assets/buttons/hamburger_white.png',
                          //     height: 48,
                          //     width: 48,
                          //   ),
                          // ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: MediaQuery.of(context).size.width * 0.3,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: AssetImage(() {
                                    switch (role) {
                                      case 'Pembina':
                                        return 'assets/mockups/pembina.jpg';
                                      case 'Peserta':
                                        return 'assets/mockups/peserta.jpg';
                                      case 'Pembimbing Kelompok':
                                        return 'assets/mockups/pembimbing.jpg';
                                      case 'Panitia':
                                        return 'assets/mockups/panitia.jpg';
                                      default:
                                        return 'assets/mockups/unknown.jpg';
                                    }
                                  }()),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (role != 'Panitia')
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    Row(
                                      children: [
                                        Card(
                                          color: AppColors.secondary,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.work, size: 12, color: AppColors.primary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  role.replaceAll(' Kelompok', ''),
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (kelompok.isNotEmpty && kelompok != 'Null')
                                          Card(
                                            color: AppColors.secondary,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.group, size: 12, color: AppColors.primary),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    kelompok,
                                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (gereja.isNotEmpty && gereja != 'Null')
                                      Card(
                                        color: AppColors.secondary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.church, size: 16, color: AppColors.primary),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  gereja,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 3,
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // CustomPinTextfield(),
                          // progress evaluasi dan komitmen
                          if (!role.toLowerCase().contains('panitia') && !role.toLowerCase().contains('pembimbing'))
                            _isLoading
                                ? buildAcaraShimmer()
                                //     : _acaraList.isEmpty
                                //     ? Center(
                                //       child: CustomNotFound(
                                //         text: "Gagal memuat daftar materi :(",
                                //         textColor: AppColors.brown1,
                                //         imagePath: 'assets/images/data_not_found.png',
                                //         onBack: initAll,
                                //         backText: 'Reload Materi',
                                //       ),
                                //     )
                                : Builder(
                                  builder: (context) {
                                    // Ambil userId dari _dataUser
                                    final userId = _dataUser['id'] ?? '';
                                    // Progress Evaluasi
                                    final progressEvaluasi = _evaluasiDoneMap[userId] ?? [];
                                    final evaluasiTotal = progressEvaluasi.length;
                                    final evaluasiDone = progressEvaluasi.where((e) => e).length;
                                    final evaluasiProgress = evaluasiTotal > 0 ? evaluasiDone / evaluasiTotal : 0.0;

                                    // Progress Komitmen
                                    final progressKomitmen = _komitmenDoneMap[userId] ?? [];
                                    final komitmenTotal = progressKomitmen.length;
                                    final komitmenDone = progressKomitmen.where((e) => e).length;
                                    final komitmenProgress = komitmenTotal > 0 ? komitmenDone / komitmenTotal : 0.0;

                                    return Column(
                                      children: [
                                        MateriMenuCard(
                                          title: 'Evaluasi Pribadi',
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        EvaluasiKomitmenListScreen(type: 'Evaluasi', userId: userId),
                                              ),
                                            ).then((result) {
                                              if (result == 'reload') {
                                                initAll();
                                              }
                                            });
                                            ;
                                          },
                                          valueProgress: evaluasiProgress,
                                          valueDone: evaluasiDone,
                                          valueTotal: evaluasiTotal,
                                        ),
                                        MateriMenuCard(
                                          title: 'Komitmen Pribadi',
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        EvaluasiKomitmenListScreen(type: 'Komitmen', userId: userId),
                                              ),
                                            );
                                          },
                                          valueProgress: komitmenProgress,
                                          valueDone: komitmenDone,
                                          valueTotal: komitmenTotal,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                          if (!role.toLowerCase().contains('panitia') && !role.toLowerCase().contains('pembimbing'))
                            const SizedBox(height: 16),
                          if (!role.toLowerCase().contains('panitia') && !role.toLowerCase().contains('pembimbing'))
                            _isLoading
                                ? buildBacaanShimer()
                                //     : _acaraList.isEmpty
                                //     ? Center(
                                //       child: CustomNotFound(
                                //         text: "Gagal memuat daftar materi :(",
                                //         textColor: AppColors.brown1,
                                //         imagePath: 'assets/images/data_not_found.png',
                                //         onBack: initAll,
                                //         backText: 'Reload Materi',
                                //       ),
                                //     )
                                :
                                // card bacaan
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => BibleReadingListScreen(userId: id)),
                                    ).then((result) {
                                      if (result == 'reload') {
                                        initAll(); // reload dashboard
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 180,
                                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withAlpha(70),
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.center,
                                            colors: [Colors.black.withAlpha(100), Colors.black.withAlpha(10)],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          image: const DecorationImage(
                                            image: AssetImage('assets/mockups/bible_reading.jpg'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Bacaan Saya',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _dataBrm.isNotEmpty ? (_dataBrm[0]['passage'] ?? '') : '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
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
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Text(
                                            _dataBrm.isNotEmpty
                                                ? DateFormatter.ubahTanggal(_dataBrm[0]['tanggal'])
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
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                logoutUser(context);
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

Widget buildAcaraShimmer() {
  return Column(
    children: List.generate(2, (index) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 18,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    ),
                    Container(
                      width: 24,
                      height: 18,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(height: 12, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Container(
                        width: 40,
                        height: 16,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }),
  );
}

Widget buildBacaanShimer() {
  return Stack(
    children: [
      Container(
        height: 180,
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(16)),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 120,
                  height: 24,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 8),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: Container(
              width: 60,
              height: 16,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
    ],
  );
}

class MateriMenuCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double valueProgress;
  final int? valueDone;
  final int? valueTotal;

  const MateriMenuCard({
    super.key,
    required this.title,
    required this.onTap,
    this.valueProgress = 0.0,
    this.valueDone,
    this.valueTotal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: valueProgress,
                            minHeight: 12,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                      ),
                      if (valueDone != null && valueTotal != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            '$valueDone/$valueTotal',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
