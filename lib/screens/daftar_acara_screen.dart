import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_panel_shape.dart';

import '../services/api_service.dart';

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
    loadAcara();
    loadCountAcara();
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
      print('❌ Gagal memuat acara: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void loadCountAcara() async {
    try {
      final countAcara = await ApiService.getAcaraCount(context);
      setState(() {
        _countAcara = countAcara ?? 0;
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
                      height: 48,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Day $d',
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
      appBar: AppBar(title: const Text('Daftar Acara')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDaySelector(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _acaraList.isEmpty
                      ? const Center(child: Text('Tidak ada acara.'))
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _acaraList.length,
                        itemBuilder: (context, index) {
                          final acara = _acaraList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SizedBox(
                              child: Stack(
                                children: [
                                  CustomPanelShape(
                                    width: 350,
                                    height: 180,
                                    imageProvider:
                                        Image.asset(
                                          'assets/images/event.jpg',
                                        ).image,
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
                                          acara['acara_nama']?.toString() ?? '',
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
                                                return desc.substring(0, 30) +
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
                                    right: 45,
                                    top: 155,
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
            ),
          ],
        ),
      ),
    );
  }
}
