import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../services/api_service.dart';
import 'gereja_kelompok_list_screen.dart';

class KelompokScreen extends StatefulWidget {
  const KelompokScreen({super.key});

  @override
  State<KelompokScreen> createState() => _KelompokScreenState();
}

class _KelompokScreenState extends State<KelompokScreen> {
  String? currentEmail;
  List<dynamic> anggotaKelompok = [];
  String? namaKelompok;
  dynamic selectedUser;
  String selectedTab = 'komitmen';
  List<bool> isSelected = [false, true];
  final List<String> opsi = ['Gereja', 'Kelompok'];

  @override
  void initState() {
    super.initState();
    // _fetchMyGroup();
    _loadUserData();
  }

  // Future<void> _fetchMyGroup() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final email = prefs.getString('email');
  //   if (email == null) return;

  //   try {
  //     final response = await ApiService.getMyGroupMembers(context, email);
  //     setState(() {
  //       namaKelompok = response['nama_kelompok'];
  //       anggotaKelompok = response['anggota'];
  //       selectedUser = response['anggota'].firstWhere(
  //         (u) => u['email'] == email,
  //         orElse: () => null,
  //       );
  //     });
  //   } catch (e) {
  //     print('Gagal mengambil data kelompok: $e');
  //   }
  // }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentEmail = prefs.getString('email');
    });
  }

  IconData getRoleIcon(String role) {
    switch (role) {
      case 'Pembina':
        return Icons.church;
      case 'Panitia':
        return Icons.admin_panel_settings;
      case 'Pembimbing Kelompok':
        return Icons.boy;
      case 'Peserta':
        return Icons.badge;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          namaKelompok ?? 'Nama Kelompok',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          Flexible(
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(32),
              borderWidth: 1,
              borderColor: Colors.white54,
              selectedBorderColor: Colors.white,
              selectedColor: Colors.black,
              fillColor: Colors.white70,
              color: Colors.white,
              constraints: const BoxConstraints(minHeight: 40, minWidth: 90),
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
                          (context) => GerejaKelompokListScreen(type: 'Gereja'),
                    ),
                  );
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              GerejaKelompokListScreen(type: 'Kelompok'),
                    ),
                  );
                }
              },
              children: opsi.map((label) => Text(label)).toList(),
            ),
          ),
        ],
      ),

      body:
          anggotaKelompok.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Image.asset(
                    'assets/images/background_member2.png',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
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
                                  'Kelompok',
                                  style: TextStyle(
                                    fontSize: 36,
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
                              itemCount: anggotaKelompok.length,
                              itemBuilder: (context, index) {
                                final user = anggotaKelompok[index];
                                final isCurrentUser =
                                    user['email'] == currentEmail;
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
                                      elevation: isSelected ? 4 : 1,
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
                                                  getRoleIcon(user['roles']),
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
                                                    user['username'] ?? '',
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
                                                    Flexible(
                                                      child: Text(
                                                        user['roles'] ?? '',
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
                                                    Flexible(
                                                      child: Text(
                                                        user['gereja'] ?? '',
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
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Label ANDA (kanan atas)
                                          if (isCurrentUser)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                width: 40,
                                                height: 20,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.accent,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'ANDA',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
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
                          Expanded(
                            child: Column(
                              children: [
                                // Tombol Komitmen & Evaluasi (tidak ikut scroll)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap:
                                            () => setState(
                                              () => selectedTab = 'komitmen',
                                            ),
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color:
                                                selectedTab == 'komitmen'
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              32,
                                            ),
                                            border:
                                                selectedTab == 'komitmen'
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
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                child: Icon(
                                                  Icons.arrow_right_sharp,
                                                  size: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap:
                                            () => setState(
                                              () => selectedTab = 'evaluasi',
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color:
                                                selectedTab == 'evaluasi'
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              32,
                                            ),
                                            border:
                                                selectedTab == 'evaluasi'
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
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                child: Icon(
                                                  Icons.arrow_right_sharp,
                                                  size: 32,
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
