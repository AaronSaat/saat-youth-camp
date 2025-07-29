import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/screens/catatan_harian_screen.dart';
import 'package:syc/screens/kontak_panitia_screen.dart';
import 'package:syc/screens/list_komitmen_screen.dart';
import 'package:syc/screens/main_screen.dart' show MainScreen;
import 'package:syc/widgets/custom_alert_dialog.dart';
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../utils/global_variables.dart';
import '../widgets/custom_count_up.dart';
import '../widgets/custom_circular_progress';
import '../widgets/custom_not_found.dart';
import '../widgets/custom_pin_textfield.dart';
import '../widgets/custom_snackbar.dart';
import 'bible_reading_list_screen.dart';
import 'daftar_acara_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'package:syc/utils/app_colors.dart';

import 'detail_acara_screen.dart';
import 'bible_reading_more_screen.dart';
import 'list_evaluasi_screen.dart';
import 'login_screen.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isLoading_userdata = true;
  bool _isLoading_progreskomitmen = true;
  bool _isLoading_progresevaluasi = true;
  bool _isLoading_avatar = true;
  DateTime? _lastBackPressed;

  // [DEVELOPMENT NOTES] nanti hapus
  // untuk testing, set di global variables.dart
  late DateTime _today;
  late TimeOfDay _timeOfDay;

  // loading progres komitmen untuk panitia
  bool _isLoading_progreskomitmenday1_panitia = true;
  bool _isLoading_progreskomitmenday2_panitia = true;
  bool _isLoading_progreskomitmenday3_panitia = true;

  Map<String, String> _dataUser = {};
  List<Map<String, dynamic>> _dataBrm = [];
  String avatar = '';

  // progress
  Map<String, String> _komitmenDoneMap = {};
  int _komitmenTotal = 0;
  Map<String, String> _evaluasiDoneMap = {};
  int _evaluasiTotal = 0;

  // progress untuk panitia
  Map<String, String> _komitmenDoneDay1MapPanitia = {};
  Map<String, String> _komitmenDoneDay2MapPanitia = {};
  Map<String, String> _komitmenDoneDay3MapPanitia = {};
  Map<String, String> _countUserMapPanitia = {};

  @override
  void initState() {
    _lastBackPressed = null;
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
      _isLoading_userdata = true;
      _isLoading_avatar = true;

      // loading peserta
      _isLoading_progreskomitmen = true;
      _isLoading_progresevaluasi = true;

      // loading progres komitmen untuk panitia
      _isLoading_progreskomitmenday1_panitia = true;
      _isLoading_progreskomitmenday2_panitia = true;
      _isLoading_progreskomitmenday3_panitia = true;
    });
    try {
      await loadUserData();
      await loadAvatarById();

      if (_dataUser['role']!.toLowerCase().contains('peserta')) {
        await loadProgresEvaluasiAnggota();
        await loadProgresKomitmenAnggota();
      }

      if (_dataUser['role']!.toLowerCase().contains('panitia')) {
        await loadCountUser();
        await loadKomitmenDoneDay1Panitia();
        await loadKomitmenDoneDay2Panitia();
        await loadKomitmenDoneDay3Panitia();
      }
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isLoading_userdata = false;
      _isLoading_avatar = false;

      // loading peserta
      _isLoading_progreskomitmen = false;
      _isLoading_progresevaluasi = false;

      // loading progres komitmen untuk panitia
      _isLoading_progreskomitmenday1_panitia = false;
      _isLoading_progreskomitmenday2_panitia = false;
      _isLoading_progreskomitmenday3_panitia = false;
    });
  }

  Future<void> loadUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading_userdata = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      'nama',
      'divisi',
      'email',
      'group_id',
      'role',
      'count_roles',
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
      _isLoading_userdata = false;
    });
  }

  Future<void> loadProgresKomitmenAnggota() async {
    if (!mounted) return;
    setState(() {
      _isLoading_progreskomitmen = true;
    });
    try {
      final userId = _dataUser['id'] ?? '';
      final komitmenList = await ApiService.getCountKomitmenAnsweredByPeserta(
        context,
        userId,
      );
      final komitmen = await ApiService.getKomitmen(context);

      if (!mounted) return;
      setState(() {
        _komitmenDoneMap = komitmenList.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
        _komitmenTotal = komitmen.length;

        print('Komitmen Done Map: $_komitmenDoneMap');
        print('Total Komitmen: ${_komitmenTotal} komitmen');
        _isLoading_progreskomitmen = false;
      });
    } catch (e) {
      if (!mounted) return;
    }
  }

  Future<void> loadProgresEvaluasiAnggota() async {
    if (!mounted) return;
    setState(() {
      _isLoading_progresevaluasi = true;
    });
    try {
      final userId = _dataUser['id'] ?? '';
      final evaluasiList = await ApiService.getCountEvaluasiAnsweredByPeserta(
        context,
        userId,
      );
      final acaraList = await ApiService.getAcara(context);

      if (!mounted) return;
      setState(() {
        _evaluasiDoneMap = evaluasiList.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
        _evaluasiTotal = acaraList.length;

        print('Evaluasi Done Map: $_evaluasiDoneMap');
        print('Total Eval: ${_evaluasiTotal} evaluasi');
        _isLoading_progresevaluasi = false;
      });
    } catch (e) {
      if (!mounted) return;
    }
  }

  Future<void> loadAvatarById() async {
    if (!mounted) return;
    setState(() {
      _isLoading_avatar = true;
    });
    final userId = _dataUser['id'].toString() ?? '';
    try {
      final _avatar = await ApiService.getAvatarById(context, userId);
      if (!mounted) return;
      setState(() {
        avatar = _avatar;
        print('Avatar URL: $avatar');
        _isLoading_avatar = false;
      });
    } catch (e) {}
  }

  Future<void> loadCountUser() async {
    if (!mounted) return;
    setState(() {});
    try {
      final _countUser = await ApiService.getCountUser(context);
      if (!mounted) return;
      setState(() {
        _countUserMapPanitia = _countUser.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
        print('Count User Map: $_countUserMapPanitia');
      });
    } catch (e) {}
  }

  //aku load satu satu , mau sekaligus juga bisa sih
  Future<void> loadKomitmenDoneDay1Panitia() async {
    if (!mounted) return;
    setState(() {
      _isLoading_progreskomitmenday1_panitia = true;
    });
    try {
      final _countKomitmen = await ApiService.getCountKomitmenAnsweredByDay(
        context,
        "1",
      );
      if (!mounted) return;
      setState(() {
        _komitmenDoneDay1MapPanitia = _countKomitmen.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
        print('Komitmen Done Day 1 Map: $_komitmenDoneDay1MapPanitia');
        _isLoading_progreskomitmenday1_panitia = false;
      });
    } catch (e) {}
  }

  Future<void> loadKomitmenDoneDay2Panitia() async {
    if (!mounted) return;
    setState(() {
      _isLoading_progreskomitmenday2_panitia = true;
    });
    try {
      final _countKomitmen = await ApiService.getCountKomitmenAnsweredByDay(
        context,
        "2",
      );
      if (!mounted) return;
      setState(() {
        _komitmenDoneDay2MapPanitia = _countKomitmen.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
        print('Komitmen Done Day 2 Map: $_komitmenDoneDay2MapPanitia');
        _isLoading_progreskomitmenday2_panitia = false;
      });
    } catch (e) {}
  }

  Future<void> loadKomitmenDoneDay3Panitia() async {
    if (!mounted) return;
    setState(() {
      _isLoading_progreskomitmenday3_panitia = true;
    });
    try {
      final _countKomitmen = await ApiService.getCountKomitmenAnsweredByDay(
        context,
        "3",
      );
      if (!mounted) return;
      setState(() {
        _komitmenDoneDay3MapPanitia = _countKomitmen.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
        print('Komitmen Done Day 3Map: $_komitmenDoneDay3MapPanitia');
        _isLoading_progreskomitmenday3_panitia = false;
      });
    } catch (e) {}
  }

  Future<void> logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    //reset
    setState(() {
      GlobalVariables.currentIndex = 0;
    });
  }

  Future<void> switchRole(BuildContext context, String newRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', newRole);
    setState(() {}); // trigger rebuild
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _lastBackPressed = null;
    final id = _dataUser['id'] ?? '';
    final gereja = _dataUser['gereja_nama'] ?? '';
    final kelompok = _dataUser['kelompok_nama'] ?? '';
    final role = _dataUser['role'] ?? '';
    final name = _dataUser['nama'] ?? '';
    final divisi = _dataUser['divisi'] ?? '';
    final count_roles = _dataUser['count_roles'] ?? '0';
    print('role: $role');

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
        body: Stack(
          children: [
            Positioned(
              child: Image.asset(
                'assets/images/background_profile.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.fill,
              ),
            ),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () => initAll(),
                color: AppColors.brown1,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 24.0,
                      bottom: 96,
                      left: 24.0,
                      right: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            // Align(
                            //   alignment: Alignment.topRight,
                            //   child: Image.asset(
                            //     'assets/buttons/hamburger_white.png',
                            //     height: 48,
                            //     width: 48,
                            //   ),
                            // ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.3,
                                      height:
                                          MediaQuery.of(context).size.width *
                                          0.3,
                                      child:
                                          _isLoading_avatar
                                              ? Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: CircleAvatar(
                                                  radius: 50,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                ),
                                              )
                                              : CircleAvatar(
                                                radius: 50,
                                                backgroundImage:
                                                    !avatar
                                                                .toLowerCase()
                                                                .contains(
                                                                  'null',
                                                                ) &&
                                                            avatar != ''
                                                        ? NetworkImage(
                                                          '${GlobalVariables.serverUrl}$avatar',
                                                        )
                                                        : AssetImage(() {
                                                              switch (role) {
                                                                case 'Pembina':
                                                                  return 'assets/mockups/pembina.jpg';
                                                                case 'Peserta':
                                                                  return 'assets/mockups/peserta.jpg';
                                                                case 'Pembimbing Kelompok':
                                                                  return 'assets/mockups/pembimbing.jpg';
                                                                case 'Panitia':
                                                                  return 'assets/mockups/panitia.jpg';
                                                                default:
                                                                  return 'assets/mockups/unknown.jpg';
                                                              }
                                                            }())
                                                            as ImageProvider,
                                              ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ProfileEditScreen(),
                                            ),
                                          ).then((result) {
                                            if (result == 'reload') {
                                              initAll();
                                            }
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.grey4,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        // role != 'Panitia' ? name : 'Panitia',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Card(
                                            color: AppColors.secondary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.work,
                                                    size: 12,
                                                    color: AppColors.primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    role.replaceAll(
                                                      ' Kelompok',
                                                      '',
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (kelompok.isNotEmpty &&
                                              kelompok != 'Null')
                                            Card(
                                              color: AppColors.secondary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.group,
                                                      size: 12,
                                                      color: AppColors.primary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      kelompok,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (divisi.isNotEmpty && divisi != 'Null')
                                        Card(
                                          color: AppColors.secondary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.business,
                                                  size: 16,
                                                  color: AppColors.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    divisi,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (gereja.isNotEmpty && gereja != 'Null')
                                        Card(
                                          color: AppColors.secondary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.church,
                                                  size: 16,
                                                  color: AppColors.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    gereja,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // CustomPinTextfield(),
                            // progress evaluasi dan komitmen
                            if (role.toLowerCase().contains('peserta'))
                              (_isLoading_progresevaluasi &&
                                      _isLoading_progreskomitmen)
                                  ? buildAcaraShimmer()
                                  //     : _acaraList.isEmpty
                                  //     ? Center(
                                  //       child: CustomNotFound(
                                  //         text: "Gagal memuat daftar materi :(",
                                  //         textColor: AppColors.brown1,
                                  //         imagePath: 'assets/images/data_not_found.png',
                                  //         onBack: initAll,
                                  //         backText: 'Reload Materi',
                                  //       ),
                                  //     )
                                  : Builder(
                                    builder: (context) {
                                      // Ambil userId dari _dataUser
                                      final userId = _dataUser['id'] ?? '';

                                      // Progress Evaluasi
                                      final progresEvaluasiStr =
                                          _evaluasiDoneMap['count'] ?? '0';
                                      final progresEvaluasi =
                                          int.tryParse(progresEvaluasiStr) ?? 0;
                                      final totalEvaluasi = _evaluasiTotal ?? 1;

                                      // Progress Komitmen
                                      final progresKomitmenStr =
                                          _komitmenDoneMap['count'] ?? '0';
                                      final progresKomitmen =
                                          int.tryParse(progresKomitmenStr) ?? 0;
                                      final totalKomitmen = _komitmenTotal ?? 1;

                                      return Column(
                                        children: [
                                          MateriMenuCard(
                                            title: 'Evaluasi Pribadi',
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          ListEvaluasiScreen(
                                                            userId: userId,
                                                          ),
                                                ),
                                              ).then((result) {
                                                if (result == 'reload') {
                                                  initAll();
                                                }
                                              });
                                              ;
                                            },
                                            valueProgress:
                                                (totalEvaluasi > 0)
                                                    ? (progresEvaluasi /
                                                        totalEvaluasi)
                                                    : 0.0,
                                            valueDone: progresEvaluasi,
                                            valueTotal: totalEvaluasi,
                                          ),
                                          MateriMenuCard(
                                            title: 'Komitmen Pribadi',
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          ListKomitmenScreen(
                                                            userId: userId,
                                                          ),
                                                ),
                                              );
                                            },
                                            valueProgress:
                                                (totalKomitmen > 0)
                                                    ? (progresKomitmen /
                                                        totalKomitmen)
                                                    : 0.0,
                                            valueDone: progresKomitmen,
                                            valueTotal: totalKomitmen,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            BibleReadingListScreen(userId: id),
                                  ),
                                ).then((result) {
                                  if (result == 'reload') {
                                    initAll(); // reload dashboard
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    padding: const EdgeInsets.only(
                                      left: 150,
                                      right: 24,
                                      bottom: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(70),
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          'assets/images/card_bacaan.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Bacaan Saya',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              fontSize: 24,
                                            ),
                                            maxLines: 2,
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // const SizedBox(height: 16),
                            // InkWell(
                            //   onTap: () {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(builder: (context) => CatatanHarianScreen(role: role, id: id)),
                            //     );
                            //   },
                            //   borderRadius: BorderRadius.circular(16),
                            //   child: Stack(
                            //     children: [
                            //       Container(
                            //         height: 180,
                            //         padding: const EdgeInsets.only(left: 150, right: 24, bottom: 16),
                            //         decoration: BoxDecoration(
                            //           color: AppColors.primary.withAlpha(70),
                            //           borderRadius: BorderRadius.circular(16),
                            //           image: const DecorationImage(
                            //             image: AssetImage('assets/images/card_catatan.png'),
                            //             fit: BoxFit.cover,
                            //           ),
                            //         ),
                            //         child: Align(
                            //           alignment: Alignment.bottomRight,
                            //           child: Column(
                            //             mainAxisSize: MainAxisSize.min,
                            //             crossAxisAlignment: CrossAxisAlignment.end,
                            //             mainAxisAlignment: MainAxisAlignment.end,
                            //             children: [
                            //               Text(
                            //                 'Catatan Harian',
                            //                 style: const TextStyle(
                            //                   fontWeight: FontWeight.w900,
                            //                   color: Colors.white,
                            //                   fontSize: 22,
                            //                 ),
                            //                 maxLines: 2,
                            //                 textAlign: TextAlign.right,
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KontakPanitiaScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    padding: const EdgeInsets.only(
                                      left: 150,
                                      right: 24,
                                      bottom: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(70),
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          'assets/images/card_kontak.jpg',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Kontak Panitia',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              fontSize: 22,
                                            ),
                                            maxLines: 2,
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // day 1 - 3 untuk panitia
                            // if (role.toLowerCase().contains('panitia'))
                            //   _isLoading_progreskomitmenday1_panitia
                            //       ? buildProgresKomitmenPanitiaShimmerCard(
                            //         context,
                            //       )
                            //       : (() {
                            //         // Ambil jumlah peserta yang sudah mengisi komitmen hari ke-1
                            //         final progresDay1Str =
                            //             _komitmenDoneDay1MapPanitia['count'] ??
                            //             '0';
                            //         final totalDay1Str =
                            //             _countUserMapPanitia["count_peserta"] ??
                            //             '0';
                            //         final progresDay1 =
                            //             int.tryParse(progresDay1Str) ?? 0;
                            //         final totalDay1 =
                            //             int.tryParse(totalDay1Str) ?? 1;
                            //         final progressDay1Value =
                            //             totalDay1 > 0
                            //                 ? progresDay1 / totalDay1
                            //                 : 0.0;

                            //         // Ambil jumlah peserta yang sudah mengisi komitmen hari ke-2
                            //         final progresDay2Str =
                            //             _komitmenDoneDay2MapPanitia['count'] ??
                            //             '0';
                            //         final totalDay2Str =
                            //             _countUserMapPanitia["count_peserta"] ??
                            //             '0';
                            //         final progresDay2 =
                            //             int.tryParse(progresDay2Str) ?? 0;
                            //         final totalDay2 =
                            //             int.tryParse(totalDay2Str) ?? 1;
                            //         final progressDay2Value =
                            //             totalDay2 > 0
                            //                 ? progresDay2 / totalDay2
                            //                 : 0.0;

                            //         // Ambil jumlah peserta yang sudah mengisi komitmen hari ke-2
                            //         final progresDay3Str =
                            //             _komitmenDoneDay3MapPanitia['count'] ??
                            //             '0';
                            //         final totalDay3Str =
                            //             _countUserMapPanitia["count_peserta"] ??
                            //             '0';
                            //         final progresDay3 =
                            //             int.tryParse(progresDay2Str) ?? 0;
                            //         final totalDay3 =
                            //             int.tryParse(totalDay3Str) ?? 1;
                            //         final progressDay3Value =
                            //             totalDay3 > 0
                            //                 ? progresDay3 / totalDay3
                            //                 : 0.0;

                            //         return SizedBox(
                            //           height: 180,
                            //           child: Stack(
                            //             children: [
                            //               Positioned.fill(
                            //                 child: ClipRRect(
                            //                   borderRadius:
                            //                       BorderRadius.circular(16),
                            //                   child: Image.asset(
                            //                     'assets/images/card_komitmen2.jpg',
                            //                     fit: BoxFit.fill,
                            //                   ),
                            //                 ),
                            //               ),
                            //               Container(
                            //                 padding: const EdgeInsets.only(
                            //                   left: 96,
                            //                   right: 16,
                            //                   bottom: 16,
                            //                 ),
                            //                 decoration: BoxDecoration(
                            //                   borderRadius:
                            //                       BorderRadius.circular(16),
                            //                 ),
                            //                 child: Column(
                            //                   mainAxisAlignment:
                            //                       MainAxisAlignment.center,
                            //                   children: [
                            //                     Row(
                            //                       mainAxisAlignment:
                            //                           MainAxisAlignment.center,
                            //                       crossAxisAlignment:
                            //                           CrossAxisAlignment.center,
                            //                       children: [
                            //                         // day 1
                            //                         Column(
                            //                           mainAxisSize:
                            //                               MainAxisSize.min,
                            //                           crossAxisAlignment:
                            //                               CrossAxisAlignment
                            //                                   .center,
                            //                           children: [
                            //                             CustomCircularProgress(
                            //                               progress:
                            //                                   progressDay1Value
                            //                                       .clamp(
                            //                                         0.0,
                            //                                         1.0,
                            //                                       ),
                            //                               size: 70,
                            //                               color: Colors.white,
                            //                               duration: Duration(
                            //                                 milliseconds: 600,
                            //                               ),
                            //                               child: Column(
                            //                                 mainAxisAlignment:
                            //                                     MainAxisAlignment
                            //                                         .center,
                            //                                 children: [
                            //                                   Text(
                            //                                     '$progresDay1/$totalDay1',
                            //                                     style: TextStyle(
                            //                                       fontSize:
                            //                                           totalDay1 >
                            //                                                   500
                            //                                               ? 8
                            //                                               : 10,
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w900,
                            //                                       color:
                            //                                           Colors
                            //                                               .white,
                            //                                     ),
                            //                                   ),
                            //                                   Text(
                            //                                     'Hari ke-1',
                            //                                     style: TextStyle(
                            //                                       fontSize: 10,
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w400,
                            //                                       color:
                            //                                           Colors
                            //                                               .white,
                            //                                     ),
                            //                                   ),
                            //                                 ],
                            //                               ),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                         SizedBox(width: 8),
                            //                         // day 2
                            //                         Column(
                            //                           mainAxisSize:
                            //                               MainAxisSize.min,
                            //                           crossAxisAlignment:
                            //                               CrossAxisAlignment
                            //                                   .center,
                            //                           children: [
                            //                             CustomCircularProgress(
                            //                               progress:
                            //                                   progressDay2Value
                            //                                       .clamp(
                            //                                         0.0,
                            //                                         1.0,
                            //                                       ),
                            //                               size: 70,
                            //                               color: Colors.white,
                            //                               duration: Duration(
                            //                                 milliseconds: 600,
                            //                               ),
                            //                               child: Column(
                            //                                 mainAxisAlignment:
                            //                                     MainAxisAlignment
                            //                                         .center,
                            //                                 children: [
                            //                                   Text(
                            //                                     '$progresDay2/$totalDay2',
                            //                                     style: TextStyle(
                            //                                       fontSize:
                            //                                           totalDay1 >
                            //                                                   500
                            //                                               ? 8
                            //                                               : 10,
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w900,
                            //                                       color:
                            //                                           Colors
                            //                                               .white,
                            //                                     ),
                            //                                   ),
                            //                                   Text(
                            //                                     'Hari ke-2',
                            //                                     style: TextStyle(
                            //                                       fontSize: 10,
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w400,
                            //                                       color:
                            //                                           Colors
                            //                                               .white,
                            //                                     ),
                            //                                   ),
                            //                                 ],
                            //                               ),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                         SizedBox(width: 8),
                            //                         // day 3
                            //                         Column(
                            //                           mainAxisSize:
                            //                               MainAxisSize.min,
                            //                           crossAxisAlignment:
                            //                               CrossAxisAlignment
                            //                                   .center,
                            //                           children: [
                            //                             CustomCircularProgress(
                            //                               progress:
                            //                                   progressDay3Value
                            //                                       .clamp(
                            //                                         0.0,
                            //                                         1.0,
                            //                                       ),
                            //                               size: 70,
                            //                               color: Colors.white,
                            //                               duration: Duration(
                            //                                 milliseconds: 600,
                            //                               ),
                            //                               child: Column(
                            //                                 mainAxisAlignment:
                            //                                     MainAxisAlignment
                            //                                         .center,
                            //                                 children: [
                            //                                   Text(
                            //                                     '$progresDay3/$totalDay3',
                            //                                     style: TextStyle(
                            //                                       fontSize:
                            //                                           totalDay1 >
                            //                                                   500
                            //                                               ? 8
                            //                                               : 10,
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w900,
                            //                                       color:
                            //                                           Colors
                            //                                               .white,
                            //                                     ),
                            //                                   ),
                            //                                   Text(
                            //                                     'Hari ke-3',
                            //                                     style: TextStyle(
                            //                                       fontSize: 10,
                            //                                       fontWeight:
                            //                                           FontWeight
                            //                                               .w400,
                            //                                       color:
                            //                                           Colors
                            //                                               .white,
                            //                                     ),
                            //                                   ),
                            //                                 ],
                            //                               ),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                       ],
                            //                     ),
                            //                     const SizedBox(height: 8),
                            //                   ],
                            //                 ),
                            //               ),
                            //               Positioned(
                            //                 right: 16,
                            //                 bottom: 16,
                            //                 child: Text(
                            //                   'Pengisian Komitmen',
                            //                   style: TextStyle(
                            //                     fontSize: 22,
                            //                     color: Colors.white,
                            //                     fontWeight: FontWeight.w900,
                            //                   ),
                            //                   overflow: TextOverflow.ellipsis,
                            //                   textAlign: TextAlign.center,
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         );
                            //       })(),
                            const SizedBox(height: 24),
                            if (role.toLowerCase().contains('panitia'))
                              _isLoading_progreskomitmenday1_panitia
                                  ? buildProgresKomitmenPanitiaShimmerCard(
                                    context,
                                  )
                                  : (() {
                                    // Ambil jumlah peserta yang sudah mengisi komitmen hari ke-1
                                    final progresDay1Str =
                                        _komitmenDoneDay1MapPanitia['count'] ??
                                        '0';
                                    final totalDay1Str =
                                        _countUserMapPanitia["count_peserta"] ??
                                        '0';
                                    final progresDay1 =
                                        int.tryParse(progresDay1Str) ?? 0;
                                    final totalDay1 =
                                        int.tryParse(totalDay1Str) ?? 1;
                                    final progressDay1Value =
                                        totalDay1 > 0
                                            ? progresDay1 / totalDay1
                                            : 0.0;

                                    // Ambil jumlah peserta yang sudah mengisi komitmen hari ke-2
                                    final progresDay2Str =
                                        _komitmenDoneDay2MapPanitia['count'] ??
                                        '0';
                                    final totalDay2Str =
                                        _countUserMapPanitia["count_peserta"] ??
                                        '0';
                                    final progresDay2 =
                                        int.tryParse(progresDay2Str) ?? 0;
                                    final totalDay2 =
                                        int.tryParse(totalDay2Str) ?? 1;
                                    final progressDay2Value =
                                        totalDay2 > 0
                                            ? progresDay2 / totalDay2
                                            : 0.0;

                                    // Ambil jumlah peserta yang sudah mengisi komitmen hari ke-2
                                    final progresDay3Str =
                                        _komitmenDoneDay3MapPanitia['count'] ??
                                        '0';
                                    final totalDay3Str =
                                        _countUserMapPanitia["count_peserta"] ??
                                        '0';
                                    final progresDay3 =
                                        int.tryParse(progresDay2Str) ?? 0;
                                    final totalDay3 =
                                        int.tryParse(totalDay3Str) ?? 1;
                                    final progressDay3Value =
                                        totalDay3 > 0
                                            ? progresDay3 / totalDay3
                                            : 0.0;

                                    return SizedBox(
                                      height: 180,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.asset(
                                                'assets/images/card_komitmen3.jpg',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Pengisian Komitmen',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 16),
                                                // Linear progress per hari
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Hari 1',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        child: LinearProgressIndicator(
                                                          value:
                                                              progressDay1Value,
                                                          minHeight: 12,
                                                          backgroundColor:
                                                              Colors.white
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                          valueColor:
                                                              const AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      '$progresDay1/$totalDay1',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Hari 2',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        child: LinearProgressIndicator(
                                                          value:
                                                              progressDay2Value,
                                                          minHeight: 12,
                                                          backgroundColor:
                                                              Colors.white
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                          valueColor:
                                                              const AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      '$progresDay2/$totalDay2',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Hari 3',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        child: LinearProgressIndicator(
                                                          value:
                                                              progressDay3Value,
                                                          minHeight: 12,
                                                          backgroundColor:
                                                              Colors.white
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                          valueColor:
                                                              const AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      '$progresDay3/$totalDay3',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })(),

                            if (count_roles == "2") const SizedBox(height: 16),

                            if (count_roles == "2")
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  // onPressed: () async {
                                  //   setState(() async {
                                  //     if (role.toLowerCase().contains('pembimbing kelompok')) {
                                  //       await switchRole(context, 'Panitia');
                                  //     } else if (role.toLowerCase().contains('panitia')) {
                                  //       await switchRole(context, 'Pembimbing Kelompok');
                                  //     }
                                  //   });
                                  // },
                                  onPressed: () async {
                                    if (role.toLowerCase().contains(
                                      'pembimbing kelompok',
                                    )) {
                                      await switchRole(context, 'Panitia');
                                    } else if (role.toLowerCase().contains(
                                      'panitia',
                                    )) {
                                      await switchRole(
                                        context,
                                        'Pembimbing Kelompok',
                                      );
                                    }
                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const MainScreen(),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.switch_account),
                                  label: Text(
                                    role.toLowerCase().contains(
                                          'pembimbing kelompok',
                                        )
                                        ? 'Switch to Panitia'
                                        : 'Switch to Pembimbing Kelompok',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  logoutUser(context);
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Logout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                            //[DEVELOPMENT NOTES] untuk testing, nanti dihapus
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              child: const Text(
                                "Tombol Testing (nanti dihapus)",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),

                            //[DEVELOPMENT NOTES] untuk testing, nanti dihapus
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () {
                                            GlobalVariables.today = DateTime(
                                              2025,
                                              12,
                                              30,
                                            );
                                            GlobalVariables
                                                .timeOfDay = const TimeOfDay(
                                              hour: 6,
                                              minute: 0,
                                            );
                                            _today = GlobalVariables.today;
                                            _timeOfDay =
                                                GlobalVariables.timeOfDay;
                                            setState(() {
                                              GlobalVariables.currentIndex = 0;
                                            });
                                            if (mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const MainScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            '30-12-2025\n06:00',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () {
                                            GlobalVariables.today = DateTime(
                                              2025,
                                              12,
                                              30,
                                            );
                                            GlobalVariables
                                                .timeOfDay = const TimeOfDay(
                                              hour: 21,
                                              minute: 0,
                                            );
                                            _today = GlobalVariables.today;
                                            _timeOfDay =
                                                GlobalVariables.timeOfDay;
                                            setState(() {
                                              GlobalVariables.currentIndex = 0;
                                            });
                                            if (mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const MainScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            '30-12-2025\n21:00',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () {
                                            GlobalVariables.today = DateTime(
                                              2025,
                                              12,
                                              31,
                                            );
                                            GlobalVariables
                                                .timeOfDay = const TimeOfDay(
                                              hour: 3,
                                              minute: 0,
                                            );
                                            _today = GlobalVariables.today;
                                            _timeOfDay =
                                                GlobalVariables.timeOfDay;
                                            setState(() {
                                              GlobalVariables.currentIndex = 0;
                                            });
                                            if (mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const MainScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            '31-12-2025\n03:00',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () {
                                            GlobalVariables.today = DateTime(
                                              2025,
                                              12,
                                              31,
                                            );
                                            GlobalVariables
                                                .timeOfDay = const TimeOfDay(
                                              hour: 21,
                                              minute: 0,
                                            );
                                            _today = GlobalVariables.today;
                                            _timeOfDay =
                                                GlobalVariables.timeOfDay;
                                            setState(() {
                                              GlobalVariables.currentIndex = 0;
                                            });
                                            if (mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const MainScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            '31-12-2025\n21:00',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () {
                                            GlobalVariables.today = DateTime(
                                              2026,
                                              1,
                                              1,
                                            );
                                            GlobalVariables
                                                .timeOfDay = const TimeOfDay(
                                              hour: 3,
                                              minute: 0,
                                            );
                                            _today = GlobalVariables.today;
                                            _timeOfDay =
                                                GlobalVariables.timeOfDay;
                                            setState(() {
                                              GlobalVariables.currentIndex = 0;
                                            });
                                            if (mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const MainScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            '01-01-2026\n03:00',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () {
                                            GlobalVariables.today = DateTime(
                                              2026,
                                              1,
                                              1,
                                            );
                                            GlobalVariables
                                                .timeOfDay = const TimeOfDay(
                                              hour: 21,
                                              minute: 0,
                                            );
                                            _today = GlobalVariables.today;
                                            _timeOfDay =
                                                GlobalVariables.timeOfDay;
                                            setState(() {
                                              GlobalVariables.currentIndex = 0;
                                            });
                                            if (mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const MainScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            '01-01-2026\n21:00',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () {
                                            GlobalVariables.today = DateTime(
                                              2026,
                                              1,
                                              2,
                                            );
                                            GlobalVariables
                                                .timeOfDay = const TimeOfDay(
                                              hour: 3,
                                              minute: 0,
                                            );
                                            _today = GlobalVariables.today;
                                            _timeOfDay =
                                                GlobalVariables.timeOfDay;
                                            setState(() {
                                              GlobalVariables.currentIndex = 0;
                                            });
                                            if (mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const MainScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            '02-01-2026\n03:00',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () {
                                            GlobalVariables.today = DateTime(
                                              2026,
                                              1,
                                              2,
                                            );
                                            GlobalVariables
                                                .timeOfDay = const TimeOfDay(
                                              hour: 16,
                                              minute: 0,
                                            );
                                            _today = GlobalVariables.today;
                                            _timeOfDay =
                                                GlobalVariables.timeOfDay;
                                            setState(() {
                                              GlobalVariables.currentIndex = 0;
                                            });
                                            if (mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const MainScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            '02-01-2026\n16:00',
                                            textAlign: TextAlign.center,
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

Widget buildAcaraShimmer() {
  return Column(
    children: List.generate(2, (index) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(height: 12, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Container(
                        width: 40,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }),
  );
}

Widget buildBacaanShimer() {
  return Stack(
    children: [
      Container(
        height: 180,
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 120,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: Container(
              width: 60,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget buildProgresKomitmenPanitiaShimmerCard(BuildContext context) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    period: const Duration(milliseconds: 800),
    child: Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(width: 120, height: 24, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 200, height: 16, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 80, height: 16, color: Colors.white),
          ],
        ),
      ),
    ),
  );
}

class MateriMenuCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double valueProgress;
  final int? valueDone;
  final int? valueTotal;

  const MateriMenuCard({
    super.key,
    required this.title,
    required this.onTap,
    this.valueProgress = 0.0,
    this.valueDone,
    this.valueTotal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: valueProgress,
                            minHeight: 12,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              valueProgress >= 1.0
                                  ? Colors.green
                                  : valueProgress >= 0.5
                                  ? AppColors.secondary
                                  : AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                      if (valueDone != null && valueTotal != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            '$valueDone/$valueTotal',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
    );
  }
}
