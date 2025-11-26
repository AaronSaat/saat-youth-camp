import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:shimmer/shimmer.dart';
import 'package:syc/screens/list_komitmen_screen.dart';
import 'package:syc/screens/scan_qr_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/utils/global_variables.dart';
import 'package:syc/widgets/custom_snackbar.dart';
import '../services/api_service.dart';
import '../widgets/custom_not_found.dart';
import 'bible_reading_list_screen.dart';
import 'list_evaluasi_screen.dart';
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

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // control whether the full info card is shown or shrunk
  bool _showInfoCard = true;

  @override
  void initState() {
    print('[SCREEN] AnggotaKelompokScreen initState');
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
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _toggleInfoCardView() {
    if (!mounted) return;
    setState(() {
      _showInfoCard = !_showInfoCard;
    });
  }

  Future<void> loadUserData() async {
    final token = await secureStorage.read(key: 'token');
    final email = await secureStorage.read(key: 'email');
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      // 'token',
      // 'email',
      'role',
      'gereja_id',
      'gereja_nama',
      'kelompok_id',
      'kelompok_nama',
    ];
    final Map<String, String> userData = {};
    for (final key in keys) {
      userData[key] = prefs.getString(key) ?? '';
    }
    userData['token'] = token ?? '';
    userData['email'] = email ?? '';
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
        if (!mounted) return;
        setState(() {
          nama = decoded['nama_kelompok'];
          anggota = decoded['data_anggota_kelompok'];
        });
        print('[PREF_API] Anggota Kelompok (from shared pref): $anggota');
        return;
      }
    }

    final response = await ApiService().getAnggotaKelompok(context, kelompokId);
    await prefs.setString(anggotaKey, jsonEncode(response));
    if (!mounted) return;
    setState(() {
      nama = response['nama_kelompok'];
      anggota = response['data_anggota_kelompok'];
    });
    print('[PREF_API] Anggota Kelompok (from API): $anggota');

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:
              Navigator.canPop(context)
                  ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: AppColors.primary,
                    onPressed: () => Navigator.of(context).maybePop(),
                  )
                  : null,
        ),
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
                          : (_showInfoCard
                              ? AnggotaKelompokInfoCard()
                              : AnggotaKelompokStatsCard()),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton:
          (_dataUser['role']?.toLowerCase() == 'pembimbing kelompok' ||
                      _dataUser['role']?.toLowerCase() == 'panitia') &&
                  widget.id != '41'
              ? Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FloatingActionButton(
                      heroTag: 'toggle_info_card',
                      backgroundColor: AppColors.floating_button,
                      onPressed: _toggleInfoCardView,
                      child: Icon(
                        _showInfoCard ? Icons.view_list : Icons.info,
                        color: AppColors.brown1,
                      ),
                    ),
                  ],
                ),
              )
              : null,
    );
  }
}

class AnggotaKelompokInfoCard extends StatelessWidget {
  const AnggotaKelompokInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state =
        context.findAncestorStateOfType<_AnggotaKelompokScreenState>();
    if (state == null) return const SizedBox.shrink();

    final nama = state.nama;
    final anggota = state.anggota;
    final role = (state._dataUser['role'] ?? '-').toString().toLowerCase();
    final isLoading = state._isLoading;

    return Column(
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
            final user = anggota[index] as Map<String, dynamic>;
            final userRole = (user['role'] ?? '').toString().toLowerCase();
            final kelengkapan = user['kelengkapan'] ?? 0;

            Widget avatarWidget() {
              if (isLoading) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                );
              }

              final path = user['avatar_local_path']?.toString() ?? '';
              if (path.isNotEmpty && File(path).existsSync()) {
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(File(path)),
                  backgroundColor: Colors.grey[200],
                );
              }

              return CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: SvgPicture.asset(
                    'assets/icons/profile.svg',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }

            return Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Card(
                      elevation: 0,
                      color: AppColors.primary,
                      margin: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SizedBox(
                        height:
                            userRole.contains('pembimbing')
                                ? 230
                                : userRole.contains('anggota') &&
                                    role.contains('peserta')
                                ? 280
                                : userRole.contains('anggota') &&
                                    (role.contains('pembimbing kelompok') ||
                                        role.contains('panitia')) &&
                                    state.widget.id == '41' &&
                                    user['id'] == null &&
                                    kelengkapan == 0
                                ? 310
                                : userRole.contains('anggota') &&
                                    (role.contains('pembimbing kelompok') ||
                                        role.contains('panitia')) &&
                                    state.widget.id != '41' &&
                                    user['id'] == null &&
                                    kelengkapan == 0
                                ? 310
                                : userRole.contains('anggota') &&
                                    (role.contains('pembimbing kelompok') ||
                                        role.contains('panitia')) &&
                                    state.widget.id == '41' &&
                                    user['id'] != null &&
                                    kelengkapan == 0
                                ? 300
                                : userRole.contains('anggota') &&
                                    (role.contains('pembimbing kelompok') ||
                                        role.contains('panitia')) &&
                                    state.widget.id != '41' &&
                                    user['id'] != null &&
                                    kelengkapan == 0
                                ? 350
                                : userRole.contains('anggota') &&
                                    (role.contains('pembimbing kelompok') ||
                                        role.contains('panitia')) &&
                                    state.widget.id == '41' &&
                                    user['id'] == null &&
                                    kelengkapan == 1
                                ? 260
                                : userRole.contains('anggota') &&
                                    (role.contains('pembimbing kelompok') ||
                                        role.contains('panitia')) &&
                                    state.widget.id != '41' &&
                                    user['id'] == null &&
                                    kelengkapan == 1
                                ? 275
                                : userRole.contains('anggota') &&
                                    (role.contains('pembimbing kelompok') ||
                                        role.contains('panitia')) &&
                                    state.widget.id == '41' &&
                                    user['id'] != null &&
                                    kelengkapan == 1
                                ? 290
                                : userRole.contains('anggota') &&
                                    (role.contains('pembimbing kelompok') ||
                                        role.contains('panitia')) &&
                                    state.widget.id != '41' &&
                                    user['id'] != null &&
                                    kelengkapan == 1
                                ? 300
                                : userRole.contains('anggota') &&
                                    role.contains('pembina')
                                ? 280
                                : 325,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 48,
                            bottom: 24,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: avatarWidget(),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      user['nama'] ?? '-',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize:
                                            (user['nama'] != null &&
                                                    user['nama']
                                                            .toString()
                                                            .length >
                                                        25)
                                                ? 18
                                                : 24,
                                        color:
                                            user['id'] == null
                                                ? AppColors.accent
                                                : Colors.white,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (userRole == 'pembimbing')
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.bed,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${user['kamar'] ?? 'Tidak ada kamar'}",
                                        style: TextStyle(
                                          fontSize:
                                              (user['kamar'] != null &&
                                                      user['kamar']
                                                              .toString()
                                                              .length >
                                                          20)
                                                  ? 10
                                                  : 14,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              if (userRole != 'pembimbing')
                                Center(
                                  child: Column(
                                    children: [
                                      if ((user['gereja_nama'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.church,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 5),
                                            Flexible(
                                              child: Text(
                                                '${user['gereja_nama']}',
                                                style: TextStyle(
                                                  fontSize:
                                                      (user['gereja_nama'] !=
                                                                  null &&
                                                              user['gereja_nama']
                                                                      .toString()
                                                                      .length >
                                                                  40)
                                                          ? 12
                                                          : 14,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if ((user['umur'] ?? '')
                                              .toString()
                                              .isNotEmpty) ...[
                                            const Icon(
                                              Icons.cake,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${user['umur']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                          ],
                                          const Icon(
                                            Icons.bed,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "${user['kamar'] ?? 'Tidak ada kamar'}",
                                            style: TextStyle(
                                              fontSize:
                                                  (user['kamar'] != null &&
                                                          user['kamar']
                                                                  .toString()
                                                                  .length >
                                                              20)
                                                      ? 10
                                                      : 14,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if ((([
                                        'panitia',
                                        'pembimbing kelompok',
                                        'pembina',
                                      ].contains(role)) &&
                                      userRole != 'pembimbing') &&
                                  state.widget.id != '41' &&
                                  user['id'] != null)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (role.contains('panitia') ||
                                        role.contains('pembimbing kelompok'))
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          child: SizedBox(
                                            height: 35,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (c) =>
                                                            ListEvaluasiScreen(
                                                              userId:
                                                                  user['id'] ??
                                                                  '',
                                                            ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Evaluasi',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: SizedBox(
                                          height: 35,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (c) => ListKomitmenScreen(
                                                        userId:
                                                            user['id'] ?? '',
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Komitmen',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: SizedBox(
                                          height: 35,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (c) =>
                                                          BibleReadingListScreen(
                                                            userId:
                                                                user['id'] ??
                                                                '',
                                                          ),
                                                ),
                                              ).then((result) {
                                                if (result == 'reload')
                                                  state._initAll();
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Bacaan',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              if ((role.toLowerCase().contains('panitia') ||
                                      role.toLowerCase().contains(
                                        'pembimbing kelompok',
                                      )) &&
                                  userRole.toLowerCase().contains('anggota') &&
                                  user['kelengkapan'] == 0)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (userRole == 'anggota')
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          child: SizedBox(
                                            height: 35,
                                            child: GestureDetector(
                                              onTap: () {
                                                showCustomSnackBar(
                                                  context,
                                                  'Peserta / pembina belum melengkapi data Konfirmasi Datang / Pulang.',
                                                  duration: const Duration(
                                                    seconds: 3,
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.accent,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Belum Mengisi Jadwal',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ],
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
                    if (userRole == 'pembimbing' || userRole == 'pembina')
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: const Text(
                            'Pembimbing',
                            style: TextStyle(
                              color: AppColors.black1,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    if (userRole == 'anggota' && user['status_datang'] == "0")
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            if (role == 'pembimbing kelompok') {
                              //
                            } else {
                              showCustomSnackBar(
                                context,
                                'Konfirmasi dilakukan oleh salah satu pembimbing kelompok. Jika kamu double role, switch to Pembimbing Kelompok di halaman profile',
                                duration: const Duration(seconds: 3),
                              );
                            }
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: const Text(
                              'Belum konfirmasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (userRole == 'anggota' &&
                        user['status_datang'] == "1")
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: const Text(
                            'Sudah konfirmasi',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    if (user['id'] == null)
                      const Positioned(
                        top: 30,
                        left: 30,
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Belum buat akun',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ],
    );
  }
}

class AnggotaKelompokStatsCard extends StatelessWidget {
  const AnggotaKelompokStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state =
        context.findAncestorStateOfType<_AnggotaKelompokScreenState>();
    if (state == null) return const SizedBox.shrink();

    final nama = state.nama;
    final anggota = state.anggota;
    final role = (state._dataUser['role'] ?? '-').toString().toLowerCase();
    final isLoading = state._isLoading;

    return Column(
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
            final user = anggota[index] as Map<String, dynamic>;
            final userRole = (user['role'] ?? '').toString().toLowerCase();

            Widget avatarWidget() {
              if (isLoading) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                );
              }

              final path = user['avatar_local_path']?.toString() ?? '';
              if (path.isNotEmpty && File(path).existsSync()) {
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(File(path)),
                  backgroundColor: Colors.grey[200],
                );
              }

              return CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: SvgPicture.asset(
                    'assets/icons/profile.svg',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }

            return Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Card(
                      elevation: 0,
                      color: AppColors.primary,
                      margin: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SizedBox(
                        height:
                            userRole.contains('pembimbing')
                                ? 190
                                : userRole.contains('anggota') &&
                                    role.contains('peserta')
                                ? 250
                                : userRole.contains('anggota') &&
                                    (role.contains('pembimbing kelompok') ||
                                        role.contains('panitia'))
                                ? 250
                                : 260,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 48,
                            bottom: 16,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: avatarWidget(),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      user['nama'] ?? '-',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize:
                                            (user['nama'] != null &&
                                                    user['nama']
                                                            .toString()
                                                            .length >
                                                        25)
                                                ? 18
                                                : 24,
                                        color:
                                            user['id'] == null
                                                ? AppColors.accent
                                                : Colors.white,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                              if (userRole.contains('anggota'))
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 28,
                                                    child: LinearProgressIndicator(
                                                      value:
                                                          ((user['progress']?['eval_day_1'] ??
                                                                  0) /
                                                              (user['progress']?['total_eval_day_1'] ??
                                                                  1)),
                                                      minHeight: 28,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(
                                                            AppColors.secondary,
                                                          ),
                                                      backgroundColor:
                                                          Colors.white24,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Eval Hari-1: ${(user['progress']?['eval_day_1'] ?? 0)}/${(user['progress']?['total_eval_day_1'] ?? 0)}',
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
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 28,
                                                    child: LinearProgressIndicator(
                                                      value:
                                                          ((user['progress']?['eval_day_2'] ??
                                                                  0) /
                                                              (user['progress']?['total_eval_day_2'] ??
                                                                  1)),
                                                      minHeight: 28,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(
                                                            AppColors.secondary,
                                                          ),
                                                      backgroundColor:
                                                          Colors.white24,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Eval Hari-2: ${(user['progress']?['eval_day_2'] ?? 0)}/${(user['progress']?['total_eval_day_2'] ?? 0)}',
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
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 28,
                                                    child: LinearProgressIndicator(
                                                      value:
                                                          ((user['progress']?['eval_day_3'] ??
                                                                  0) /
                                                              (user['progress']?['total_eval_day_3'] ??
                                                                  1)),
                                                      minHeight: 28,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(
                                                            AppColors.secondary,
                                                          ),
                                                      backgroundColor:
                                                          Colors.white24,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Eval Hari-3: ${(user['progress']?['eval_day_3'] ?? 0)}/${(user['progress']?['total_eval_day_3'] ?? 0)}',
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
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 28,
                                                  child: LinearProgressIndicator(
                                                    value:
                                                        ((user['progress']?['eval_day_4'] ??
                                                                0) /
                                                            (user['progress']?['total_eval_day_4'] ??
                                                                1)),
                                                    minHeight: 28,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(AppColors.secondary),
                                                    backgroundColor:
                                                        Colors.white24,
                                                  ),
                                                ),
                                                Text(
                                                  'Eval Hari-4: ${(user['progress']?['eval_day_4'] ?? 0)}/${(user['progress']?['total_eval_day_4'] ?? 0)}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 28,
                                                  child: LinearProgressIndicator(
                                                    value:
                                                        ((user['progress']?['eval_all'] ??
                                                                0) /
                                                            (user['progress']?['total_eval_all'] ??
                                                                1)),
                                                    minHeight: 28,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(AppColors.secondary),
                                                    backgroundColor:
                                                        Colors.white24,
                                                  ),
                                                ),
                                                Text(
                                                  'Eval Semua: ${(user['progress']?['eval_all'] ?? 0)}/${(user['progress']?['total_eval_all'] ?? 0)}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 28,
                                                  child: LinearProgressIndicator(
                                                    value:
                                                        ((user['progress']?['komitmen_day'] ??
                                                                0) /
                                                            (user['progress']?['total_komitmen_day'] ??
                                                                1)),
                                                    minHeight: 28,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(AppColors.secondary),
                                                    backgroundColor:
                                                        Colors.white24,
                                                  ),
                                                ),
                                                Text(
                                                  'Komitmen: ${(user['progress']?['komitmen_day'] ?? 0)}/${(user['progress']?['total_komitmen_day'] ?? 0)}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (userRole == 'pembimbing' || userRole == 'pembina')
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: const Text(
                            'Pembimbing',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    if (userRole == 'anggota' && user['status_datang'] == "0")
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            showCustomSnackBar(
                              context,
                              'Konfirmasi dilakukan oleh salah satu pembimbing kelompok. Jika kamu double role, switch to Pembimbing Kelompok di halaman profile',
                              duration: const Duration(seconds: 3),
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: const Text(
                              'Belum konfirmasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (userRole == 'anggota' &&
                        user['status_datang'] == "1")
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: const Text(
                            'Sudah konfirmasi',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    if (user['id'] == null)
                      const Positioned(
                        top: 30,
                        left: 30,
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Belum buat akun',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ],
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
