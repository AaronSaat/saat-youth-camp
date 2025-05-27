import 'package:flutter/material.dart';

import '../services/api_service.dart';

class KelompokListScreen extends StatefulWidget {
  final String type;

  const KelompokListScreen({Key? key, required this.type}) : super(key: key);

  @override
  _KelompokListScreenState createState() => _KelompokListScreenState();
}

class _KelompokListScreenState extends State<KelompokListScreen> {
  final List<String> dummyKelompok = [
    'Kelompok 1 - Paulus',
    'Kelompok 2 - Petrus',
    'Kelompok 3 - Yohanes',
    'Kelompok 4 - Markus',
  ];
  List<dynamic> _kelompokList = [];
  List<dynamic> _gerejaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'Gereja') {
      loadGereja();
    } else {
      _isLoading = false;
    }
  }

  void loadGereja() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final gerejaList = await ApiService.getAllGereja(context);
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
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading: BackButton(color: Colors.white),
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
                                        gereja['nama_gereja'] ?? 'Gereja',
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
                                } else {
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
                                        dummyKelompok[index],
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
                                }
                              },
                              childCount:
                                  widget.type == 'Gereja'
                                      ? _gerejaList.length
                                      : dummyKelompok.length,
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
