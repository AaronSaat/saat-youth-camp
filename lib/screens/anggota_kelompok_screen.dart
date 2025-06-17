import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:shimmer/shimmer.dart';
import 'package:syc/utils/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/custom_not_found.dart';
import 'evaluasi_komitmen_list_screen.dart';
import 'list_gereja_screen.dart';

class AnggotaKelompokScreen extends StatefulWidget {
  final String? id;
  const AnggotaKelompokScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<AnggotaKelompokScreen> createState() => _AnggotaKelompokScreenState();
}

class _AnggotaKelompokScreenState extends State<AnggotaKelompokScreen> {
  List<dynamic> anggota = [];
  String? nama;
  dynamic selectedUser;
  bool _isLoading = true;
  Map<String, String> _dataUser = {};

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    try {
      await loadAnggotaKelompok(widget.id);
      await loadUserData();
    } catch (e) {
      // handle error jika perlu
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      'email',
      'role',
      'token',
      'gereja_id',
      'gereja_nama',
      'kelompok_id',
      'kelompok_nama',
    ];
    final Map<String, String> userData = {};
    for (final key in keys) {
      userData[key] = prefs.getString(key) ?? '';
    }
    if (!mounted) return;
    setState(() {
      _dataUser = userData;
    });
  }

  Future<void> loadAnggotaKelompok(kelompokId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.getAnggotaKelompok(context, kelompokId);
      setState(() {
        nama = response['nama_kelompok'];
        anggota = response['data_anggota_kelompok'];
      });
    } catch (e) {
      setState(() {});
      print('Gagal mengambil data kelompok: $e');
    }
  }

  String getRoleImage(String role) {
    if (role == "Pembimbing") {
      return 'assets/mockups/pembimbing.jpg';
    } else if (role == "Anggota") {
      return 'assets/mockups/peserta.jpg';
    } else {
      return 'assets/mockups/panitia.jpg';
    }
  }

  IconData getRoleIcon(String role) {
    if (role == "Pembimbing") {
      return Icons.church;
    } else if (role == "Anggota") {
      return Icons.person_2;
    } else {
      return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _dataUser['role'] ?? '-';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context) ? BackButton(color: AppColors.primary) : null,
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
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 96),
                  child:
                      _isLoading
                          ? buildAnggotaShimmer()
                          : anggota.isEmpty
                          ? Center(
                            child: CustomNotFound(
                              text: "Gagal memuat anggota kelompok :(",
                              textColor: AppColors.brown1,
                              imagePath: 'assets/images/data_not_found.png',
                              onBack: _initAll,
                              backText: 'Reload Anggota',
                            ),
                          )
                          : Column(
                            children: [
                              Text(
                                'Kelompok ${nama ?? ''}',
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
                                  final width = MediaQuery.of(context).size.width;
                                  final user = anggota[index];
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Card
                                      Container(
                                        margin: const EdgeInsets.only(top: 48), // space for the image
                                        child: Card(
                                          elevation: 0,
                                          color: Colors.grey[200],
                                          margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                          child: SizedBox(
                                            height: 250,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 16, right: 16, top: 64, bottom: 16),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Centered text at the top
                                                  Center(
                                                    child: Text(
                                                      user['nama'] ?? '-',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                        color: AppColors.primary,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Three left-aligned texts in the middle
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      if ((user['role'] ?? '').toString().isNotEmpty)
                                                        Text(
                                                          '${user['role']}',
                                                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                                                          textAlign: TextAlign.left,
                                                        ),
                                                      if ((user['provinsi'] ?? '').toString().isNotEmpty)
                                                        Text(
                                                          '${user['provinsi']}',
                                                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                                                          textAlign: TextAlign.left,
                                                        ),
                                                      if ((user['umur'] ?? '').toString().isNotEmpty)
                                                        Text(
                                                          '${user['umur']}',
                                                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                                                          textAlign: TextAlign.left,
                                                        ),
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                  // Three buttons in a row at the bottom, hidden if role == 'peserta'
                                                  if ((role ?? '').toString().toLowerCase() != 'peserta')
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: AppColors.primary,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(16),
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                // TODO: Implement action 1
                                                              },
                                                              child: const Text(
                                                                'Evaluasi',
                                                                style: TextStyle(color: Colors.white, fontSize: 10),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: AppColors.primary,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(16),
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                // TODO: Implement action 2
                                                              },
                                                              child: const Text(
                                                                'Komitmen',
                                                                style: TextStyle(color: Colors.white, fontSize: 8),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: AppColors.primary,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(16),
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                // TODO: Implement action 3
                                                              },
                                                              child: const Text(
                                                                'Bacaan',
                                                                style: TextStyle(color: Colors.white, fontSize: 10),
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
                                        ),
                                      ),
                                      // Positioned Circle Avatar
                                      Positioned(
                                        top: 10,
                                        left: width / 2 - 56, // center horizontally relative to card
                                        child: CircleAvatar(
                                          radius: 56,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 52,
                                            backgroundImage: AssetImage(getRoleImage(user['role'] ?? '')),
                                          ),
                                        ),
                                      ),
                                    ],
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
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
