import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_panel_shape.dart';

import '../services/api_service.dart';
import '../widgets/custom_not_found.dart';
import 'detail_acara_screen.dart';

class DaftarAcaraScreen extends StatefulWidget {
  const DaftarAcaraScreen({super.key});

  @override
  State<DaftarAcaraScreen> createState() => _DaftarAcaraScreenState();
}

class _DaftarAcaraScreenState extends State<DaftarAcaraScreen> {
  List<dynamic> _acaraList = [];
  int _countAcara = 0;
  bool _isLoading = true;
  int day = 1;

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await loadCountAcara();
      await loadAcara();
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> loadAcara() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final acaraList = await ApiService.getAcaraByDay(context, day);
      if (!mounted) return;
      setState(() {
        _acaraList = acaraList;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat acara: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadCountAcara() async {
    try {
      final countAcara = await ApiService.getAcaraCount(context);
      if (!mounted) return;
      setState(() {
        _countAcara = countAcara;
      });
    } catch (e) {
      print('❌ Gagal memuat acara count: $e');
    }
  }

  Widget _buildDaySelector() {
    final List<int> days = List.generate(_countAcara, (index) => index + 1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            days.map((d) {
              final bool selected = day == d;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      if (day != d) {
                        setState(() {
                          day = d;
                        });
                        loadAcara();
                      }
                    },
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Day $d',
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_fade.jpg',
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
                  padding: EdgeInsets.only(top: 24.0, bottom: 64),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.search,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                'assets/texts/events.png',
                                height: 72,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDaySelector(),
                      _isLoading
                          ? buildAcaraShimmer(context)
                          : _acaraList.isEmpty
                          ? Center(
                            child: CustomNotFound(
                              text: "Gagal memuat daftar acara :(",
                              textColor: AppColors.brown1,
                              imagePath: 'assets/images/data_not_found.png',
                              onBack: initAll,
                              backText: 'Reload Acara',
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: _acaraList.length,
                            itemBuilder: (context, index) {
                              final acara = _acaraList[index];
                              print(
                                'Acara: ${acara['id']} - ${acara['acara_nama']}',
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: SizedBox(
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      DetailAcaraScreen(
                                                        id: acara["id"],
                                                      ),
                                            ),
                                          );
                                        },
                                        child: CustomPanelShape(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.2,

                                          imageProvider: () {
                                            final nama =
                                                acara['acara_nama']
                                                    ?.toString() ??
                                                '';
                                            if (nama ==
                                                'Pendaftaran Ulang dan Kedatangan') {
                                              return Image.asset(
                                                'assets/mockups/daftar.jpg',
                                              ).image;
                                            } else if (nama == 'Opening') {
                                              return Image.asset(
                                                'assets/mockups/opening.jpg',
                                              ).image;
                                            } else if (nama == 'KKR 1') {
                                              return Image.asset(
                                                'assets/mockups/kkr1.jpg',
                                              ).image;
                                            } else if (nama == 'KKR 2') {
                                              return Image.asset(
                                                'assets/mockups/kkr2.jpg',
                                              ).image;
                                            } else if (nama == 'KKR 3') {
                                              return Image.asset(
                                                'assets/mockups/kkr3.jpg',
                                              ).image;
                                            } else if (nama == 'Saat Teduh') {
                                              return Image.asset(
                                                'assets/mockups/saat_teduh1.jpg',
                                              ).image;
                                            } else if (nama ==
                                                'Drama Musikal') {
                                              return Image.asset(
                                                'assets/mockups/drama_musikal.jpg',
                                              ).image;
                                            } else if (nama ==
                                                'New Year Countdown') {
                                              return Image.asset(
                                                'assets/mockups/new_year.jpg',
                                              ).image;
                                            } else if (nama == 'Closing') {
                                              return Image.asset(
                                                'assets/mockups/closing.jpg',
                                              ).image;
                                            } else {
                                              return Image.asset(
                                                'assets/images/event.jpg',
                                              ).image;
                                            }
                                          }(),
                                        ),
                                      ),
                                      Positioned(
                                        left: 24,
                                        bottom: 20,
                                        right: 16,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              acara['acara_nama']?.toString() ??
                                                  '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                                text: () {
                                                  final desc =
                                                      acara['acara_deskripsi']
                                                          ?.toString() ??
                                                      '';
                                                  if (desc.length > 30) {
                                                    return desc.substring(
                                                          0,
                                                          30,
                                                        ) +
                                                        '...';
                                                  }
                                                  return desc;
                                                }(),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        right:
                                            MediaQuery.of(context).size.width *
                                            0.1,
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                            0.007,
                                        child: Text(
                                          'Tap for More',
                                          style: const TextStyle(
                                            color: Color(0xFF606060),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
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

  // Shimmer loading untuk daftar acara
  Widget buildAcaraShimmer(BuildContext context, {int itemCount = 3}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            child: Stack(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 20,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 120,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 180,
                          height: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: MediaQuery.of(context).size.width * 0.1,
                  bottom: MediaQuery.of(context).size.height * 0.007,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 80,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
