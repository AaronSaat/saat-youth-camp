import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.type == 'Gereja') {
        final gerejaList = await ApiService.getGereja(context);
        if (!mounted) return;
        setState(() {
          _gerejaList = gerejaList;
          _isLoading = false;
        });
      } else if (widget.type == 'Kelompok') {
        final kelompokList = await ApiService.getKelompok(context);
        if (!mounted) return;
        setState(() {
          _kelompokList = kelompokList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
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
          SafeArea(
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
                    _isLoading
                        ? buildListShimmer(context)
                        : (widget.type == 'Gereja'
                            ? _gerejaList.isEmpty
                            : _kelompokList.isEmpty)
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/data_not_found.png',
                                height: 100,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.type == 'Gereja'
                                    ? "Gagal memuat daftar gereja :("
                                    : "Gagal memuat daftar kelompok :(",
                                style: const TextStyle(
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

Widget buildListShimmer(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      height: 7 * 86.0, // 7 item x tinggi item + padding
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 7,
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
