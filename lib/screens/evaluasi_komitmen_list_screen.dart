import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/app_colors.dart';

class EvaluasiKomitmenListScreen extends StatefulWidget {
  final String type;
  final String userId;

  const EvaluasiKomitmenListScreen({
    Key? key,
    required this.type,
    required this.userId,
  }) : super(key: key);

  @override
  _EvaluasiKomitmenListScreenState createState() =>
      _EvaluasiKomitmenListScreenState();
}

class _EvaluasiKomitmenListScreenState
    extends State<EvaluasiKomitmenListScreen> {
  List<dynamic> _acaraList = [];
  List<dynamic> _komitmenList = [];
  bool _isLoading = true;
  int day = 1; // default day
  int _countAcara = 1;
  int _countAcaraAll = 1;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'Evaluasi') {
      loadAcara();
      loadCountAcara();
    } else if (widget.type == 'Komitmen') {
      loadKomitmen();
    } else {
      _isLoading = false;
    }
  }

  void loadAcara() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final acaraList = await ApiService.getAcaraByDay(context, day);
      setState(() {
        _acaraList = acaraList ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat list acara: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void loadKomitmen() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final komitmenList = await ApiService.getKomitmen(context);
      setState(() {
        _komitmenList = komitmenList ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat list komitmen: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ini untuk acara-count dan acara-count-all (jadi satu)
  void loadCountAcara() async {
    try {
      final countAcara = await ApiService.getAcaraCount(context);
      final countAcaraAll = await ApiService.getAcaraCountAll(context);
      setState(() {
        _countAcara = countAcara ?? 0;
        _countAcaraAll = countAcaraAll ?? 0;
      });
    } catch (e) {
      print('❌ Gagal memuat acara count dan acara count all: $e');
    }
  }
  // void loadEvaluasi(userId, acaraId) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     final evaluasiList = await ApiService.getEvaluasiByPesertaByDay(context, userId, acaraId);
  //     setState(() {
  //       _evaluasiList = evaluasiList ?? [];
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     print('❌ Gagal memuat evaluasi oleh user $userId pada hari $acaraId: $e');
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
  // void loadKomitmen(userId, acaraId) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     final komitmenList = await ApiService.getKomitmenByPesertaByDay(context, userId, acaraId);
  //     setState(() {
  //       _komitmenList = komitmenList ?? [];
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     print('❌ Gagal memuat komitmen oleh user $userId pada hari $acaraId: $e');
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Widget _buildDaySelector() {
    List<int> days = List.generate(_countAcara, (index) => index + 1);
    if (_countAcaraAll > _countAcara) {
      days.add(99);
    }
    // Tambahkan ScrollController agar bisa scroll ke tab yang dipilih
    final ScrollController _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Scroll ke posisi tab yang dipilih setelah build
      int selectedIdx = days.indexOf(day);
      if (selectedIdx != -1 && _scrollController.hasClients) {
        double offset = (selectedIdx * 108.0) - 16.0; // 100(width) + 8(spacing)
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
        height: 56,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: days.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, idx) {
            final d = days[idx];
            final bool selected = day == d;
            return GestureDetector(
              onTap: () {
                if (day != d) {
                  setState(() {
                    day = d;
                  });
                  loadAcara();
                }
              },
              child: Container(
                width: 100,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  d == 99 ? 'Overall' : 'Day $d',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text(widget.type, style: const TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_member_list.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          if (widget.type == 'Evaluasi') _buildDaySelector(),
                          Expanded(
                            child: ListView.builder(
                              itemCount:
                                  widget.type == 'Evaluasi'
                                      ? _acaraList.length
                                      : _komitmenList.length,
                              itemBuilder: (context, index) {
                                final items =
                                    widget.type == 'Evaluasi'
                                        ? _acaraList
                                        : _komitmenList;

                                String item;
                                if (widget.type == 'Evaluasi') {
                                  final acara = items[index];
                                  item =
                                      '${acara['acara_nama'] ?? '-'} (Hari ${acara['hari'] ?? '-'})';
                                } else {
                                  final komitmen = items[index];
                                  item =
                                      'Komitmen Hari ${komitmen['hari'] ?? '-'}';
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(color: Colors.white),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    title: Text(
                                      item,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_right_sharp,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                    onTap: () {},
                                  ),
                                );
                              },
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
