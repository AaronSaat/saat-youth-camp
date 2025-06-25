import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syc/screens/anggota_kelompok_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_snackbar.dart';
import 'package:timeago/timeago.dart'
    as timeago
    show IdMessages, format, setLocaleMessages;

import '../services/api_service.dart';
import '../widgets/custom_card.dart';
import 'anggota_gereja_screen.dart';

class CatatanHarianScreen extends StatefulWidget {
  const CatatanHarianScreen({Key? key}) : super(key: key);

  @override
  _CatatanHarianScreenState createState() => _CatatanHarianScreenState();
}

class _CatatanHarianScreenState extends State<CatatanHarianScreen> {
  Map<String, dynamic> _dataCatatanHarian = {};
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  // 10 pastel colors, cenderung gelap, cocok untuk latar text putih
  final List<Color> pastelDarkColors = [
    const Color(0xFF6D8B74), // Deep Sage
    const Color(0xFF7D6E83), // Muted Purple
    const Color(0xFF8C7C68), // Dusty Olive
    const Color(0xFF5B7B7A), // Slate Teal
    const Color(0xFF7A7265), // Smoky Taupe
    const Color(0xFF6C7A89), // Blue Grey
    const Color(0xFF7B8C6A), // Moss Green
    const Color(0xFF7A6F73), // Mauve
    const Color(0xFF6E6E6E), // Charcoal Grey
    const Color(0xFF5D7261), // Forest Green
  ];

  @override
  void initState() {
    timeago.setLocaleMessages('id', timeago.IdMessages());
    super.initState();
    initAll();
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
        print("Data fetched: ${_dataCatatanHarian}");
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToPreviousDate() async {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    await initAll();
  }

  void _goToNextDate() async {
    if (_selectedDate.add(const Duration(days: 1)).isAfter(DateTime.now())) {
      showCustomSnackBar(context, "Tidak bisa melihat catatan besok.");
      return;
    } else {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
      await initAll();
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Catatan Harian',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.brown1,
                              ),
                              onPressed: _goToPreviousDate,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Tanggal: ${_formatDate(_selectedDate)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.brown1,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.brown1,
                              ),
                              onPressed: _goToNextDate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_dataCatatanHarian['data_brm'] != null &&
                          _dataCatatanHarian['data_brm']['passage'] != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.menu_book_rounded,
                                color: AppColors.brown1,
                                size: 20,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  "${_dataCatatanHarian['data_brm']['passage']}",
                                  style: TextStyle(
                                    color: AppColors.brown1,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? buildListShimmer(context)
                          : (_dataCatatanHarian['success'] == false ||
                              _dataCatatanHarian['status'] == 'Not Found' ||
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
                                  "Gagal memuat data catatan harian :(",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.brown1,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : (_dataCatatanHarian['data_notes'] is List &&
                              _dataCatatanHarian['data_notes'] != null)
                          ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                (_dataCatatanHarian['data_notes'] as List)
                                    .length,
                            itemBuilder: (context, index) {
                              final note =
                                  _dataCatatanHarian['data_notes'][index];
                              final time = timeago.format(
                                DateTime.parse(note['created_at'].toString()),
                                locale: 'id',
                              );

                              if (note["notes"] != null &&
                                  note["notes"].toString().trim().isNotEmpty) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  color:
                                      pastelDarkColors[index %
                                          pastelDarkColors.length],
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
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        note['nama'] ?? '-',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 24,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Kelompok: ${note['kelompok'] ?? '-'}",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 32),
                                                  Flexible(
                                                    child: Text(
                                                      note['created_at'] != null
                                                          ? timeago.format(
                                                            DateTime.fromMillisecondsSinceEpoch(
                                                              int.parse(
                                                                    note['created_at']
                                                                        .toString(),
                                                                  ) *
                                                                  1000,
                                                            ),
                                                            locale: 'id',
                                                          )
                                                          : '',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 24),
                                              Text(
                                                "${note['notes'] ?? '-'}",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          )
                          : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/data_not_found.png',
                                  height: 100,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Tidak ada data catatan harian.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.brown1,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
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
