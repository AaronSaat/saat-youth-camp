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

  // progress
  Map<String, List<bool>> _komitmenDoneMap = {};
  Map<String, Map<String, int>> _komitmenSummaryMap = {};
  Map<String, List<bool>> _evaluasiDoneMap = {};
  Map<String, Map<String, int>> _evaluasiSummaryMap = {};

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.type == 'Peserta' ||
          widget.type == 'Pembimbing Kelompok' ||
          widget.type == 'Panitia Kelompok') {
        await loadAnggotaKelompok(widget.id);
      } else if (widget.type == 'Pembina Gereja' ||
          widget.type == 'Panitia Gereja') {
        await loadAnggotaGereja(widget.id);
      }
      await loadProgresKomitmenAnggota();
      await loadProgresEvaluasiAnggota();
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
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.getAnggotaGereja(context, gerejaId);
      setState(() {
        gereja_atau_kelompok = 'Gereja';
        nama = response['nama_gereja'];
        anggota = response['data_anggota_gereja'];
        _isLoading = false;
      });
      print('Gereja atau kelompok?: $gereja_atau_kelompok');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Gagal mengambil data kelompok: $e');
    }
  }

  Future<void> loadProgresKomitmenAnggota() async {
    try {
      final komitmenList = await ApiService.getKomitmen(context);
      _komitmenDoneMap = {};
      _komitmenSummaryMap = {};
      for (var user in anggota) {
        final userId = user['id'].toString();
        List<bool> progress = List.filled(komitmenList.length, false);
        for (int i = 0; i < progress.length; i++) {
          try {
            final result = await ApiService.getKomitmenByPesertaByDay(
              context,
              userId,
              i + 1,
            );
            if (result['success'] == true) {
              progress[i] = true;
            }
          } catch (e) {
            // ignore error, keep as false
          }
        }
        _komitmenDoneMap[userId] = progress;
        // Hitung jumlah true/false
        int done = progress.where((e) => e).length;
        int notDone = progress.length - done;
        _komitmenSummaryMap[userId] = {'done': done, 'notDone': notDone};
      }
      print('Progress Komitmen Map: \n$_komitmenDoneMap');
      print('Summary Komitmen Map: \n$_komitmenSummaryMap');
    } catch (e) {
      print('❌ Gagal memuat progress komitmen: $e');
    }
  }

  Future<void> loadProgresEvaluasiAnggota() async {
    if (!mounted) return;
    try {
      final acaraList = await ApiService.getAcara(context);
      _evaluasiDoneMap = {};
      _evaluasiSummaryMap = {};
      for (var user in anggota) {
        final userId = user['id'].toString();
        List<bool> progress = List.filled(acaraList.length, false);
        for (int i = 0; i < progress.length; i++) {
          try {
            final result = await ApiService.getEvaluasiByPesertaByAcara(
              context,
              userId,
              i + 1,
            );
            if (result['success'] == true) {
              progress[i] = true;
            }
          } catch (e) {
            // ignore error, keep as false
          }
        }
        _evaluasiDoneMap[userId] = progress;
        // Hitung jumlah true/false
        int done = progress.where((e) => e).length;
        int notDone = progress.length - done;
        _evaluasiSummaryMap[userId] = {'done': done, 'notDone': notDone};
      }
      print('Progress evaluasi Map: \n$_evaluasiDoneMap');
      print('Summary evaluasi Map: \n$_evaluasiSummaryMap');
    } catch (e) {
      // Use a logging framework or handle error appropriately
      if (!mounted) return;
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
                                                if ((user['gender'] == "P" ||
                                                        user['gender'] == "L" ||
                                                        user['gender'] ==
                                                            null) &&
                                                    user['role'] !=
                                                        "Pembimbing")
                                                  Positioned(
                                                    top: -5,
                                                    right: -5,
                                                    child: Card(
                                                      color:
                                                          user['gender'] == "P"
                                                              ? Colors.pink
                                                              : user['gender'] ==
                                                                  "L"
                                                              ? Colors.blue
                                                              : Colors.grey,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              bottomLeft:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                              topRight:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                      ),
                                                      elevation: 0,
                                                      child: SizedBox(
                                                        width: 48,
                                                        height: 36,
                                                        child: Icon(
                                                          user['gender'] == "P"
                                                              ? Icons.female
                                                              : user['gender'] ==
                                                                  "L"
                                                              ? Icons.male
                                                              : Icons
                                                                  .help_outline,
                                                          color: Colors.white,
                                                        ),
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
                                                // show komitmen progress
                                                if (user['role'] == "Anggota")
                                                  Positioned(
                                                    bottom: -5,
                                                    left: -5,
                                                    child: Card(
                                                      color: AppColors.brown1,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              topRight:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                              bottomLeft:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                      ),
                                                      elevation: 0,
                                                      child: SizedBox(
                                                        width: 72,
                                                        height: 36,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.checklist,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Builder(
                                                              builder: (
                                                                context,
                                                              ) {
                                                                final summary =
                                                                    _komitmenSummaryMap[user['id']
                                                                        .toString()];
                                                                if (summary ==
                                                                    null) {
                                                                  return const Text(
                                                                    '-',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                  );
                                                                }
                                                                return Text(
                                                                  '${summary['done']}/${summary['done']! + summary['notDone']!}',
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                // show evaluasi progress
                                                if (user['role'] == "Anggota")
                                                  Positioned(
                                                    top: -5,
                                                    left: -5,
                                                    child: Card(
                                                      color: AppColors.brown1,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              bottomRight:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                              topLeft:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                      ),
                                                      elevation: 0,
                                                      child: SizedBox(
                                                        width: 72,
                                                        height: 36,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .assignment_turned_in,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Builder(
                                                              builder: (
                                                                context,
                                                              ) {
                                                                final summary =
                                                                    _evaluasiSummaryMap[user['id']
                                                                        .toString()];
                                                                if (summary ==
                                                                    null) {
                                                                  return const Text(
                                                                    '-',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                  );
                                                                }
                                                                return Text(
                                                                  '${summary['done']}/${summary['done']! + summary['notDone']!}',
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
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
