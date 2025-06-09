import 'package:flutter/material.dart';
import 'package:syc/screens/zzz_temp_codes.dart';
import 'package:syc/utils/app_colors.dart';

import '../services/api_service.dart';
import '../widgets/custom_card.dart';
import 'gereja_kelompok_anggota_screen.dart';

class GerejaKelompokListScreen extends StatefulWidget {
  final String type;

  const GerejaKelompokListScreen({Key? key, required this.type})
    : super(key: key);

  @override
  _GerejaKelompokListScreenState createState() =>
      _GerejaKelompokListScreenState();
}

class _GerejaKelompokListScreenState extends State<GerejaKelompokListScreen> {
  List<dynamic> _kelompokList = [];
  List<dynamic> _gerejaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'Gereja') {
      loadGereja();
    } else if (widget.type == 'Kelompok') {
      loadKelompok();
      _isLoading = false;
    }
  }

  void loadGereja() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final gerejaList = await ApiService.getGereja(context);
      setState(() {
        _gerejaList = gerejaList ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat gereja: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void loadKelompok() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final kelompokList = await ApiService.getKelompok(context);
      setState(() {
        _kelompokList = kelompokList ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat kelompok: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
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
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      bottom: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              widget.type == 'Gereja'
                                  ? 'assets/texts/daftar_gereja.png'
                                  : 'assets/texts/daftar_kelompok.png',
                              height: 128,
                            ),
                          ],
                        ),
                        // Tidak ada day selector di desain ini
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              widget.type == 'Gereja'
                                  ? _gerejaList.length
                                  : _kelompokList.length,
                          itemBuilder: (context, index) {
                            if (widget.type == 'Gereja') {
                              final gereja = _gerejaList[index];
                              return CustomCard(
                                text: gereja['nama_gereja'] ?? 'Gereja???',
                                icon: Icons.church,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              GerejaKelompokAnggotaScreen(
                                                type: 'Pembina Gereja',
                                                id:
                                                    gereja['gereja_id'] ??
                                                    'Gereja???',
                                              ),
                                    ),
                                  );
                                },
                                iconBackgroundColor: AppColors.brown1,
                              );
                            } else {
                              final kelompok = _kelompokList[index];
                              return CustomCard(
                                text:
                                    kelompok['nama_kelompok'] ?? 'Kelompok???',
                                icon: Icons.group,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (
                                            context,
                                          ) => GerejaKelompokAnggotaScreen(
                                            type: 'Peserta',
                                            id:
                                                '${kelompok['id'] ?? 'Kelompok???'}',
                                          ),
                                    ),
                                  );
                                },
                                iconBackgroundColor: AppColors.brown1,
                              );
                            }
                          },
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
