import 'dart:convert'; // Tambahkan jika belum ada
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:shimmer/shimmer.dart';
import 'package:syc/screens/list_komitmen_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_snackbar.dart' show showCustomSnackBar;
import '../services/api_service.dart';
import '../utils/global_variables.dart';
import '../widgets/custom_not_found.dart';
import 'bible_reading_list_screen.dart';
import 'list_evaluasi_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class AnggotaGroupMainScreen extends StatefulWidget {
  final String? id;
  const AnggotaGroupMainScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<AnggotaGroupMainScreen> createState() => _AnggotaGroupMainScreenState();
}

// [IMPORTANT PLEASE READ]
// Ini saya pisahkan untuk behaviour back sekali dan back dua kali untuk keluar aplikasi
// Harus dibedakan karena kalo tidak, saat panitia liat anggota kelompok,
// tidak bisa back ke halaman sebelumnya, malah keluar snackbar dan keluar aplikasi
class _AnggotaGroupMainScreenState extends State<AnggotaGroupMainScreen> {
  List<dynamic> anggota = [];
  String? nama;
  dynamic selectedUser;
  bool _isLoading = true;
  Map<String, String> _dataUser = {};

  DateTime? _lastBackPressed;

  @override
  void initState() {
    print('[SCREEN]AnggotaGroupMainScreen initState');
    _lastBackPressed = null;
    super.initState();
    _initAll();
  }

  Future<void> _initAll({bool forceRefresh = false}) async {
    try {
      await loadUserData();
      await loadAnggotaGereja(widget.id, forceRefresh: forceRefresh);
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

  Future<void> loadAnggotaGereja(groupId, {bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final anggotaKey = 'anggota_gereja_$groupId';

    if (!forceRefresh) {
      final cachedAnggota = prefs.getString(anggotaKey);
      if (cachedAnggota != null) {
        final decoded = jsonDecode(cachedAnggota);
        setState(() {
          nama = decoded['nama_gereja'];
          anggota = decoded['data_anggota_gereja'];
        });
        print('[PREF_API] Anggota Gereja (from shared pref): $anggota');
        return;
      }
    }

    try {
      final response = await ApiService.getAnggotaGroup(context, groupId);
      await prefs.setString(anggotaKey, jsonEncode(response));
      setState(() {
        nama = response['nama_gereja'];
        anggota = response['data_anggota_gereja'];
      });
      print('[PREF_API] Anggota Gereja (from API): $anggota');
    } catch (e) {
      setState(() {});
      print('Gagal mengambil data gereja: $e');
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
    if (role == "Pembina") {
      return 'assets/mockups/pembina.jpg';
    } else if (role == "Anggota") {
      return 'assets/mockups/peserta.jpg';
    } else {
      return 'assets/mockups/panitia.jpg';
    }
  }

  IconData getRoleIcon(String role) {
    if (role == "Pembina") {
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          final now = DateTime.now();
          if (_lastBackPressed == null ||
              now.difference(_lastBackPressed!) > Duration(seconds: 2)) {
            _lastBackPressed = now;
            showCustomSnackBar(
              context,
              "Tekan sekali lagi untuk keluar aplikasi",
              duration: const Duration(seconds: 5),
              showDismissButton: false,
              showAppIcon: true,
            );
          } else {
            // Keluar aplikasi
            Future.delayed(const Duration(milliseconds: 100), () {
              // ignore: use_build_context_synchronously
              SystemNavigator.pop();
            });
          }
        }
      },
      child: Scaffold(
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
                                text: "Kelompok pendaftaran tidak ditemukan",
                                textColor: AppColors.brown1,
                                imagePath: 'assets/images/data_not_found.png',
                                onBack: () => _initAll(forceRefresh: true),
                                backText: 'Reload Anggota',
                              ),
                            )
                            : anggota.isEmpty
                            ? Center(
                              child: CustomNotFound(
                                text:
                                    "Gagal memuat anggota group pendaftaran :(",
                                textColor: AppColors.brown1,
                                imagePath: 'assets/images/data_not_found.png',

                                onBack: () => _initAll(forceRefresh: true),
                                backText: 'Reload Anggota',
                              ),
                            )
                            : Column(
                              children: [
                                Text(
                                  'Group ${nama ?? ''}',
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
                                            // Card utama dengan margin atas untuk avatar
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Stack(
                                                children: [
                                                  Card(
                                                    elevation: 0,
                                                    color: AppColors.brown1,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 16,
                                                          right: 16,
                                                          top: 16,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    child: SizedBox(
                                                      height:
                                                          (user['role']
                                                                      ?.toString()
                                                                      .toLowerCase()
                                                                      .contains(
                                                                        'pembina',
                                                                      ) ??
                                                                  false)
                                                              ? 225
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
                                                                            'pembina',
                                                                          ) ||
                                                                      role
                                                                          .toString()
                                                                          .toLowerCase()
                                                                          .contains(
                                                                            'panitia',
                                                                          )) &&
                                                                  user['id'] ==
                                                                      null) //sebagai anggota dan role user pembimbing kelompok atau panitia atau pembina dan anggota belum install app
                                                              ? 300
                                                              : 300,
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                          left: 16,
                                                          right: 16,
                                                          top:
                                                              user['id'] ==
                                                                          null ||
                                                                      user['role'] ==
                                                                          "Pembina"
                                                                  ? 48
                                                                  : 16,
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
                                                            // Avatar dan Nama
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // Avatar
                                                                _isLoading
                                                                    ? Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            4,
                                                                          ),
                                                                      child: Container(
                                                                        width:
                                                                            100,
                                                                        height:
                                                                            100,
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.grey[300],
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                      ),
                                                                    )
                                                                    : (user['avatar_local_path'] !=
                                                                            null &&
                                                                        user['avatar_local_path']
                                                                            .toString()
                                                                            .isNotEmpty &&
                                                                        File(
                                                                          user['avatar_local_path'],
                                                                        ).existsSync())
                                                                    ? Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            4,
                                                                          ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                      child: CircleAvatar(
                                                                        key: ValueKey(
                                                                          user['avatar_local_path'],
                                                                        ),
                                                                        radius:
                                                                            50,
                                                                        backgroundImage: FileImage(
                                                                          File(
                                                                            user['avatar_local_path'],
                                                                          ),
                                                                        ),
                                                                        backgroundColor:
                                                                            Colors.grey[200],
                                                                      ),
                                                                    )
                                                                    : Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            4,
                                                                          ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                      child: CircleAvatar(
                                                                        radius:
                                                                            50,
                                                                        backgroundColor:
                                                                            Colors.grey[200],
                                                                        child: ClipOval(
                                                                          child: SvgPicture.asset(
                                                                            'assets/icons/profile.svg',
                                                                            width:
                                                                                90,
                                                                            height:
                                                                                90,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                const SizedBox(
                                                                  width: 12,
                                                                ),
                                                                // Nama
                                                                Flexible(
                                                                  child: Text(
                                                                    user['nama'] ??
                                                                        '-',
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      fontSize:
                                                                          (user['nama'] !=
                                                                                      null &&
                                                                                  user['nama'].toString().length >
                                                                                      25)
                                                                              ? 18
                                                                              : 24,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                    maxLines: 2,
                                                                    // textAlign:
                                                                    //     TextAlign
                                                                    //         .center,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            // Info kelompok, provinsi, umur, kamar
                                                            if ((user['role'] ??
                                                                        '')
                                                                    .toString()
                                                                    .toLowerCase() !=
                                                                'pembimbing')
                                                              Center(
                                                                child: Column(
                                                                  children: [
                                                                    if ((user['nama_kelompok'] ??
                                                                            '')
                                                                        .toString()
                                                                        .isNotEmpty)
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.person,
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
                                                                              '${user['nama_kelompok']}',
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    (user['nama_kelompok'] !=
                                                                                                null &&
                                                                                            user['nama_kelompok'].toString().length >
                                                                                                40)
                                                                                        ? 12
                                                                                        : 14,
                                                                                color:
                                                                                    Colors.white,
                                                                              ),
                                                                              textAlign:
                                                                                  TextAlign.center,
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
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.location_on,
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
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.cake,
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
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.bed,
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
                                                            // Tombol aksi
                                                            if (([
                                                                  'panitia',
                                                                  'pembimbing',
                                                                  'pembina',
                                                                ].contains(
                                                                  (role ?? '')
                                                                      .toLowerCase(),
                                                                )) &&
                                                                (user['role']
                                                                        ?.toString()
                                                                        .toLowerCase() !=
                                                                    'pembina'))
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
                                                                      ))
                                                                    Expanded(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              2,
                                                                        ),
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
                                                                  Expanded(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            2,
                                                                      ),
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
                                                                                15,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            2,
                                                                      ),
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
                                                                                        user['id'] ??
                                                                                        '',
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
                                                                ],
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Badge status di pojok kanan atas
                                                  if ((user['role'] ?? '')
                                                              .toString()
                                                              .toLowerCase() ==
                                                          'pembina' ||
                                                      (user['role'] ?? '')
                                                              .toString()
                                                              .toLowerCase() ==
                                                          'pembimbing')
                                                    Positioned(
                                                      top: 15,
                                                      right: 15,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color:
                                                              AppColors
                                                                  .secondary,
                                                          borderRadius:
                                                              const BorderRadius.only(
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
                                                          (user['role'] ?? '')
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            'Belum install app',
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 10,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
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
