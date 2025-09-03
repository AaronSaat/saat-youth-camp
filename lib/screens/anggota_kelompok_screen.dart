import 'dart:convert'; // Tambahkan jika belum ada
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:shimmer/shimmer.dart';
import 'package:syc/screens/konfirmasi_registrasi_ulang_screen.dart';
import 'package:syc/screens/list_komitmen_screen.dart';
import 'package:syc/screens/scan_qr_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/utils/global_variables.dart';
import '../services/api_service.dart';
import '../widgets/custom_not_found.dart';
import '../widgets/custom_snackbar.dart';
import 'bible_reading_list_screen.dart';
import 'list_evaluasi_screen.dart';
import 'list_gereja_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class AnggotaKelompokScreen extends StatefulWidget {
  final String? id;
  const AnggotaKelompokScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<AnggotaKelompokScreen> createState() => _AnggotaKelompokScreenState();
}

// [IMPORTANT PLEASE READ]
// Ini saya pisahkan untuk behaviour back sekali dan back dua kali untuk keluar aplikasi
// Harus dibedakan karena kalo tidak, saat panitia liat anggota kelompok,
// tidak bisa back ke halaman sebelumnya, malah keluar snackbar dan keluar aplikasi
class _AnggotaKelompokScreenState extends State<AnggotaKelompokScreen> {
  List<dynamic> anggota = [];
  String? nama;
  dynamic selectedUser;
  bool _isLoading = true;
  Map<String, String> _dataUser = {};

  DateTime? _lastBackPressed;

  @override
  void initState() {
    print('[SCREEN] AnggotaKelompokScreen initState');
    _lastBackPressed = null;
    super.initState();
    _initAll();
  }

  Future<void> _initAll({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    print('Memuat anggota kelompok dengan ID: ${widget.id}');
    try {
      await loadAnggotaKelompok(widget.id, forceRefresh: forceRefresh);
      await loadUserData();
    } catch (e) {}
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

  Future<void> loadAnggotaKelompok(
    kelompokId, {
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final anggotaKey = 'anggota_kelompok_$kelompokId';

    if (!forceRefresh) {
      final cachedAnggota = prefs.getString(anggotaKey);
      if (cachedAnggota != null) {
        final decoded = jsonDecode(cachedAnggota);
        setState(() {
          nama = decoded['nama_kelompok'];
          anggota = decoded['data_anggota_kelompok'];
        });
        print('[PREF_API] Anggota Kelompok (from shared pref): $anggota');
        return;
      }
    }

    try {
      final response = await ApiService.getAnggotaKelompok(context, kelompokId);
      await prefs.setString(anggotaKey, jsonEncode(response));
      setState(() {
        nama = response['nama_kelompok'];
        anggota = response['data_anggota_kelompok'];
      });
      print('[PREF_API] Anggota Kelompok (from API): $anggota');
    } catch (e) {
      setState(() {});
      print('Gagal mengambil data kelompok: $e');
    }

    // load avatar dan download
    for (var user in anggota) {
      user['avatar_local_path'] = await loadAnggotaAvatarById(
        user['id'].toString(),
        user['avatar_url'],
        forceRefresh: forceRefresh,
      );
    }

    await prefs.setString(
      anggotaKey,
      jsonEncode({'nama_kelompok': nama, 'data_anggota_kelompok': anggota}),
    );
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

  Future<String> loadAnggotaAvatarById(
    String userId,
    String? avatarUrl, {
    bool forceRefresh = false,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/avatar_$userId.jpg';
    final file = File(filePath);

    if (forceRefresh || !file.existsSync()) {
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        String fullAvatarUrl = avatarUrl;
        if (!avatarUrl.startsWith('http')) {
          fullAvatarUrl = '${GlobalVariables.serverUrl}$avatarUrl';
        }
        try {
          final response = await http.get(Uri.parse(fullAvatarUrl));
          if (response.statusCode == 200) {
            await file.writeAsBytes(response.bodyBytes);
            print(
              '[AVATAR] Download dan simpan avatar anggota $userId: $filePath',
            );
            return filePath;
          }
        } catch (e) {
          print('[AVATAR] Error download avatar anggota $userId: $e');
        }
      }
      print('[AVATAR] Gagal download avatar anggota $userId dari API');
      return '';
    } else {
      print('[AVATAR] Ambil avatar anggota $userId dari local: $filePath');
      return filePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    _lastBackPressed = null;
    final role = _dataUser['role'] ?? '-';
    final id = _dataUser['id'] ?? '';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            Navigator.canPop(context)
                ? BackButton(color: AppColors.primary)
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
              onRefresh: () => _initAll(forceRefresh: true),
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
                          : widget.id == "Null"
                          ? Center(
                            child: CustomNotFound(
                              text: "Kelompok tidak ditemukan",
                              textColor: AppColors.brown1,
                              imagePath: 'assets/images/data_not_found.png',
                              onBack: () => _initAll(forceRefresh: true),
                              backText: 'Reload Anggota',
                            ),
                          )
                          : anggota.isEmpty
                          ? Center(
                            child: CustomNotFound(
                              text: "Gagal memuat anggota kelompok :(",
                              textColor: AppColors.brown1,
                              imagePath: 'assets/images/data_not_found.png',
                              onBack: () => _initAll(forceRefresh: true),
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

                              const SizedBox(height: 16),

                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: anggota.length,
                                itemBuilder: (context, index) {
                                  final width =
                                      MediaQuery.of(context).size.width;
                                  final user = anggota[index];
                                  return Column(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          // Card
                                          Stack(
                                            children: [
                                              Card(
                                                elevation: 0,
                                                color: AppColors.brown1,
                                                margin: const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  top: 16,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: SizedBox(
                                                  height:
                                                      (user['role']
                                                                  ?.toString()
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    'pembimbing',
                                                                  ) ??
                                                              false)
                                                          ? 170
                                                          : (user['role']
                                                                  .toString()
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    'anggota',
                                                                  ) &&
                                                              (role
                                                                  .toString()
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    'peserta',
                                                                  )))
                                                          ? 250 //sebagai anggota dan role user peserta
                                                          : (user['role']
                                                                  .toString()
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    'anggota',
                                                                  ) &&
                                                              (role
                                                                      .toString()
                                                                      .toLowerCase()
                                                                      .contains(
                                                                        'pembimbing kelompok',
                                                                      ) ||
                                                                  role
                                                                      .toString()
                                                                      .toLowerCase()
                                                                      .contains(
                                                                        'panitia',
                                                                      ))) //sebagai anggota dan role user pembimbing kelompok atau panitia
                                                          ? 325
                                                          : 260,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 16,
                                                          right: 16,
                                                          top: 48,
                                                          bottom: 16,
                                                        ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Centered text at the top
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [ 
                                                            // Avatar
                                                            CircleAvatar(
                                                              radius: 44,
                                                              backgroundImage:
                                                                  user['avatar_url'] !=
                                                                          null
                                                                      ? NetworkImage(
                                                                        '${GlobalVariables.serverUrl}${user['avatar_url']}',
                                                                      )
                                                                      : AssetImage(() {
                                                                            if (user['role'].toString().toLowerCase().contains(
                                                                              'pembina',
                                                                            )) {
                                                                              return 'assets/mockups/pembina.jpg';
                                                                            } else if (user['role'].toString().toLowerCase().contains(
                                                                              'anggota',
                                                                            )) {
                                                                              return 'assets/mockups/peserta.jpg';
                                                                            } else if (user['role'].toString().toLowerCase().contains(
                                                                              'pembimbing',
                                                                            )) {
                                                                              return 'assets/mockups/pembimbing.jpg';
                                                                            } else {
                                                                              return 'assets/mockups/unknown.jpg';
                                                                            }
                                                                          }())
                                                                          as ImageProvider,
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            // Nama
                                                            Flexible(
                                                              child: Text(
                                                                user['nama'] ??
                                                                    '-',
                                                                style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize: 24,
                                                                  color:
                                                                      AppColors
                                                                          .secondary,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // Three left-aligned texts in the middle
                                                        if ((user['role'] ?? '')
                                                                .toString()
                                                                .toLowerCase() !=
                                                            'pembimbing')
                                                          Center(
                                                            child: Column(
                                                              children: [
                                                                if ((user['role'] ??
                                                                        '')
                                                                    .toString()
                                                                    .isNotEmpty)
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .church,
                                                                        size:
                                                                            18,
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Flexible(
                                                                        child: Text(
                                                                          '${user['gereja_nama']}',
                                                                          style: const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                if ((user['provinsi'] ??
                                                                        '')
                                                                    .toString()
                                                                    .isNotEmpty)
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .location_on,
                                                                        size:
                                                                            18,
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            6,
                                                                      ),
                                                                      Text(
                                                                        '${user['provinsi']}',
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                if ((user['umur'] ??
                                                                        '')
                                                                    .toString()
                                                                    .isNotEmpty)
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .cake,
                                                                        size:
                                                                            18,
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            6,
                                                                      ),
                                                                      Text(
                                                                        '${user['umur']}',
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                if ((user['kamar'] ??
                                                                        '')
                                                                    .toString()
                                                                    .isNotEmpty)
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .bed,
                                                                        size:
                                                                            18,
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            6,
                                                                      ),
                                                                      Text(
                                                                        '${user['kamar']}',
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ],
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        // Three buttons in a row at the bottom, hidden if role == 'peserta'
                                                        // Tampilkan tombol jika role login adalah panitia, pembimbing, atau pembina
                                                        // DAN user yang ditampilkan BUKAN pembimbing
                                                        if (([
                                                              'panitia',
                                                              'pembimbing kelompok',
                                                              'pembina',
                                                            ].contains(
                                                              (role ?? '')
                                                                  .toLowerCase(),
                                                            )) &&
                                                            (user['role']
                                                                    ?.toString()
                                                                    .toLowerCase() !=
                                                                'pembimbing'))
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              if (role
                                                                      .toString()
                                                                      .toLowerCase()
                                                                      .contains(
                                                                        'panitia',
                                                                      ) ||
                                                                  role
                                                                      .toString()
                                                                      .toLowerCase()
                                                                      .contains(
                                                                        'pembimbing kelompok',
                                                                      ))
                                                                Expanded(
                                                                  child: Padding(
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              2,
                                                                        ),
                                                                    child: SizedBox(
                                                                      height:
                                                                          35, // Set your desired button height here
                                                                      child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor:
                                                                              Colors.white,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              16,
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
                                                                                  ) => ListEvaluasiScreen(
                                                                                    userId:
                                                                                        user['id'] ??
                                                                                        '',
                                                                                  ),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: const Text(
                                                                          'Evaluasi',
                                                                          style: TextStyle(
                                                                            color:
                                                                                AppColors.primary,
                                                                            fontSize:
                                                                                13,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            2,
                                                                      ),
                                                                  child: SizedBox(
                                                                    height:
                                                                        35, // Set your desired button height here
                                                                    child: ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                            16,
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
                                                                                ) => ListKomitmenScreen(
                                                                                  userId:
                                                                                      user['id'] ??
                                                                                      '',
                                                                                ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      child: Text(
                                                                        'Komitmen',
                                                                        style: TextStyle(
                                                                          color:
                                                                              AppColors.primary,
                                                                          fontSize:
                                                                              10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            2,
                                                                      ),
                                                                  child: SizedBox(
                                                                    height:
                                                                        35, // Set your desired button height here
                                                                    child: ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                            16,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      onPressed: () async {
                                                                        Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder:
                                                                                (
                                                                                  context,
                                                                                ) => BibleReadingListScreen(
                                                                                  userId:
                                                                                      user['id'],
                                                                                ),
                                                                          ),
                                                                        ).then((
                                                                          result,
                                                                        ) {
                                                                          if (result ==
                                                                              'reload') {
                                                                            _initAll(); // reload dashboard
                                                                          }
                                                                        });
                                                                      },
                                                                      child: Text(
                                                                        'Bacaan',
                                                                        style: TextStyle(
                                                                          color:
                                                                              AppColors.primary,
                                                                          fontSize:
                                                                              13,
                                                                        ),
                                                                      ),
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
                                              if ((user['role'] ?? '')
                                                          .toString()
                                                          .toLowerCase() ==
                                                      'pembimbing' ||
                                                  (user['role'] ?? '')
                                                          .toString()
                                                          .toLowerCase() ==
                                                      'pembina')
                                                Positioned(
                                                  top: 16,
                                                  right: 16,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.secondary,
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
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 8,
                                                        ),
                                                    child: Text(
                                                      'Pembimbing',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              if ((user['role'] ?? '')
                                                          .toString()
                                                          .toLowerCase() ==
                                                      'anggota' &&
                                                  user['status_datang'] == "0")
                                                Positioned(
                                                  top: 16,
                                                  right: 16,
                                                  child: GestureDetector(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: AppColors.accent,
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
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 8,
                                                          ),
                                                      child: Text(
                                                        'Belum verifikasi',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              else if ((user['role'] ?? '')
                                                          .toString()
                                                          .toLowerCase() ==
                                                      'anggota' &&
                                                  user['status_datang'] == "1")
                                                Positioned(
                                                  top: 16,
                                                  right: 16,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: AppColors.green,
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
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 8,
                                                        ),
                                                    child: Text(
                                                      'Sudah verifikasi',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              if (user['id'] == null)
                                                Positioned(
                                                  top: 30,
                                                  left: 30,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .warning_amber_rounded,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Belum install app',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
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

      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton:
          _dataUser['role']?.toLowerCase() == 'pembimbing kelompok'
              ? Padding(
                padding: const EdgeInsets.only(bottom: 96.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FloatingActionButton(
                      backgroundColor: AppColors.brown1,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ScanQrScreen(
                                  namakelompok:
                                      _dataUser['kelompok_nama'] ?? '',
                                ),
                          ),
                        ).then((result) {
                          if (result == 'reload') {
                            _initAll(forceRefresh: true);
                          }
                        });
                      },
                      child: const Icon(Icons.qr_code, color: Colors.white),
                    ),
                  ],
                ),
              )
              : null,
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
