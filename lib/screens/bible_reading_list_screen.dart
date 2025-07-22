import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:syc/screens/bible_reading_more_screen.dart';
import 'package:syc/screens/form_evaluasi_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_not_found.dart';
import '../widgets/custom_snackbar.dart';
import 'catatan_harian_screen.dart';
import 'evaluasi_komitmen_view_screen.dart';

class BibleReadingListScreen extends StatefulWidget {
  final String userId;

  const BibleReadingListScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  _BibleReadingListScreenState createState() => _BibleReadingListScreenState();
}

class _BibleReadingListScreenState extends State<BibleReadingListScreen> {
  bool _isLoading = true;
  int day = 1;
  int _hariKe = 1;
  int _jumlahHari = 1;
  String _namaBulan = '';
  List<dynamic> _dataBrm = [];
  Map<String, dynamic> _dataProgress = {};
  Map<String, String> _dataUser = {};
  List<String> _dataBacaan = [];
  List<String> _dataNotesBacaan = [];
  List<int> _dataProgressBacaan = [];
  bool _autoSelected = false;

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
      print('🔄 Memuat data bacaan harian...');
    });
    try {
      final hariKe = getCurrentDayOfMonth();
      final jumlahHari = getDaysInCurrentMonth();

      if (!mounted) return;
      setState(() {
        _hariKe = hariKe ?? 0;
        _jumlahHari = jumlahHari ?? 0;
        _namaBulan = getNamaBulan();
      });
      await loadUserData();
      await loadBrmByBulan();
      await loadBrmReportByPesertaByBulan();
      await loadReportCountBrmByPesertaByDay();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat acara count dan acara count all: $e');
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      print('✅ Data bacaan harian berhasil dimuat.');
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

  Future<void> loadBrmByBulan() async {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    try {
      final brm = await ApiService.getBrmByBulan(context, month);
      if (!mounted) return;
      setState(() {
        _dataBrm = brm;
        print('Data Brm Bulanan: $_dataBrm');
      });
    } catch (e) {}
  }

  Future<void> loadReportCountBrmByPesertaByDay() async {
    try {
      final now = DateTime.now();
      final year = now.year;
      final month = now.month;
      List<String> dateList = List.generate(_jumlahHari, (i) {
        final day = i + 1;
        return DateTime(year, month, day).toIso8601String().substring(0, 10);
      });

      List<int> countList = [];
      for (final date in dateList) {
        try {
          final count = await ApiService.getBrmReportCountByPesertaByDay(
            context,
            widget.userId,
            date,
          );
          countList.add(count);
        } catch (e) {
          countList.add(0);
        }
      }

      if (!mounted) return;
      setState(() {
        _dataProgressBacaan = countList;
      });
    } catch (e) {}
  }

  Future<void> loadBrmReportByPesertaByBulan() async {
    try {
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');

      final bacaan = await ApiService.getBrmReportByPesertaByBulan(
        context,
        widget.userId,
        month,
      );

      if (!mounted) return;
      setState(() {
        _dataProgress = bacaan;
        print('Data Progress Bulanan: $_dataProgress');
      });
    } catch (e) {}
  }

  int getCurrentDayOfMonth() {
    final now = DateTime.now();
    return now.day;
  }

  int getDaysInCurrentMonth() {
    final now = DateTime.now();
    final beginningNextMonth =
        (now.month < 12)
            ? DateTime(now.year, now.month + 1, 1)
            : DateTime(now.year + 1, 1, 1);
    final lastDayOfMonth = beginningNextMonth.subtract(const Duration(days: 1));
    return lastDayOfMonth.day;
  }

  String getNamaBulan() {
    const namaBulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final now = DateTime.now();
    int bulan = now.month;
    if (bulan < 1 || bulan > 12) return '';
    return namaBulan[bulan - 1];
  }

  Widget _buildDaySelector() {
    List<int> days = List.generate(_jumlahHari, (index) => index + 1);
    final ScrollController _scrollController = ScrollController();

    // Scroll to _hariKe after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int selectedIdx = days.indexOf(day);
      if (!_autoSelected && day == 1 && _hariKe > 0 && _hariKe <= _jumlahHari) {
        setState(() {
          day = _hariKe;
          _autoSelected = true; //supaya tidak reselect kalo bukan hari ke-1
          print('Selected day set to: $day from _hariKe: $_hariKe');
        });
        selectedIdx = days.indexOf(_hariKe);
      }
      if (selectedIdx != -1 && _scrollController.hasClients) {
        double offset = (selectedIdx * 108.0) - 16.0;
        if (offset < 0) offset = 0;
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: days.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final d = days[index];
            final bool selected = day == d;
            return GestureDetector(
              onTap: () {
                setState(() {
                  day = d;
                  print('Selected day: $day');
                  // initAll();
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 108,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$d $_namaBulan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (_dataProgressBacaan.length > index &&
                      _dataProgressBacaan[index] > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = _dataUser['id'] ?? '';
    final role = _dataUser['role'] ?? '';
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Bacaan Hari Ini',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: true,
        actions: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              _dataBrm.isNotEmpty
                  ? DateFormatter.ubahTanggal(_dataBrm![day - 1]['tanggal'])
                  : '',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_list_bacaan.jpg',
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
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 204.0,
                    left: 24.0,
                    right: 24.0,
                    bottom: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDaySelector(),
                      const SizedBox(height: 16),
                      _isLoading
                          ? buildShimmerList()
                          :
                          // _dataBacaan.isEmpty &&
                          //     _dataProgressBacaan.isEmpty &&
                          //     _dataNotesBacaan.isEmpty
                          // ? Center(
                          //   child: const CustomNotFound(
                          //     text: "Gagal memuat data brm hari ini :(",
                          //     textColor: AppColors.brown1,
                          //     imagePath: 'assets/images/data_not_found.png',
                          //   ),
                          // )
                          // :
                          // : (day == _hariKe)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hari $day dari $_jumlahHari',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                CustomCard(
                                  text:
                                      (_dataBrm.length >= day &&
                                              _dataBrm[day - 1]?['passage'] !=
                                                  null &&
                                              _dataBrm[day - 1]['passage']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? _dataBrm[day - 1]['passage']
                                              .toString()
                                          : '',
                                  // _dataBrm.isNotEmpty &&
                                  //         _dataBrm[0]['passage'] != null
                                  //     ? _dataBrm[0]['passage'].toString()
                                  //     : '',
                                  icon: Icons.menu_book_rounded,
                                  onTap: () {
                                    final userId = widget.userId;
                                    if (day == _hariKe && widget.userId == id) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  BibleReadingMoreScreen(
                                                    userId: userId,
                                                  ),
                                        ),
                                      ).then((result) {
                                        if (result == 'reload') {
                                          initAll();
                                        }
                                      });
                                    } else if (widget.userId != id) {
                                      setState(() {
                                        if (!mounted) return;
                                        showCustomSnackBar(
                                          context,
                                          'Tidak bisa mengakses bacaan milik orang lain',
                                          isSuccess: false,
                                        );
                                      });
                                    } else {
                                      setState(() {
                                        if (!mounted) return;
                                        showCustomSnackBar(
                                          context,
                                          'Hanya bisa mengakses bacaan $_hariKe $_namaBulan',
                                          isSuccess: false,
                                        );
                                      });
                                    }
                                  },
                                  iconBackgroundColor: AppColors.brown1,
                                  showCheckIcon: false,
                                ),
                                CustomCard(
                                  text: 'Catatan Harian',
                                  icon: Icons.sticky_note_2_rounded,
                                  iconBackgroundColor: AppColors.brown1,
                                  showCheckIcon: false,
                                  onTap: () {
                                    if (day <= _hariKe) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => CatatanHarianScreen(
                                                role: role,
                                                id: widget.userId,
                                                initialDate: DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  day,
                                                ),
                                              ),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        if (!mounted) return;
                                        showCustomSnackBar(
                                          context,
                                          'Hanya bisa mengakses catatan harian sebelum $_hariKe $_namaBulan',
                                          isSuccess: false,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                      // : Center(
                      //   child: CustomNotFound(
                      //     text:
                      //         "Hanya bisa menampilkan bacaan tanggal $_hariKe $_namaBulan :(",
                      //     textColor: Colors.white,
                      //     imagePath: 'assets/images/data_not_found.png',
                      //   ),
                      // ),
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

Widget buildShimmerList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(3, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }),
  );
}

Widget buildShimmerTabBarList() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
    child: SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 108,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          );
        },
      ),
    ),
  );
}
