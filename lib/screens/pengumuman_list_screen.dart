// lib/screens/login_screen3.dart

import 'dart:convert'; // Tambahkan jika belum ada
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart' show Shimmer;
import 'package:timeago/timeago.dart'
    as timeago
    show IdMessages, format, setLocaleMessages;

import '../services/api_service.dart';
import '../widgets/custom_not_found.dart';
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
  bool _isLoading = false;
  List<Map<String, dynamic>> _pengumumanList = [];
  Map<String, dynamic> _dataUser = {};

  @override
  void initState() {
    timeago.setLocaleMessages('id', timeago.IdMessages());
    super.initState();
    initAll();
  }

  Future<void> initAll({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    try {
      await loadUserData();
      await loadPengumumanByUserId(forceRefresh: forceRefresh);
    } catch (e) {}
    if (!mounted) return;
    setState(() => _isLoading = false);
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

  Future<void> loadPengumumanByUserId({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    final userId = _dataUser['id'] ?? '';
    final pengumumanKey = 'pengumuman_list_$userId';

    if (!forceRefresh) {
      final cachedPengumuman = prefs.getString(pengumumanKey);
      if (cachedPengumuman != null) {
        final List<dynamic> decoded = jsonDecode(cachedPengumuman);
        final pengumumanList2 = List<Map<String, dynamic>>.from(decoded);
        setState(() {
          _pengumumanList = pengumumanList2;
          _isLoading = false;
          print(
            '[PREF_API] Pengumuman List (from shared pref): $_pengumumanList',
          );
        });
        return;
      }
    }

    try {
      final pengumumanList = await ApiService.getPengumuman(context, userId);
      await prefs.setString(pengumumanKey, jsonEncode(pengumumanList));
      if (!mounted) return;
      setState(() {
        final pengumumanList2 = List<Map<String, dynamic>>.from(pengumumanList);
        _pengumumanList = pengumumanList2;
        _isLoading = false;
        print('[PREF_API] Pengumuman List (from API): $_pengumumanList');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
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
              child: RefreshIndicator(
                onRefresh: () => initAll(forceRefresh: true),
                color: AppColors.brown1,
                backgroundColor: Colors.white,
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
                            Navigator.pop(context, 'reload');
                          },
                        ),
                        automaticallyImplyLeading: false,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            right: 16,
                            left: 16,
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PENGUMUMAN',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        'Info terbaru!',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 84),
                                Expanded(
                                  child:
                                      _isLoading
                                          ? buildPengumumanShimmerList()
                                          : (_pengumumanList.isEmpty
                                              ? Center(
                                                child: CustomNotFound(
                                                  text:
                                                      "Gagal memuat daftar pengumuman :(",
                                                  textColor: AppColors.brown1,
                                                  imagePath:
                                                      'assets/images/data_not_found.png',
                                                ),
                                              )
                                              : ListView.builder(
                                                itemCount:
                                                    _pengumumanList.length,
                                                itemBuilder: (context, index) {
                                                  final pengumuman =
                                                      _pengumumanList[index];
                                                  final bool isRead =
                                                      pengumuman["count_read"] >
                                                      0;
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Column(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => PengumumanDetailScreen(
                                                                      tanggal:
                                                                          pengumuman['created_at']
                                                                              ?.toString() ??
                                                                          '',
                                                                      judul:
                                                                          pengumuman['judul'] ??
                                                                          '',
                                                                      deskripsi:
                                                                          pengumuman['detail'] ??
                                                                          '',
                                                                      id:
                                                                          pengumuman['id']
                                                                              ?.toString() ??
                                                                          '',
                                                                      userId:
                                                                          _dataUser['id'] ??
                                                                          '',
                                                                      read:
                                                                          isRead,
                                                                    ),
                                                              ),
                                                            ).then((result) {
                                                              if (result ==
                                                                  'reload') {
                                                                initAll();
                                                              }
                                                            });
                                                          },
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      right:
                                                                          12.0,
                                                                    ),
                                                                child: Icon(
                                                                  Icons
                                                                      .campaign,
                                                                  color:
                                                                      isRead
                                                                          ? AppColors
                                                                              .grey4
                                                                          : AppColors
                                                                              .primary,
                                                                  size: 40,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 3,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      pengumuman['judul'] ??
                                                                          '',
                                                                      style: TextStyle(
                                                                        color:
                                                                            isRead
                                                                                ? AppColors.grey4
                                                                                : AppColors.primary,
                                                                        fontWeight:
                                                                            isRead
                                                                                ? FontWeight.w500
                                                                                : FontWeight.w900,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    Text(
                                                                      pengumuman["detail"]
                                                                          .replaceAll(
                                                                            RegExp(
                                                                              r'<[^>]*>',
                                                                            ),
                                                                            '',
                                                                          )
                                                                          .trim(),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                        color:
                                                                            isRead
                                                                                ? AppColors.grey4
                                                                                : AppColors.primary,
                                                                        fontWeight:
                                                                            isRead
                                                                                ? FontWeight.w400
                                                                                : FontWeight.w700,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Center(
                                                                  child: Text(
                                                                    pengumuman['created_at'] !=
                                                                            null
                                                                        ? timeago.format(
                                                                          DateTime.fromMillisecondsSinceEpoch(
                                                                            int.parse(
                                                                                  pengumuman['created_at'].toString(),
                                                                                ) *
                                                                                1000,
                                                                          ),
                                                                          locale:
                                                                              'id',
                                                                        )
                                                                        : '',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                      color:
                                                                          isRead
                                                                              ? AppColors.grey4
                                                                              : AppColors.primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        const Divider(
                                                          color:
                                                              AppColors.grey2,
                                                          height: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildPengumumanShimmerList() {
  return ListView.builder(
    itemCount: 6,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          period: const Duration(milliseconds: 800),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon shimmer
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Judul dan deskripsi shimmer
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 120, height: 16, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(width: 180, height: 14, color: Colors.white),
                      ],
                    ),
                  ),
                  // Tanggal shimmer
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.grey, height: 2),
            ],
          ),
        ),
      );
    },
  );
}

Widget buildShimmerList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(5, (index) {
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
