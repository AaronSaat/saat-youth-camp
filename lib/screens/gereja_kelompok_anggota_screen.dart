import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syc/utils/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/custom_not_found.dart';
import 'evaluasi_komitmen_list_screen.dart';
import 'gereja_kelompok_list_screen.dart';

class GerejaKelompokAnggotaScreen extends StatefulWidget {
  final String?
  type; // Panitia Gereja / Panitia Kelompok / Peserta / Pembimbing Kelompok / Pembina Gereja
  final String? id;
  const GerejaKelompokAnggotaScreen({
    Key? key,
    required this.type,
    required this.id,
  }) : super(key: key);

  @override
  State<GerejaKelompokAnggotaScreen> createState() =>
      _GerejaKelompokAnggotaScreenState();
}

class _GerejaKelompokAnggotaScreenState
    extends State<GerejaKelompokAnggotaScreen> {
  List<dynamic> anggota = [];
  String? nama;
  dynamic selectedUser;
  String selectedTab = 'Komitmen';
  List<bool> isSelected = [false, true];
  final List<String> opsi = ['Gereja', 'Kelompok'];
  bool _isLoading = true;
  String gereja_atau_kelompok = '';

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    try {
      if (widget.type == 'Peserta' ||
          widget.type == 'Pembimbing Kelompok' ||
          widget.type == 'Panitia Kelompok') {
        await loadAnggotaKelompok(widget.id);
      } else if (widget.type == 'Pembina Gereja' ||
          widget.type == 'Panitia Gereja') {
        await loadAnggotaGereja(widget.id);
      }
    } catch (e) {
      // handle error jika perlu
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadAnggotaGereja(gerejaId) async {
    try {
      final response = await ApiService.getAnggotaGereja(context, gerejaId);
      setState(() {
        gereja_atau_kelompok = 'Gereja';
        nama = response['nama_gereja'];
        anggota = response['data_anggota_gereja'];
      });
      print('Gereja atau kelompok?: $gereja_atau_kelompok');
    } catch (e) {
      setState(() {});
      print('Gagal mengambil data gereja: $e');
    }
  }

  Future<void> loadAnggotaKelompok(kelompokId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.getAnggotaKelompok(context, kelompokId);
      setState(() {
        gereja_atau_kelompok = 'Kelompok';
        nama = response['nama_kelompok'];
        anggota = response['data_anggota_kelompok'];
      });
    } catch (e) {
      setState(() {});
      print('Gagal mengambil data kelompok: $e');
    }
  }

  String getRoleImage(String role) {
    print('Role: $role, Gereja atau Kelompok: $gereja_atau_kelompok');
    if (gereja_atau_kelompok == "Gereja" && role == "Pembina") {
      return 'assets/mockups/pembina.jpg';
    } else if (gereja_atau_kelompok == "Gereja" && role == "Anggota") {
      return 'assets/mockups/peserta.jpg';
    } else if (gereja_atau_kelompok == "Kelompok" && role == "Pembimbing") {
      return 'assets/mockups/pembimbing.jpg';
    } else if (gereja_atau_kelompok == "Kelompok" && role == "Anggota") {
      return 'assets/mockups/peserta.jpg';
    } else {
      return 'assets/mockups/panitia.jpg';
    }
  }

  IconData getRoleIcon(String role) {
    print('Role: $role, Gereja atau Kelompok: $gereja_atau_kelompok');
    if (gereja_atau_kelompok == "Gereja" && role == "Pembina") {
      return Icons.church;
    } else if (gereja_atau_kelompok == "Gereja" && role == "Anggota") {
      return Icons.person_2;
    } else if (gereja_atau_kelompok == "Kelompok" && role == "Pembimbing") {
      return Icons.leaderboard;
    } else if (gereja_atau_kelompok == "Kelompok" && role == "Anggota") {
      return Icons.person;
    } else {
      return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            Navigator.canPop(context)
                ? BackButton(color: AppColors.primary)
                : null,
        actions:
            (widget.type == 'Panitia Kelompok' ||
                    widget.type == 'Panitia Gereja')
                ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(32),
                      borderWidth: 1,
                      selectedBorderColor: AppColors.primary,
                      selectedColor: Colors.white,
                      fillColor: AppColors.primary,
                      color: AppColors.primary,
                      constraints: const BoxConstraints(
                        minHeight: 40,
                        minWidth: 90,
                      ),
                      isSelected: isSelected,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < isSelected.length; i++) {
                            isSelected[i] = i == index;
                          }
                        });
                        if (index == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      GerejaKelompokListScreen(type: 'Gereja'),
                            ),
                          );
                        } else if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => GerejaKelompokListScreen(
                                    type: 'Kelompok',
                                  ),
                            ),
                          );
                        }
                      },
                      children: opsi.map((label) => Text(label)).toList(),
                    ),
                  ),
                ]
                : null,
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
              onRefresh: () => _initAll(),
              color: AppColors.brown1,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 96,
                  ),
                  child:
                      _isLoading
                          ? buildAnggotaShimmer()
                          : anggota.isEmpty
                          ? Center(
                            child: CustomNotFound(
                              text: "Gagal memuat anggota gereja / kelompok :(",
                              textColor: AppColors.brown1,
                              imagePath: 'assets/images/data_not_found.png',
                              onBack: _initAll,
                              backText: 'Reload Anggota',
                            ),
                          )
                          : Column(
                            children: [
                              Text(
                                '${gereja_atau_kelompok.isNotEmpty ? gereja_atau_kelompok : ''} ${nama ?? ''}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: anggota.length,
                                itemBuilder: (context, index) {
                                  final user = anggota[index];
                                  return Card(
                                    elevation: 0,
                                    color: Colors.grey[200],
                                    margin: const EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      top: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: SizedBox(
                                      height: 170,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 140,
                                                  width: 140,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                16,
                                                              ),
                                                          topLeft:
                                                              Radius.circular(
                                                                16,
                                                              ),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                16,
                                                              ),
                                                          bottomRight:
                                                              Radius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                        getRoleImage(
                                                          user['role'] ?? '',
                                                        ),
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),

                                                if (user['role'] == "Pembina" ||
                                                    user['role'] ==
                                                        "Pembimbing")
                                                  Positioned(
                                                    right: -5,
                                                    bottom: -5,
                                                    child: Card(
                                                      color: Colors.yellow[700],
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              topLeft:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                              bottomRight:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                      ),
                                                      elevation: 0,
                                                      child: const SizedBox(
                                                        width: 48,
                                                        height: 36,
                                                        child: Icon(
                                                          Icons.star,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            child: SizedBox(
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.35,
                                              height: 170,
                                              child: Column(
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
                                                        user['nama'] ?? '',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors.primary,
                                                          fontSize:
                                                              (user['nama'] !=
                                                                          null &&
                                                                      user['nama']
                                                                              .length >
                                                                          15)
                                                                  ? 14
                                                                  : 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                      const SizedBox(height: 4),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: 210,
                                                        height: 30,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                AppColors
                                                                    .brown1,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    32,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => EvaluasiKomitmenListScreen(
                                                                      type:
                                                                          'Komitmen',
                                                                      userId:
                                                                          user['id']
                                                                              .toString(),
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                          child: const Text(
                                                            'KOMITMEN',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      SizedBox(
                                                        width: 210,
                                                        height: 30,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                AppColors
                                                                    .brown1,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    32,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => EvaluasiKomitmenListScreen(
                                                                      type:
                                                                          'Evaluasi',
                                                                      userId:
                                                                          user['id']
                                                                              .toString(),
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                          child: const Text(
                                                            'EVALUASI',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
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
}

Widget buildAnggotaShimmer() {
  return Padding(
    padding: const EdgeInsets.only(left: 8, right: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Card(
              elevation: 0,
              color: Colors.grey[200],
              margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: SizedBox(
                height: 170,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox(
                        width: 120,
                        height: 170,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 90,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 90,
                                    height: 28,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                ),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 90,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
  );
}
