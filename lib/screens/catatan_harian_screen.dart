import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_count_up.dart' show CustomCountUp;
import 'package:syc/widgets/custom_snackbar.dart';
import 'package:timeago/timeago.dart'
    as timeago
    show IdMessages, format, setLocaleMessages;

import '../services/api_service.dart';

class CatatanHarianScreen extends StatefulWidget {
  final String role;
  final String id;
  final DateTime initialDate;
  const CatatanHarianScreen({
    Key? key,
    required this.role,
    required this.id,
    required this.initialDate,
  }) : super(key: key);

  @override
  _CatatanHarianScreenState createState() => _CatatanHarianScreenState();
}

class _CatatanHarianScreenState extends State<CatatanHarianScreen> {
  Map<String, dynamic> _dataCatatanHarian = {};

  // loadingnya jadi satu saja (tidak perlu dipisah dengan data panitia)
  bool _isLoading = true;

  //untuk pagination
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _pageSize = 10;

  DateTime _selectedDate = DateTime.now();

  // progress untuk panitia
  Map<String, String> _bacaanDoneMapPanitia = {};
  Map<String, String> _countUserMapPanitia = {};

  final ScrollController _scrollController = ScrollController();

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
    _selectedDate = widget.initialDate;
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchMoreNotes();
      }
    });
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _page = 1;
      _hasMore = true;
    });

    await loadCountUser();
    try {
      print(
        "Fetching data for date: ${_selectedDate.toIso8601String().substring(0, 10)}",
      );
      final dataCatatan = await ApiService().getBrmNotesByDay(
        context,
        _selectedDate.toIso8601String().substring(0, 10),
        widget.id,
        _page,
        _pageSize,
      );

      final dataBacaan = await ApiService().getCountBrmReportByDay(
        context,
        _selectedDate.toIso8601String().substring(0, 10),
      );

      if (!mounted) return;
      setState(() {
        _bacaanDoneMapPanitia = dataBacaan.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      });
      print('Bacaan Done Map: $_bacaanDoneMapPanitia');

      if (!mounted) return;
      setState(() {
        _dataCatatanHarian = dataCatatan;
        print(
          'LENGTH CATATAN LOAD PERTAMA: ${_dataCatatanHarian['data_notes'].length}',
        );
        _isLoading = false;
        print('isloading: $_isLoading');
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
      final _countUser = await ApiService().getCountUser(context);
      if (!mounted) return;
      setState(() {
        _countUserMapPanitia = _countUser.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
        print('Count User Map: $_countUserMapPanitia');
      });
    } catch (e) {}
  }

  void _goToPreviousDate() async {
    final now = DateTime.now();
    final tenDaysAgo = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 19));
    final previousDate = _selectedDate.subtract(const Duration(days: 1));
    if (previousDate.isBefore(tenDaysAgo)) {
      showCustomSnackBar(
        context,
        "Hanya bisa melihat catatan 10 hari terakhir.",
      );
      return;
    }
    setState(() {
      _selectedDate = previousDate;
    });
    await initAll();
  }

  void _goToNextDate() async {
    // if (_selectedDate.add(const Duration(days: 1)).isAfter(DateTime.now())) {
    //   showCustomSnackBar(context, "Tidak bisa melihat catatan besok.");
    //   return;
    // } else {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    await initAll();
    // }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _fetchMoreNotes() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final newNotes = await ApiService().getBrmNotesByDay(
        context,
        _selectedDate.toIso8601String().substring(0, 10),
        widget.id,
        _page + 1,
        _pageSize,
      );
      final newDataNotes = newNotes['data_notes'];
      if (newDataNotes is List) {
        final int totalData =
            int.tryParse(newNotes['count_data_notes']?.toString() ?? '0') ?? 0;
        final int currentLength =
            (_dataCatatanHarian['data_notes'] as List).length +
            newDataNotes.length;
        if (newDataNotes.isEmpty ||
            newDataNotes.length < _pageSize ||
            currentLength >= totalData) {
          _hasMore = false;
        }
        setState(() {
          _page++;
          _dataCatatanHarian['data_notes'].addAll(newNotes['data_notes']);
          _dataCatatanHarian['count_data_notes'] = totalData;
        });
      }
    } catch (e) {
      // handle error jika perlu
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.brown1,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Catatan Harian',
          style: TextStyle(
            color: AppColors.brown1,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                          color: AppColors.brown1,
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
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "${_dataCatatanHarian['data_brm']['passage']}",
                                style: TextStyle(
                                  color: Colors.white,
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
                    _isLoading
                        ? buildProgresBacaanPanitiaShimmerCard(context)
                        : (() {
                          final progresPesertaStr =
                              _bacaanDoneMapPanitia['count_peserta'] ?? '0';
                          final progresPembinaStr =
                              _bacaanDoneMapPanitia['count_pembina'] ?? '0';
                          final totalStr = _countUserMapPanitia['count'] ?? '0';
                          final progresPeserta =
                              int.tryParse(progresPesertaStr) ?? 0;
                          final progresPembina =
                              int.tryParse(progresPembinaStr) ?? 0;
                          final totalProgres = progresPeserta + progresPembina;
                          final total = int.tryParse(totalStr) ?? 0;
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: AppColors.brown1,
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
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                CustomCountUp(
                                  target: totalProgres,
                                  duration: Duration(seconds: 2),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    "/ $total menyelesaikan bacaannya hari ini",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })(),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
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
                                controller: _scrollController,
                                // shrinkWrap: true,
                                // physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    (_dataCatatanHarian['data_notes'] as List)
                                        .length +
                                    (_hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  final length =
                                      _dataCatatanHarian['data_notes'].length;
                                  if (index < length && !_isLoading) {
                                    final note =
                                        _dataCatatanHarian['data_notes'][index];
                                    if (note["notes"] != null &&
                                        note["notes"]
                                            .toString()
                                            .trim()
                                            .isNotEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          if (note['user_id']
                                                                  .toString() ==
                                                              widget.id)
                                                            Container(
                                                              width: 24,
                                                              height: 24,
                                                              decoration: BoxDecoration(
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                                color:
                                                                    AppColors
                                                                        .primary,
                                                              ),
                                                              child: const Icon(
                                                                Icons.person,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                size: 16,
                                                              ),
                                                            ),
                                                          if (note['user_id']
                                                                  .toString() ==
                                                              widget.id)
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                          Text(
                                                            note['nama'] ?? '-',
                                                            style: const TextStyle(
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "Kelompok: ${note['kelompok'] ?? '-'}",
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors.primary,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        note["notes"] ?? '',
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors.brown1,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
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
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            const Divider(
                                              color: AppColors.grey2,
                                              height: 2,
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  } else if (_isLoadingMore) {
                                    // WidgetsBinding.instance.addPostFrameCallback((_) {
                                    //   _fetchMoreNotes();
                                    // });
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    );
                                  }
                                },
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
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
