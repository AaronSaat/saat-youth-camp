import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../services/api_service.dart';
import 'evaluasi_komitmen_list_screen.dart';
import 'gereja_kelompok_list_screen.dart';
import '../widgets/custom_snackbar.dart';

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
    // loadUserData();
    if (widget.type == 'Peserta') {
      isSelected = [false, true];
      loadAnggotaKelompok(widget.id);
    } else if (widget.type == 'Pembimbing Kelompok') {
      isSelected = [false, true];
      loadAnggotaKelompok(widget.id);
    } else if (widget.type == 'Pembina Gereja') {
      isSelected = [true, false];
      loadAnggotaGereja(widget.id);
    } else if (widget.type == 'Panitia Kelompok') {
      isSelected = [false, true];
      loadAnggotaKelompok(widget.id);
    } else if (widget.type == 'Panitia Gereja') {
      isSelected = [true, false];
      loadAnggotaGereja(widget.id);
    }
    // set current user email untuk 'anda'
  }

  Future<void> loadAnggotaGereja(gerejaId) async {
    try {
      final response = await ApiService.getAnggotaGereja(context, gerejaId);
      setState(() {
        gereja_atau_kelompok = 'Gereja';
        nama = response['nama_gereja'];
        anggota = response['data_anggota_gereja'];
      });
    } catch (e) {
      print('Gagal mengambil data gereja: $e');
    }
  }

  Future<void> loadAnggotaKelompok(kelompokId) async {
    try {
      final response = await ApiService.getAnggotaKelompok(context, kelompokId);
      setState(() {
        gereja_atau_kelompok = 'Kelompok';
        nama = response['nama_kelompok'];
        anggota = response['data_anggota_kelompok'];
      });
    } catch (e) {
      print('Gagal mengambil data kelompok: $e');
    }
  }

  // Future<void> loadUserData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     currentEmail = prefs.getString('email');
  //   });
  // }

  IconData getRoleIcon(String role) {
    // type: Panitia Gereja / Panitia Kelompok / Peserta / Pembimbing Kelompok / Pembina Gereja
    // role: Panitia, Pembina, Peserta, etc.
    if (gereja_atau_kelompok == 'Gereja' || role == 'Pembina') {
      return Icons.church;
    } else if (gereja_atau_kelompok == 'Gereja' || role == 'Peserta') {
      return Icons.person_2;
    } else if (gereja_atau_kelompok == 'Kelompok' || role == 'Pembimbing') {
      return Icons.leaderboard;
    } else if (gereja_atau_kelompok == 'Kelompok' || role == 'Anggota') {
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
            Navigator.canPop(context) ? BackButton(color: Colors.white) : null,
        title: Text(
          gereja_atau_kelompok == 'Kelompok'
              ? 'Kelompok ${nama ?? ''}'
              : nama ?? 'Nama Gereja/Kelompok???',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions:
            (widget.type == 'Panitia Kelompok' ||
                    widget.type == 'Panitia Gereja')
                ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(32),
                      borderWidth: 1,
                      borderColor: Colors.white54,
                      selectedBorderColor: Colors.white,
                      selectedColor: Colors.black,
                      fillColor: Colors.white70,
                      color: Colors.white,
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

      body:
          anggota.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/background_member2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Positioned.fill(child: Image.asset('assets/images/background_member2.png', fit: BoxFit.cover)),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 150,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  gereja_atau_kelompok == 'Kelompok'
                                      ? 'Kelompok ${nama ?? ''}'
                                      : nama ?? 'Nama Gereja/Kelompok???',
                                  style: TextStyle(
                                    fontSize:
                                        (() {
                                          final text =
                                              gereja_atau_kelompok == 'Kelompok'
                                                  ? 'Kelompok ${nama ?? ''}'
                                                  : nama ??
                                                      'Nama Gereja/Kelompok???';
                                          if (text.length > 60) {
                                            return 16.0;
                                          } else if (text.length > 30) {
                                            return 24.0;
                                          } else {
                                            return 36.0;
                                          }
                                        })(),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 120),
                          // card anggota kelompok
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: anggota.length,
                              itemBuilder: (context, index) {
                                final user = anggota[index];
                                // final isCurrentUser =
                                //     user['email'] == currentEmail;
                                final isSelected = selectedUser == user;

                                return GestureDetector(
                                  onTap:
                                      () => setState(() => selectedUser = user),
                                  child: Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color:
                                              isSelected
                                                  ? AppColors.primary
                                                  : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      elevation: isSelected ? 15 : 7,
                                      shadowColor:
                                          isSelected
                                              ? Colors.black45
                                              : Colors.black45,
                                      child: Stack(
                                        children: [
                                          // Lingkaran + Icon (tengah atas)
                                          Positioned(
                                            top: 24,
                                            left: 0,
                                            right: 0,
                                            child: Center(
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.primary,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Icon(
                                                  getRoleIcon(
                                                    user['role'] ??
                                                        'Jabatan???',
                                                  ),
                                                  size: 50,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Info pribadi (tengah bawah)
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 300,
                                              ),
                                              height: isSelected ? 100 : 50,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isSelected
                                                        ? AppColors.primary
                                                        : AppColors.primary
                                                            .withAlpha(40),
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                        16,
                                                      ),
                                                    ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    user['nama'] ?? '',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  if (isSelected) ...[
                                                    const SizedBox(height: 2),
                                                    Flexible(
                                                      child: Text(
                                                        user['email'] ?? '',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                    // Flexible(
                                                    //   child: Text(
                                                    //     user['roles'] ?? '',
                                                    //     style: const TextStyle(
                                                    //       color: Colors.white,
                                                    //       fontSize: 10,
                                                    //     ),
                                                    //     textAlign:
                                                    //         TextAlign.center,
                                                    //     overflow:
                                                    //         TextOverflow
                                                    //             .ellipsis,
                                                    //   ),
                                                    // ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Label ANDA (kanan atas)
                                          // if (isCurrentUser)
                                          //   Positioned(
                                          //     top: 8,
                                          //     right: 8,
                                          //     child: Container(
                                          //       width: 40,
                                          //       height: 20,
                                          //       padding:
                                          //           const EdgeInsets.symmetric(
                                          //             horizontal: 6,
                                          //             vertical: 2,
                                          //           ),
                                          //       decoration: BoxDecoration(
                                          //         color: AppColors.accent,
                                          //         borderRadius:
                                          //             BorderRadius.circular(8),
                                          //       ),
                                          //       child: const Text(
                                          //         'ANDA',
                                          //         style: TextStyle(
                                          //           color: Colors.white,
                                          //           fontSize: 10,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Scrollable content
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 40,
                                child: GestureDetector(
                                  onTap: () {
                                    if (selectedUser == null) {
                                      showCustomSnackBar(
                                        context,
                                        'Pilih anggota terlebih dahulu!',
                                      );
                                      return;
                                    }
                                    setState(() => selectedTab = 'Komitmen');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                EvaluasiKomitmenListScreen(
                                                  type: selectedTab,
                                                  userId: selectedUser['id'],
                                                ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          selectedTab == 'Komitmen'
                                              ? AppColors.primary
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                      border:
                                          selectedTab == 'Komitmen'
                                              ? null
                                              : Border.all(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: Text(
                                            'KOMITMEN',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        const Positioned(
                                          right: 4,
                                          child: Icon(
                                            Icons.arrow_right_sharp,
                                            size: 24,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 120,
                                height: 40,
                                child: GestureDetector(
                                  onTap: () {
                                    if (selectedUser == null) {
                                      showCustomSnackBar(
                                        context,
                                        'Pilih anggota terlebih dahulu!',
                                      );
                                      return;
                                    }
                                    setState(() => selectedTab = 'Evaluasi');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                EvaluasiKomitmenListScreen(
                                                  type: selectedTab,
                                                  userId: selectedUser['id'],
                                                ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          selectedTab == 'Evaluasi'
                                              ? AppColors.primary
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                      border:
                                          selectedTab == 'Evaluasi'
                                              ? null
                                              : Border.all(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: Text(
                                            'EVALUASI',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        const Positioned(
                                          right: 4,
                                          child: Icon(
                                            Icons.arrow_right_sharp,
                                            size: 24,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
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
    );
  }
}
