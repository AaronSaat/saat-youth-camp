import 'package:flutter/material.dart';
import 'package:syc/screens/zzz_temp_codes.dart';

import '../services/api_service.dart';
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
                    : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading:
                              Navigator.canPop(context)
                                  ? BackButton(color: Colors.white)
                                  : null,
                          title: Text(
                            widget.type == 'Kelompok'
                                ? 'Daftar Kelompok'
                                : 'Daftar Gereja',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (widget.type == 'Gereja') {
                                  final gereja = _gerejaList[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(color: Colors.white),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      title: Text(
                                        gereja['nama_gereja'] ?? 'Gereja???',
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
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => GerejaKelompokAnggotaScreen(
                                                  type:
                                                      'Pembina Gereja', //nanti ganti sesuai role
                                                  id:
                                                      gereja['gereja_id'] ??
                                                      'Gereja???',
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  final kelompok = _kelompokList[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(color: Colors.white),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      title: Text(
                                        kelompok['nama_kelompok'] ??
                                            'Kelompok???',
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
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => GerejaKelompokAnggotaScreen(
                                                  type:
                                                      'Peserta', //nanti ganti sesuai role
                                                  id:
                                                      '${kelompok['id'] ?? 'Kelompok???'}',
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                              childCount:
                                  widget.type == 'Gereja'
                                      ? _gerejaList.length
                                      : _kelompokList.length,
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
