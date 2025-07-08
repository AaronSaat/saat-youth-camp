import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syc/screens/anggota_kelompok_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_count_up.dart' show CustomCountUp;
import 'package:syc/widgets/custom_snackbar.dart';
import 'package:timeago/timeago.dart'
    as timeago
    show IdMessages, format, setLocaleMessages;
import 'package:url_launcher/url_launcher.dart'
    show canLaunchUrl, LaunchMode, launchUrl;

import '../services/api_service.dart';
import '../widgets/custom_card.dart';
import 'anggota_gereja_screen.dart';

class KontakPanitiaScreen extends StatefulWidget {
  const KontakPanitiaScreen({Key? key}) : super(key: key);

  @override
  _KontakPanitiaScreenState createState() => _KontakPanitiaScreenState();
}

class _KontakPanitiaScreenState extends State<KontakPanitiaScreen> {
  Map<String, dynamic> _dataCatatanHarian = {
    "success": true,
    "message": "Data ditemukan",
    "data_notes": [
      {"nama": "Aaron", "peran": "BPH", "nomor": "+62 812-3453-602"},
      {"nama": "Aaron", "peran": "Kesehatan", "nomor": "029-964-1153"},
      {"nama": "Aaron", "peran": "Perlengkapan", "nomor": "029-964-1153"},
    ],
  };

  // loadingnya jadi satu saja (tidak perlu dipisah dengan data panitia)
  bool _isLoading = false;

  DateTime _selectedDate = DateTime.now();

  // progress untuk panitia
  Map<String, String> _bacaanDoneMapPanitia = {};
  Map<String, String> _countUserMapPanitia = {};

  @override
  void initState() {
    timeago.setLocaleMessages('id', timeago.IdMessages());
    super.initState();
    // initAll();
    print("Data Kontak: $_dataCatatanHarian");
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print(
        "Fetching data for date: ${_selectedDate.toIso8601String().substring(0, 10)}",
      );
      final dataCatatan = await ApiService.getBrmByDay(
        context,
        _selectedDate.toIso8601String().substring(0, 10),
      );

      if (!mounted) return;
      setState(() {
        _dataCatatanHarian = dataCatatan;
        print("Data Kontak: ${_dataCatatanHarian}");
        // print("Data bacaan: ${_bacaanDoneMapPanitia}");
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dataCatatanHarian = {};
        print("Error fetching data");
        _isLoading = false;
      });
    }
  }

  Future<void> loadCountUser() async {
    if (!mounted) return;
    setState(() {});
    try {
      final _countUser = await ApiService.getCountUser(context);
      if (!mounted) return;
      setState(() {
        _countUserMapPanitia = _countUser.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
        print('Count User Map: $_countUserMapPanitia');
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Kontak Panitia',
          style: TextStyle(
            color: AppColors.brown1,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brown1),
      ),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_anggota.jpg',
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
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 24.0,
                    top: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isLoading
                          ? buildListShimmer(context)
                          : (_dataCatatanHarian['success'] == false ||
                              _dataCatatanHarian['data_notes'] == null ||
                              !(_dataCatatanHarian['data_notes'] is List) ||
                              (_dataCatatanHarian['data_notes'] as List)
                                  .isEmpty)
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
                                  "Gagal memuat data kontak panitia :(",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.brown1,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                (_dataCatatanHarian['data_notes'] as List)
                                    .length,
                            itemBuilder: (context, index) {
                              final note =
                                  _dataCatatanHarian['data_notes'][index];

                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  final nomor = note['nomor']?.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  );
                                  if (nomor != null && nomor.isNotEmpty) {
                                    final waUrl = 'https://wa.me/$nomor';
                                    if (await canLaunchUrl(Uri.parse(waUrl))) {
                                      await launchUrl(
                                        Uri.parse(waUrl),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      showCustomSnackBar(
                                        context,
                                        'Tidak dapat membuka WhatsApp',
                                      );
                                    }
                                  }
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  color: AppColors.brown1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                note['nama'] ?? '-',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Peran: ${note['peran'] ?? '-'}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.phone,
                                                    color: Colors.white70,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    note['nomor'] ?? '-',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
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
                                ),
                              );
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
    );
  }
}

Widget buildListShimmer(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      height: 7 * 86.0, // 7 item x tinggi item + padding
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget buildProgresBacaanPanitiaShimmerCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      height: 1 * 86.0,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
