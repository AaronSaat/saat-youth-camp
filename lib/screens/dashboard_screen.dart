import 'dart:convert';
import 'dart:io';
import 'package:app_badge_plus/app_badge_plus.dart' show AppBadgePlus;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/main.dart';
import 'package:syc/screens/form_komitmen_screen.dart';
import 'package:syc/screens/list_tutorial_screen.dart';
import 'package:syc/screens/main_screen.dart';
import 'package:syc/screens/profile_edit_screen.dart';
import 'package:syc/services/notification_service.dart'
    show NotificationService;
import 'package:syc/utils/global_variables.dart';
import 'package:syc/widgets/custom_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode, launchUrl;
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_not_found.dart';
import 'package:shimmer/shimmer.dart';

import 'package:syc/utils/app_colors.dart';

import 'detail_acara_screen.dart';
import 'bible_reading_more_screen.dart';
import 'evaluasi_komitmen_view_screen.dart';
import 'pengumuman_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Static data untuk acara hari ke-1

  String statusDatang = '';
  bool isPanitia = false;
  ScrollController _acaraController = ScrollController();
  // List<dynamic> _acaraList = [];
  List<dynamic> _acaraListAll = []; //untuk flutter local notification
  List<dynamic> _komitmenListAll = [];
  List<dynamic> _acaraDateList = [];
  List<Map<String, dynamic>> _pengumumanList = [];
  int day = 1;
  int countRead = 0;
  int countAcara = 5;
  bool _isLoading = true;
  bool _isLoadingBrm = true;
  bool _isLoadingPengumuman = true;
  List<Map<String, dynamic>> _dataBrm = [];
  Map<String, String> _dataUser = {};
  bool _komitmenDone = false;
  DateTime? _lastBackPressed;
  // DateTime _today = DateTime.now();
  final NotificationService _notificationService = NotificationService();

  bool isSupported = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ini dipakai untuk acara hari ini statis, kartu komitmen, kartu dokumentasi
  // [DEVELOPMENT NOTES] nanti hapus
  // untuk testing, set di global variables.dart
  // DateTime _today = DateTime.now();
  // DateTime _today = DateTime(2025, 12, 31);
  late DateTime _today;
  late String komitmenDay;
  // TimeOfDay _timeOfDay = TimeOfDay.now();
  late TimeOfDay _timeOfDay;
  ScrollController _acaraStatisHari1Controller = ScrollController();
  ScrollController _acaraStatisHari2Controller = ScrollController();
  ScrollController _acaraStatisHari3Controller = ScrollController();
  ScrollController _acaraStatisHari4Controller = ScrollController();

  //static data
  final List<Map<String, dynamic>> acaraStatisHari1 = [
    {
      'id': 1,
      'acara_nama': 'Welcome to STT SAAT - SYC 2025 & Registration',
      'tanggal': DateTime(2025, 12, 30),
      'waktu': TimeOfDay(hour: 7, minute: 0),
      'tempat': 'Plaza Auditorium',
      'gambar': 'assets/mockups/registration.jpg',
    },
    {
      'id': 2,
      'acara_nama': 'Group Bonding',
      'tanggal': DateTime(2025, 12, 30),
      'waktu': TimeOfDay(hour: 16, minute: 0),
      'tempat': 'Seluruh Kampus',
      'gambar': 'assets/mockups/bonding.jpg',
    },
    {
      'id': 3,
      'acara_nama': 'Dinner',
      'tanggal': DateTime(2025, 12, 30),
      'waktu': TimeOfDay(hour: 18, minute: 30),
      'tempat': 'Ruang Makan',
      'gambar': 'assets/mockups/eat.jpg',
    },
    {
      'id': 4,
      'acara_nama': 'Opening (KKR1)',
      'tanggal': DateTime(2025, 12, 30),
      'waktu': TimeOfDay(hour: 19, minute: 30),
      'tempat': 'Auditorium',
      'gambar': 'assets/mockups/opening.jpg',
    },
    {
      'id': 5,
      'acara_nama': 'Alone with God',
      'tanggal': DateTime(2025, 12, 30),
      'waktu': TimeOfDay(hour: 21, minute: 30),
      'tempat': 'Auditorium',
      'gambar': 'assets/mockups/awg.jpg',
    },
    {
      'id': 6,
      'acara_nama': 'Rest',
      'tanggal': DateTime(2025, 12, 30),
      'waktu': TimeOfDay(hour: 22, minute: 30),
      'tempat': 'Ruangan Masing-Masing',
      'gambar': 'assets/mockups/rest.jpg',
    },
  ];

  //static data
  final List<Map<String, dynamic>> acaraStatisHari2 = [
    {
      'id': 7,
      'acara_nama': 'Self Preparation',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 6, minute: 0),
      'tempat': 'Ruangan Masing-Masing',
      'gambar': 'assets/mockups/preparation.jpg',
    },
    {
      'id': 8,
      'acara_nama': 'Breakfast',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 7, minute: 0),
      'tempat': 'Ruang Makan',
      'gambar': 'assets/mockups/eat.jpg',
    },
    {
      'id': 9,
      'acara_nama': 'Morning Devotion',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 8, minute: 0),
      'tempat': 'Seluruh Kampus',
      'gambar': 'assets/mockups/devotion.jpg',
    },
    {
      'id': 10,
      'acara_nama': 'Group Acitivity (with snack) - The Path of Redemption',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 9, minute: 0),
      'tempat': 'Seluruh Kampus',
      'gambar': 'assets/mockups/activity.jpg',
    },
    {
      'id': 11,
      'acara_nama': 'Lunch',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 12, minute: 30),
      'tempat': 'Ruang Makan',
      'gambar': 'assets/mockups/eat.jpg',
    },
    {
      'id': 12,
      'acara_nama': 'BKC - Semifinal',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 13, minute: 0),
      'tempat': 'Auditorium',
      'gambar': 'assets/mockups/bkc.jpg',
    },
    {
      'id': 13,
      'acara_nama': 'Self Preparation',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 15, minute: 0),
      'tempat': 'Ruangan Masing-Masing',
      'gambar': 'assets/mockups/preparation.jpg',
    },
    {
      'id': 14,
      'acara_nama': 'SYC Talks: The Book of Galatian',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 16, minute: 30),
      'tempat': 'Auditorium',
      'gambar': 'assets/mockups/talks.jpg',
    },
    {
      'id': 15,
      'acara_nama': 'Dinner',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 18, minute: 30),
      'tempat': 'Ruang Makan',
      'gambar': 'assets/mockups/eat.jpg',
    },
    {
      'id': 16,
      'acara_nama': 'KKR 2 - Jesus Paid it All',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 19, minute: 30),
      'tempat': 'Auditorium',
      'gambar': 'assets/mockups/kkr2.jpg',
    },
    {
      'id': 17,
      'acara_nama': 'Special Program',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 21, minute: 30),
      'tempat': 'Auditorium',
      'gambar': 'assets/mockups/special.jpg',
    },
  ];

  //static data
  final List<Map<String, dynamic>> acaraStatisHari3 = [
    {
      'id': 18,
      'acara_nama': 'Rest',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 1, minute: 30),
      'tempat': 'Ruangan Masing-Masing',
      'gambar': 'assets/mockups/rest.jpg',
    },
    {
      'id': 19,
      'acara_nama': 'Self Preparation',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 6, minute: 0),
      'tempat': 'Ruangan Masing-Masing',
      'gambar': 'assets/mockups/preparation.jpg',
    },
    {
      'id': 20,
      'acara_nama': 'Breakfast',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 8, minute: 0),
      'tempat': 'Ruang Makan',
      'gambar': 'assets/mockups/eat.jpg',
    },
    {
      'id': 21,
      'acara_nama': 'Morning Devotion',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 9, minute: 0),
      'tempat': 'Seluruh Kampus',
      'gambar': 'assets/mockups/devotion.jpg',
    },
    {
      'id': 22,
      'acara_nama': 'Group Acitivity "Living Redeemed Life"',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 10, minute: 0),
      'tempat': 'Seluruh Kampus',
      'gambar': 'assets/mockups/activity.jpg',
    },
    {
      'id': 23,
      'acara_nama': 'Lunch',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 12, minute: 30),
      'tempat': 'Ruang Makan',
      'gambar': 'assets/mockups/eat.jpg',
    },
    {
      'id': 24,
      'acara_nama': 'BKC - Final',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 13, minute: 0),
      'tempat': 'Auditorium',
      'gambar': 'assets/mockups/bkc.jpg',
    },
    {
      'id': 25,
      'acara_nama': "Self Preparation",
      "tanggal": DateTime(2026, 01, 01),
      "waktu": TimeOfDay(hour: 15, minute: 0),
      "tempat": "Ruangan Masing-Masing",
      "gambar": "assets/mockups/preparation.jpg",
    },
    {
      'id': 26,
      'acara_nama': 'SYC Talks: The Work of Christ',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 16, minute: 30),
      'tempat': 'Auditorium',
      'gambar': 'assets/mockups/talks.jpg',
    },
    {
      'id': 27,
      'acara_nama': 'Dinner',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 18, minute: 30),
      'tempat': 'Ruang Makan',
      'gambar': 'assets/mockups/eat.jpg',
    },
    {
      'id': 28,
      'acara_nama': "KKR 3 - The Redeemed Z's",
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 19, minute: 30),
      'tempat': 'Auditorium',
      'gambar': 'assets/mockups/kkr3.jpg',
    },
    {
      'id': 29,
      'acara_nama': "Commited Among Us",
      "tanggal": DateTime(2026, 01, 01),
      "waktu": TimeOfDay(hour: 21, minute: 30),
      "tempat": "Auditorium",
      "gambar": "assets/mockups/amongus.jpg",
    },
    {
      'id': 30,
      'acara_nama': "Rest",
      "tanggal": DateTime(2026, 01, 01),
      "waktu": TimeOfDay(hour: 22, minute: 30),
      "tempat": "Ruangan Masing-Masing",
      "gambar": "assets/mockups/rest.jpg",
    },
  ];

  //static data
  final List<Map<String, dynamic>> acaraStatisHari4 = [
    {
      'id': 31,
      'acara_nama': 'Self Preparation',
      'tanggal': DateTime(2026, 01, 02),
      'waktu': TimeOfDay(hour: 6, minute: 0),
      'tempat': 'Ruangan Masing-Masing',
      'gambar': 'assets/mockups/preparation.jpg',
    },
    {
      'id': 32,
      'acara_nama': 'Breakfast',
      'tanggal': DateTime(2026, 01, 02),
      'waktu': TimeOfDay(hour: 7, minute: 0),
      'tempat': 'Ruang Makan',
      'gambar': 'assets/mockups/eat.jpg',
    },
    {
      'id': 33,
      'acara_nama': 'Morning Devotion',
      'tanggal': DateTime(2026, 01, 02),
      'waktu': TimeOfDay(hour: 8, minute: 0),
      'tempat': 'Seluruh Kampus',
      'gambar': 'assets/mockups/devotion.jpg',
    },
    {
      'id': 34,
      'acara_nama': "Closing - Redeemed: The Story I Love to Share",
      'tanggal': DateTime(2026, 01, 02),
      'waktu': TimeOfDay(hour: 9, minute: 0),
      'tempat': 'Auditorium',
      'gambar': 'assets/mockups/closing.jpg',
    },
    {
      'id': 35,
      'acara_nama': "Lunch",
      "tanggal": DateTime(2026, 01, 02),
      "waktu": TimeOfDay(hour: 12, minute: 30),
      "tempat": "Ruang Makan",
      "gambar": "assets/mockups/eat.jpg",
    },
    {
      'id': 36,
      'acara_nama':
          "Home, Transformed & Recharged to Worship & Witness For The Glory of God -> See You @ SYC 2026",
      "tanggal": DateTime(2026, 01, 02),
      "waktu": TimeOfDay(hour: 13, minute: 0),
      "tempat": "Auditorium",
      "gambar": "assets/mockups/seeyou.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();

    _lastBackPressed = null;

    //[DEVELOPMENT NOTES] untuk testing, nanti dihapus
    setState(() {
      _today = GlobalVariables.today;
      _timeOfDay = GlobalVariables.timeOfDay;
    });

    // Inisialisasi plugin notifikasi lokal
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    flutterLocalNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Pesan FCM masuk: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    AppBadgePlus.isSupported().then((value) {
      isSupported = value;
      setState(() {});
    });

    initAll();
    // print('[BackgroundSync] Dashboard dibuka pada: ${DateTime.now()}');
    // setupBackgroundSync(); // Setup background sync untuk pengumuman

    _acaraController.addListener(() {
      double itemWidth;
      if (countAcara <= 2) {
        itemWidth = 40;
      } else if (countAcara == 3) {
        itemWidth = 110;
      } else {
        itemWidth = 160;
      }
      setState(() {});
    });
  }

  Future<void> initAll({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _isLoadingPengumuman = true;
    });
    print(
      '_today: ${_today.toIso8601String().substring(0, 10)}, acaraStatisHari1[0][tanggal]: ${acaraStatisHari1[0]["tanggal"]}, eq: ${_today.toIso8601String().substring(0, 10) == acaraStatisHari1[0]["tanggal"].toString().substring(0, 10)}',
    );

    // Selalu update status_datang di SharedPreferences dari API sebelum loadUserData
    await loadUserData(forceRefresh: forceRefresh);

    // if (_dataUser['role'] == 'Peserta' && _dataUser['status_datang'] == "0") {
    //   print('Checking status datang...');
    // await checkStatusDatang();
    // }
    // await saveUserDevice();
    await loadBrmData(forceRefresh: forceRefresh);
    await loadPengumumanByUserId(forceRefresh: forceRefresh);
    await checkKomitmenDoneForReminderCard();

    await loadAllNotifikasiAcara();

    final roleLower = (_dataUser['role'] ?? '').toString().toLowerCase();
    if (roleLower.contains('peserta') || roleLower.contains('pembina')) {
      await loadAllNotifikasiKomitmen();
    }
    // await setupAllNotification();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isLoadingPengumuman = false;
    });
  }

  Future<void> loadUserData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {});
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
      'kamar',
      'status_datang',
    ];
    final Map<String, String> userData = {};
    for (final key in keys) {
      userData[key] = prefs.getString(key) ?? '';
    }

    // Jika forceRefresh, ambil data kamar & kelompok dari API, update shared pref
    if (forceRefresh) {
      final userId = prefs.getString('id') ?? '';
      var role = prefs.getString('role') ?? '';
      if (role == 'Pembimbing Kelompok') {
        role = 'Pembimbing';
      }
      if (userId.isNotEmpty) {
        final response = await ApiService.getInfoKamarKelompok(
          context,
          userId,
          role,
        );
        print(
          'SWITCH Kelompok Nama (shared pref): ${userData['kelompok_nama']}',
        );
        print('SWITCH Kelompok ID (shared pref): ${userData['kelompok_id']}');
        print('SWITCH Kamar (shared pref): ${userData['kamar']}');
        print('SWITCH getInfoKamarKelompok response: $response');
        // Simpan nilai lama untuk dibandingkan
        final oldKelompokNama = userData['kelompok_nama'] ?? '';
        final oldKamar = userData['kamar'] ?? '';

        // response diharapkan Map<String, dynamic> sesuai contoh
        if (response != null && response['data'] != null) {
          final data = response['data'];
          // Kelompok
          if (data['kelompok'] != null) {
            final kelompok = data['kelompok'];
            await prefs.setString(
              'kelompok_id',
              kelompok['id']?.toString() ?? '',
            );
            userData['kelompok_id'] = kelompok['id']?.toString() ?? '';
            await prefs.setString(
              'kelompok_nama',
              kelompok['nama_kelompok']?.toString() ?? '',
            );
            userData['kelompok_nama'] =
                kelompok['nama_kelompok']?.toString() ?? '';
          } else {
            await prefs.setString('kelompok_id', 'Null');
            userData['kelompok_id'] = 'Null';
            await prefs.setString('kelompok_nama', 'Tidak ada kelompok');
            userData['kelompok_nama'] = 'Tidak ada kelompok';
          }
          // Kamar
          if (data['kamar'] != null) {
            await prefs.setString('kamar', data['kamar'].toString());
            userData['kamar'] = data['kamar'].toString();
          } else {
            await prefs.setString('kamar', 'Tidak ada kamar');
            userData['kamar'] = 'Tidak ada kamar';
          }
          // Bandingkan, jika berubah, pushReplacement ke MainScreen
          final newKelompokNama = userData['kelompok_nama'] ?? '';
          final newKamar = userData['kamar'] ?? '';
          if ((oldKelompokNama != newKelompokNama) || (oldKamar != newKamar)) {
            print(
              'SWITCH Kelompok berubah: $oldKelompokNama -> $newKelompokNama, Kamar: $oldKamar -> $newKamar',
            );
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            }
          }
          // Update state after fetching and saving data
          if (!mounted) return;
          setState(() {
            GlobalVariables.currentIndex = 0;
            _dataUser = userData;
          });
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _dataUser = userData;
    });
  }

  // Future<void> loadBrm() async {
  //   try {
  //     final brm = await ApiService.getBrmToday(context);
  //     if (!mounted) return;
  //     setState(() {
  //       final dataBrm = brm['data_brm'];
  //       if (dataBrm != null && dataBrm is Map<String, dynamic>) {
  //         _dataBrm = [dataBrm];
  //       } else {
  //         _dataBrm = [];
  //       }
  //       // print('Data BRM: $_dataBrm');
  //       _isLoadingBrm = false;
  //     });
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() => _isLoadingBrm = false);
  //   }
  // }

  // count read tidak bisa disimpan 10 hari, harus terupdate setiap hari
  Future<void> loadBrmData({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final bacaanTodayKey = 'dashboard_bacaan_$today';
    final countReadKey = 'dashboard_bacaan_count_$today';

    // Jika forceRefresh, selalu ambil dari API
    if (!forceRefresh) {
      final bacaanToday = prefs.getString(bacaanTodayKey);
      final countReadToday = prefs.getInt(countReadKey) ?? 0;
      if (bacaanToday != null && bacaanToday.isNotEmpty) {
        setState(() {
          _dataBrm = [
            {'tanggal': today, 'passage': bacaanToday, 'read': countReadToday},
          ];
          print('[PREF_API] Load hari ini dari shared pref: $_dataBrm');
          _isLoadingBrm = false;
        });
        return;
      }
    }

    // Fetch dari API
    final response = await ApiService.getBrmTenDays(
      context,
      _dataUser['id'] ?? '',
    );
    final List<dynamic> dataBrmList = response['data_brm'] ?? [];

    // Simpan semua ke shared pref
    for (final brm in dataBrmList) {
      final tanggal = brm['tanggal'];
      final passage = brm['passage'] ?? '';
      // Pastikan read disimpan sebagai int
      final countRead = int.tryParse(brm['read'].toString()) ?? 0;
      if (tanggal != null) {
        await prefs.setString('dashboard_bacaan_$tanggal', passage);
        await prefs.setInt('dashboard_bacaan_count_$tanggal', countRead);
      }
    }

    // Ambil data hari ini dari hasil API (atau kosong jika tidak ada)
    final todayBrm = dataBrmList.firstWhere(
      (item) => item['tanggal'] == today,
      orElse: () => null,
    );

    if (!mounted) return;
    setState(() {
      _dataBrm =
          todayBrm != null
              ? [
                {
                  'tanggal': todayBrm['tanggal'],
                  'passage': todayBrm['passage'],
                  'read': int.tryParse(todayBrm['read'].toString()) ?? 0,
                },
              ]
              : [];
      print(
        '[PREF_API] Load hari ini dari API dan simpan ke shared pref: $_dataBrm',
      );
      _isLoadingBrm = false;
    });
  }

  // untuk load acara berdasarkan hari ini
  // Future<void> loadDayHariIni() async {
  //   if (!mounted) return;
  //   setState(() {});
  //   try {
  //     final acaraList = await ApiService.getAcara(context);
  //     if (!mounted) return;
  //     setState(() {
  //       print('Acara Date List: $acaraList');

  //       // Ambil list tanggal dan hari unik
  //       final List<Map<String, dynamic>> tanggalHariList = [];
  //       final Set<String> tanggalHariSet = {};

  //       for (var acara in acaraList) {
  //         final tanggal = acara['tanggal'];
  //         final hari = acara['hari'];
  //         final key = '$tanggal|$hari';
  //         if (!tanggalHariSet.contains(key)) {
  //           tanggalHariSet.add(key);
  //           tanggalHariList.add({'tanggal': tanggal, 'hari': hari});
  //         }
  //       }

  //       _acaraDateList = tanggalHariList;
  //       print("$_acaraDateList");

  //       // Cek apakah today ada di tanggalHariList
  //       final todayEntry = tanggalHariList.firstWhere(
  //         (item) =>
  //             item['tanggal'] == _today.toIso8601String().substring(0, 10),
  //         orElse: () => {},
  //       );
  //       if (todayEntry.isNotEmpty) {
  //         day = todayEntry['hari'] ?? 0;
  //         print('Hari ini: $day');
  //       } else {
  //         day = 0; //  default
  //       }
  //     });
  //   } catch (e) {
  //     print('❌ Gagal memuat tanggal acara: $e');
  //     if (!mounted) return;
  //     setState(() {});
  //   }
  // }

  // Future<void> loadAcaraByDay() async {
  //   if (!mounted) return;
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final acaraList = await ApiService.getAcaraByDay(context, day);
  //     if (!mounted) return;
  //     setState(() {
  //       _acaraList = acaraList;
  //       _isLoading = false;
  //       countAcara = _acaraList.length;
  //       print('Acara List: $_acaraList');
  //       print('Jumlah Acara: ${_acaraList.length}');
  //     });
  //   } catch (e) {
  //     print('❌ Gagal memuat acara: $e');
  //     if (!mounted) return;
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // untuk notifikasi lokal
  Future<void> loadAllNotifikasiAcara() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final acaraList = await ApiService.getAcara(context);
      if (!mounted) return;
      setState(() {
        _acaraListAll = acaraList;
        scheduleReminderDanEvaluasiNotificationsForUser(_dataUser['id'] ?? '');
        _isLoading = false;
        print('Acara List All: \n$_acaraListAll');
      });
    } catch (e) {
      print('❌ Gagal memuat all acara : $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> scheduleReminderDanEvaluasiNotificationsForUser(
    String userId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifIdsKey = 'notif_acara_ids_$userId';
      final List<String> scheduledIds = <String>[];

      // Determine role-based permission for evaluasi notifications
      final roleLower = (_dataUser['role'] ?? '').toString().toLowerCase();
      final bool shouldScheduleEval =
          roleLower.contains('peserta') || roleLower.contains('pembina');

      // Ensure notification service initialized once
      await _notificationService.initialize();

      final now = DateTime.now();

      for (final acara in _acaraListAll) {
        try {
          // Determine whether this acara has notif enabled (handle multiple representations)
          final isNotifRaw = acara['is_notif'];
          final bool isNotif =
              (isNotifRaw == true) ||
              (isNotifRaw == 1) ||
              (isNotifRaw == '1') ||
              (isNotifRaw?.toString().toLowerCase() == 'true');

          if (!isNotif) continue;

          final acaraIdStr = (acara['id']?.toString() ?? '');
          final acaraIdNum = int.tryParse(acaraIdStr) ?? acara.hashCode.abs();
          final tanggalStr = acara['tanggal']?.toString() ?? '';
          final waktuStr = acara['waktu']?.toString() ?? '';

          if (tanggalStr.isEmpty || waktuStr.isEmpty) {
            print('👟 Skipping acara ${acaraIdStr}: missing tanggal/waktu');
            continue;
          }

          DateTime eventStart;
          try {
            // Expect waktu in "HH:mm" most of the time
            final waktuNormalized =
                (waktuStr.length == 5 && waktuStr.contains(':'))
                    ? waktuStr
                    : '00:00';
            eventStart = DateTime.parse('$tanggalStr $waktuNormalized:00');
          } catch (e) {
            // Try fallback parse from just date then add hours if waktu is numeric/hhmm
            try {
              final base = DateTime.parse(tanggalStr);
              final parts = waktuStr.split(':');
              final hh = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
              final mm = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
              eventStart = DateTime(base.year, base.month, base.day, hh, mm);
            } catch (e2) {
              print(
                'Failed to parse event start for acara $acaraIdStr: $e / $e2',
              );
              continue;
            }
          }

          // Reminder (15 minutes before) - for all roles
          final scheduledReminder = eventStart.subtract(
            const Duration(minutes: 15),
          );
          if (scheduledReminder.isAfter(now)) {
            // Stable notif id composition to reduce collisions
            final baseUser =
                int.tryParse(userId) ?? (now.millisecondsSinceEpoch ~/ 1000);
            final reminderId =
                (baseUser.abs() % 100000) * 100000 +
                (acaraIdNum.abs() % 100000);

            final titleRem = '⏰ ${acara['acara_nama'] ?? 'Acara'} akan dimulai';
            final bodyRem =
                '${acara['acara_nama'] ?? 'Acara'} akan dimulai dalam 15 menit';

            await _notificationService.scheduledNotification(
              id: reminderId,
              title: titleRem,
              body: bodyRem,
              scheduledTime: scheduledReminder,
              payload: 'splash',
            );

            scheduledIds.add(reminderId.toString());
            await prefs.setBool('notif_acara_${acaraIdStr}_reminder', true);
            await prefs.setString(
              'notif_acara_${acaraIdStr}_time',
              scheduledReminder.toIso8601String(),
            );

            print(
              'Scheduled acara reminder (ID:$reminderId) for $scheduledReminder',
            );
          } else {
            print(
              'Skip scheduling reminder for acara $acaraIdStr: time already passed',
            );
          }

          // Evaluasi (1 hour after event start) - only for peserta and pembimbing
          final scheduledEval = eventStart.add(const Duration(hours: 1));
          if (!shouldScheduleEval) {
            print(
              'Skipping evaluasi scheduling for user role "$roleLower" (acara $acaraIdStr)',
            );
          } else if (scheduledEval.isAfter(now)) {
            final baseUser =
                int.tryParse(userId) ?? (now.millisecondsSinceEpoch ~/ 1000);
            final reminderId =
                (baseUser.abs() % 100000) * 100000 +
                (acaraIdNum.abs() % 100000);
            final evalId = reminderId + 1000000; // offset for evaluasi

            final titleEval = '📝 Waktu Evaluasi';
            final bodyEval =
                'Silakan isi evaluasi untuk acara: ${acara['acara_nama'] ?? 'Acara'}';

            await _notificationService.scheduledNotification(
              id: evalId,
              title: titleEval,
              body: bodyEval,
              scheduledTime: scheduledEval,
              payload: 'splash',
            );

            scheduledIds.add(evalId.toString());
            await prefs.setBool('notif_acara_${acaraIdStr}_evaluasi', true);
            await prefs.setString(
              'notif_acara_${acaraIdStr}_eval_time',
              scheduledEval.toIso8601String(),
            );

            print('Scheduled acara evaluasi (ID:$evalId) for $scheduledEval');
          } else {
            print(
              'Skip scheduling evaluasi for acara $acaraIdStr: time already passed',
            );
          }
        } catch (e) {
          print('Error scheduling notifications for acara entry $acara : $e');
        }
      }

      if (scheduledIds.isNotEmpty) {
        // Merge with existing ids if present
        final existing = prefs.getStringList(notifIdsKey) ?? <String>[];
        final merged = <String>{...existing, ...scheduledIds}.toList();
        await prefs.setStringList(notifIdsKey, merged);
        print('Saved acara notif ids ($notifIdsKey): $merged');
      } else {
        print('No acara notifications were scheduled for user $userId');
      }
    } catch (e) {
      print('Error in scheduleReminderDanEvaluasiNotificationsForUser: $e');
    }
  }

  // untuk notifikasi lokal
  Future<void> loadAllNotifikasiKomitmen() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final komitmenList = await ApiService.getKomitmen(context);
      if (!mounted) return;
      setState(() {
        _komitmenListAll = komitmenList;
        // For testing: override cached data with sample entries
        // try {
        //   _komitmenListAll.clear();
        //   _komitmenListAll.addAll([
        //     {'hari': 1, 'tanggal': '2025-10-20'},
        //     {'hari': 2, 'tanggal': '2025-10-21'},
        //     {'hari': 3, 'tanggal': '2025-10-22'},
        //   ]);
        // } catch (e) {
        //   // ignore if cached values are not mutable
        // }
        scheduleKomitmenNotificationsForUser(_dataUser['id'] ?? '');
        _isLoading = false;
        print('Komitmen List All: \n$_komitmenListAll');
      });
    } catch (e) {
      print('❌ Gagal memuat all komitmen : $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Schedule komitmen notifications for a user based on _komitmenListAll.
  // Saves setting bool at 'notif_komitmen_<userId>' and saves ids at
  // 'notif_komitmen_ids_<userId>'.
  Future<void> scheduleKomitmenNotificationsForUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifEnabledKey = 'notif_komitmen_$userId';
      final notifIdsKey = 'notif_komitmen_ids_$userId';

      // mark enabled in list_komitmen_screen
      await prefs.setBool(notifEnabledKey, true);

      // Ensure notification plugin initialized
      await _notificationService.initialize();

      final now = DateTime.now();
      final List<String> scheduledIds = [];

      // Use _komitmenListAll (assumed loaded by loadAllNotifikasiKomitmen)
      for (final komitmen in _komitmenListAll) {
        try {
          final tanggalStr = komitmen['tanggal']?.toString() ?? '';
          if (tanggalStr.isEmpty) continue;

          // Build scheduled DateTime at 21:00 on the komitmen date
          DateTime scheduledDate;
          try {
            scheduledDate = DateTime.parse('$tanggalStr 21:00:00');
          } catch (_) {
            // try a fallback without assuming exact format
            scheduledDate = DateTime.parse(
              tanggalStr,
            ).add(const Duration(hours: 21));
          }

          if (scheduledDate.isBefore(now)) {
            // skip past dates
            continue;
          }

          // Prefer a stable komitmen id if available
          int notifId;
          final komitmenId = int.tryParse(komitmen['id']?.toString() ?? '');
          if (komitmenId != null && komitmenId > 0) {
            // compose id using userId and komitmenId to reduce collision risk
            final u = int.tryParse(userId) ?? 0;
            notifId = (u.abs() % 100000) * 100000 + (komitmenId.abs() % 100000);
          } else {
            // fallback to previous formula using hari
            final baseUser =
                int.tryParse(userId) ??
                DateTime.now().millisecondsSinceEpoch ~/ 1000;
            final hariNum =
                int.tryParse(komitmen['hari']?.toString() ?? '') ?? 0;
            notifId = baseUser.abs() % 100000 * 100 + hariNum;
          }

          final title = '🙏 Komitmen Hari ke-${komitmen['hari'] ?? '-'}';
          final body =
              'Jangan lupa mengisi komitmen untuk tanggal $tanggalStr.';
          final payload = 'splash';

          await _notificationService.scheduledNotification(
            id: notifId,
            title: title,
            body: body,
            scheduledTime: scheduledDate,
            payload: payload,
          );

          // record scheduled id (string)
          scheduledIds.add(notifId.toString());

          // debug log
          print(
            'Scheduled komitmen notif (ID: $notifId) for $scheduledDate (user $userId)',
          );
        } catch (e) {
          print('Error scheduling komitmen reminder for entry $komitmen : $e');
        }
      }

      // persist scheduled ids
      if (scheduledIds.isNotEmpty) {
        await prefs.setStringList(notifIdsKey, scheduledIds);
        print('Saved komitmen notif ids ($notifIdsKey): $scheduledIds');
      } else {
        print(
          'No komitmen notifications scheduled (no future komitmen found).',
        );
      }
    } catch (e) {
      print('Error in scheduleKomitmenNotificationsForUser: $e');
    }
  }

  Future<void> loadPengumumanByUserId({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _dataUser['id'] ?? '';
    final pengumumanKey = 'pengumuman_not_read_$userId';

    if (!forceRefresh) {
      final cachedPengumuman = prefs.getString(pengumumanKey);
      if (cachedPengumuman != null) {
        final List<dynamic> decoded = jsonDecode(cachedPengumuman);
        final pengumumanList2 = List<Map<String, dynamic>>.from(decoded);
        if (!mounted) return;
        setState(() {
          _pengumumanList = pengumumanList2;
          _isLoadingPengumuman = false;
          print(
            '[PREF_API] Pengumuman List (from shared pref): $_pengumumanList',
          );
        });
        return;
      }
    }

    try {
      final pengumumanList = await ApiService.getPengumumanNotRead(
        context,
        userId,
      );
      await prefs.setString(pengumumanKey, jsonEncode(pengumumanList));
      if (!mounted) return;
      setState(() {
        final pengumumanList2 = List<Map<String, dynamic>>.from(pengumumanList);
        _pengumumanList = pengumumanList2;
        _isLoadingPengumuman = false;
        print('[PREF_API] Pengumuman List (from API): $_pengumumanList');

        AppBadgePlus.isSupported().then((value) {
          isSupported = value;
          setState(() {});
        });

        AppBadgePlus.updateBadge(_pengumumanList.length);
        print('Badge updated: ${_pengumumanList.length}');
      });
    } catch (e) {
      print('❌ Gagal memuat pengumuman: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingPengumuman = false;
      });
    }
  }

  Future<void> checkKomitmenDoneForReminderCard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final komitmenList = await ApiService.getKomitmen(context);
      print('HEI Komitmen List: $komitmenList');
      final todayStr = GlobalVariables.today.toIso8601String().substring(0, 10);
      for (final item in komitmenList) {
        final tanggal = item['tanggal']?.toString() ?? '';
        if (tanggal == todayStr) {
          final hariParsed =
              int.tryParse(item['hari']?.toString() ?? '') ?? day;
          if (!mounted) break;
          setState(() {
            komitmenDay = tanggal;
            day = hariParsed;
          });
          print('HEI komitmen for today: hari=$day, tanggal=$tanggal');
          break;
        }
      }
    } catch (e) {
      print('❌ HEI Gagal memuat daftar komitmen untuk menentukan day: $e');
    }
    try {
      final komitmenProgress = await ApiService.getKomitmenByPesertaByDay(
        context,
        _dataUser['id'],
        day,
      );
      if (!mounted) return;
      setState(() {
        // Ambil status komitmen dari response
        final dataKomitmen = komitmenProgress['success'] ?? false;
        _komitmenDone = dataKomitmen;
        print('HEI Status komitmen: $_komitmenDone');
        _isLoading = false;
      });
    } catch (e) {
      print('❌HEI Gagal memuat progress komitmen: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> checkStatusDatang() async {
    if (!mounted) return;
    setState(() {});
    print('Checking status datang... $statusDatang');
    try {
      final res = await ApiService.getStatusDatang(
        context,
        _dataUser['secret'] ?? '',
        _dataUser['email'] ?? '',
      );
      final statusDatangApi = res['data']?['status_datang']?.toString() ?? '';
      final prefs = await SharedPreferences.getInstance();

      if (mounted) {
        setState(() {
          _dataUser['status_datang'] = statusDatangApi.toString();
          prefs.setString('status_datang', statusDatangApi.toString());
          statusDatang = statusDatangApi.toString();
          print(
            'Status datang checked and replaced: $_dataUser[status_datang] | $statusDatangApi',
          );
        });
      }
    } catch (e) {
      print('❌ Gagal memuat status datang: $e');
    }
    if (!mounted) return;
    setState(() {});
  }

  // ini adalah notifikasi pasti yaitu:
  // 1. Notifikasi acara 15 menit sebelum acara hari 1 - 4 (untuk semua role)
  // 2. Notifikasi evaluasi 1 jam setelah acara dimulai hari 1 - 4 (untuk peserta, pembina)
  // 3. Notifikasi evaluasi keseluruhan 1x hari terakhir jam 12 siang (untuk peserta, pembina)
  // 4. Notifikasi komitmen setiap hari tiap jam 21 (untuk peserta)
  // Future<void> setupAllNotification() async {
  //   try {
  //     final notificationService = NotificationService();
  //     await notificationService.initialize();
  //     // Pastikan semua key notif di SharedPreferences diset ke true (default: nyala)
  //     final prefs = await SharedPreferences.getInstance();
  //     try {
  //       // Cari semua key yang kemungkinan terkait notifikasi
  //       final notifKeys =
  //           prefs.getKeys().where((k) {
  //             final lower = k.toLowerCase();
  //             return lower.startsWith('notif') ||
  //                 lower.contains('notif') ||
  //                 lower.contains('notifikasi') ||
  //                 lower.contains('notification');
  //           }).toList();

  //       if (notifKeys.isNotEmpty) {
  //         for (final key in notifKeys) {
  //           await prefs.setBool(key, true);
  //         }
  //         print('SharedPref: set existing notif keys to true -> $notifKeys');
  //       } else {
  //         // Jika tidak ditemukan key notif apapun, set beberapa key default yang umum dipakai
  //         final defaultNotifKeys = <String>[
  //           'notif_acara',
  //           'notif_evaluasi',
  //           'notif_komitmen',
  //           'notif_pengumuman',
  //           'notif_daily_reminder',
  //         ];
  //         for (final key in defaultNotifKeys) {
  //           await prefs.setBool(key, true);
  //         }
  //         print(
  //           'SharedPref: set default notif keys to true -> $defaultNotifKeys',
  //         );
  //       }
  //     } catch (e) {
  //       print('❌ Gagal meng-set default notif di SharedPreferences: $e');
  //     }
  //     print('Notificaton setup completed');
  //   } catch (e) {
  //     print('❌ Error setting up daily notifications: $e');
  //   }
  // }

  DateTime _getNext9AM() {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      9,
      03,
    ); // 09:00

    // Jika sudah lewat jam 9 hari ini, jadwalkan untuk besok
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }

  void _showLocalNotification(RemoteMessage message) {
    const androidDetails = AndroidNotificationDetails(
      'fcm_channel', // id channel
      'FCM Notifications', // nama channel
      importance: Importance.max,
      priority: Priority.high,
    );
    const notifDetails = NotificationDetails(android: androidDetails);

    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Notifikasi',
      message.notification?.body ?? '',
      notifDetails,
    );
  }

  Future<void> saveUserDevice() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // Cek izin notifikasi terlebih dahulu
    bool notificationAllowed = false;
    if (Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);
      notificationAllowed =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      print(
        notificationAllowed
            ? 'User granted permission'
            : 'User declined or has not accepted notification permissions',
      );
    } else if (Platform.isAndroid) {
      try {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        if (deviceInfo.version.sdkInt >= 33) {
          final permission =
              await permission_handler.Permission.notification.request();
          notificationAllowed = permission.isGranted;
          print(
            notificationAllowed
                ? 'Android notification permission granted'
                : 'Android notification permission denied',
          );
        } else {
          // For Android < 13, permission is granted by default
          notificationAllowed = true;
        }
      } catch (e) {
        print('Error requesting Android notification permission: $e');
      }
    }

    if (!notificationAllowed) {
      print('Notifikasi belum diizinkan, tidak menyimpan device.');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Print device info
    final deviceInfoPlugin = DeviceInfoPlugin();
    String deviceModelInfo = '';
    String deviceManufacturerInfo = '';
    String deviceVersionInfo = '';
    String platformInfo = '';
    String fcm_token = '';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceModelInfo = androidInfo.model ?? '';
      deviceManufacturerInfo = androidInfo.manufacturer ?? '';
      deviceVersionInfo = androidInfo.version.release ?? '';
      platformInfo = 'Android';
      print(
        'Device Info (Android): $deviceModelInfo, $deviceManufacturerInfo, $deviceVersionInfo',
      );
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceModelInfo = iosInfo.utsname.machine ?? '';
      deviceManufacturerInfo = iosInfo.name ?? '';
      deviceVersionInfo = iosInfo.systemVersion ?? '';
      platformInfo = 'iOS';
      print(
        'Device Info (iOS): $deviceModelInfo, $deviceVersionInfo, $deviceManufacturerInfo',
      );
    }

    if (Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        fcm_token = await FirebaseMessaging.instance.getToken() ?? '';
        print('FCM Token (Ios): $fcm_token');
      }
    } else if (Platform.isAndroid) {
      fcm_token = await FirebaseMessaging.instance.getToken() ?? '';
      print('FCM Token (Android): $fcm_token');
    }

    try {
      final result = await ApiService.saveUserDevice(
        userId: prefs.getInt('id')?.toString() ?? '',
        username: prefs.getString('username') ?? '',
        fcmToken: fcm_token,
        platform: platformInfo,
        deviceModel: deviceModelInfo,
        deviceManufacturer: deviceManufacturerInfo,
        deviceVersion: deviceVersionInfo,
      );
      setState(() {
        print('saveUserDevice result: $result');
      });
    } catch (e) {
      setState(() {
        print('Error saving user device: $e');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _acaraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _lastBackPressed = null;
    final userId = _dataUser['id'] ?? '-';
    final role = _dataUser['role'] ?? '-';
    final nama = _dataUser['nama'] ?? '-';
    final kelompok = _dataUser['kelompok_nama'] ?? '-';
    final status_datang = _dataUser['status_datang'] ?? '-';
    print(' AAAAA Status Datang: $status_datang');
    final kamar = _dataUser['kamar'] ?? '-';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          final now = DateTime.now();
          if (_lastBackPressed == null ||
              now.difference(_lastBackPressed!) > Duration(seconds: 5)) {
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
                'assets/images/background_dashboard.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.fill,
              ),
            ),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () {
                  print('Refreshed');
                  return initAll(forceRefresh: true);
                },
                color: AppColors.brown1,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 96.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 24),
                        //   child: Column(
                        //     children: [
                        //       Align(
                        //         alignment: Alignment.topRight,
                        //         child: Image.asset(
                        //           'assets/buttons/hamburger_white.png',
                        //           height: 48,
                        //           width: 48,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset('assets/texts/hello.png', height: 72),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // kartu alert registrasi ulang
                        status_datang == "0"
                            ? AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 400),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        // Navigasi ke halaman edit profil
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    ProfileEditScreen(),
                                          ),
                                        ).then((result) {
                                          if (result == 'reload') {
                                            print('Refreshed');
                                            initAll(forceRefresh: true);
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.warning_amber_rounded,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                "Kamu belum melakukan konfirmasi registrasi ulang. Segera konfirmasi ke pembimbing kelompokmu!",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            )
                            : const SizedBox.shrink(),

                        // Pembina Pembimbing Card
                        if (role.toLowerCase().contains('pembina') == true ||
                            role.toLowerCase().contains('pembimbing') == true ||
                            role.toLowerCase().contains('peserta') == true)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    setState(() {
                                      GlobalVariables.currentIndex = 2;
                                    });
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
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 180,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                              'assets/images/card_dashboard_role.png',
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16.0,
                                              bottom: 16.0,
                                              left: 48,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  (_dataUser['role']
                                                              ?.toLowerCase()
                                                              .contains(
                                                                'pembimbing',
                                                              ) ==
                                                          true)
                                                      ? 'Pembimbing'
                                                      : (_dataUser['role']
                                                              ?.toLowerCase()
                                                              .contains(
                                                                'pembina',
                                                              ) ==
                                                          true)
                                                      ? 'Pembina'
                                                      : (_dataUser['role']
                                                              ?.toLowerCase()
                                                              .contains(
                                                                'peserta',
                                                              ) ==
                                                          true)
                                                      ? 'Peserta'
                                                      : '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                                Text(
                                                  (_dataUser['role']
                                                              ?.toLowerCase()
                                                              .contains(
                                                                'pembimbing',
                                                              ) ==
                                                          true)
                                                      ? '${_dataUser['kelompok_nama'] ?? ''}'
                                                      : (_dataUser['role']
                                                              ?.toLowerCase()
                                                              .contains(
                                                                'pembina',
                                                              ) ==
                                                          true)
                                                      ? '${_dataUser['gereja_nama'] ?? ''}'
                                                      : (_dataUser['role']
                                                              ?.toLowerCase()
                                                              .contains(
                                                                'peserta',
                                                              ) ==
                                                          true)
                                                      ? '${nama} \n Kelompok: ${kelompok} \n ${kamar}'
                                                      : '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (role.toLowerCase().contains('pembina') == true ||
                            role.toLowerCase().contains('pembimbing') == true ||
                            role.toLowerCase().contains('peserta') == true)
                          const SizedBox(height: 24),

                        // Komitmen Card untuk Peserta
                        // Card ini muncul di jam 21 - 00
                        // Tampilkan Komitmen Card hanya jika:
                        // - BUKAN panitia, pembimbing, pembina
                        // - day antara 1 sampai 3 (inklusif)
                        // Komitmen Cards (3 duplicated cards with cross-midnight windows)
                        if (!role.toLowerCase().contains('panitia') &&
                            !role.toLowerCase().contains('pembimbing') &&
                            !role.toLowerCase().contains('pembina')) ...[
                          // Kartu 1: day 1 hour 21 - 24 AND day 2 hour 0 - 15 (targetDay = 1)
                          if ((day == 1 &&
                                  _timeOfDay.hour >= 21 &&
                                  _timeOfDay.hour < 24) ||
                              (day == 2 &&
                                  _timeOfDay.hour >= 0 &&
                                  _timeOfDay.hour < 15))
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final targetDay = 1;
                                      final now = DateTime(
                                        GlobalVariables.today.year,
                                        GlobalVariables.today.month,
                                        GlobalVariables.today.day,
                                        GlobalVariables.timeOfDay.hour,
                                        GlobalVariables.timeOfDay.minute,
                                      );

                                      // compute aksesTime based on offset between targetDay and current day variable
                                      final int deltaDays = targetDay - day;
                                      final aksesDateBase = GlobalVariables
                                          .today
                                          .add(Duration(days: deltaDays));
                                      final aksesTime = DateTime(
                                        aksesDateBase.year,
                                        aksesDateBase.month,
                                        aksesDateBase.day,
                                        15,
                                        0,
                                      );

                                      if (now.isBefore(aksesTime)) {
                                        showCustomSnackBar(
                                          context,
                                          'Tidak bisa akses komitmen sebelum ${DateFormatter.ubahTanggal(aksesTime.toIso8601String().substring(0, 10))} pukul 15:00',
                                        );
                                        return;
                                      }

                                      try {
                                        final komitmenProgress =
                                            await ApiService.getKomitmenByPesertaByDay(
                                              context,
                                              userId,
                                              targetDay,
                                            );
                                        final done =
                                            komitmenProgress['success'] ??
                                            false;
                                        if (done) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      EvaluasiKomitmenViewScreen(
                                                        type: 'Komitmen',
                                                        userId: userId,
                                                        acaraHariId: targetDay,
                                                      ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      FormKomitmenScreen(
                                                        userId: userId,
                                                        acaraHariId: targetDay,
                                                      ),
                                            ),
                                          ).then((result) {
                                            if (result == 'reload') {
                                              initAll(forceRefresh: true);
                                            }
                                          });
                                        }
                                      } catch (e) {
                                        showCustomSnackBar(
                                          context,
                                          'Gagal memeriksa status komitmen. Coba lagi.',
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 180,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                'assets/images/card_dashboard_komitmen.png',
                                              ),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 16.0,
                                                        bottom: 16.0,
                                                        left: 64,
                                                      ),
                                                  child: Text(
                                                    _komitmenDone
                                                        ? 'Terima kasih telah mengisi komitmen hari ini!'
                                                        : 'Jangan lupa mengisi komitmen harianmu!',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (_komitmenDone)
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        16,
                                                      ),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                    ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              child: Row(
                                                children: const [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Selesai',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topRight: Radius.circular(
                                                      16,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      8,
                                                    ),
                                                  ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              DateFormatter.ubahTanggal(
                                                GlobalVariables.today
                                                    .toIso8601String()
                                                    .substring(0, 10),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),

                          // Kartu 2: day 2 hour 21 - 24 AND day 3 hour 0 - 15 (targetDay = 2)
                          if ((day == 2 &&
                                  _timeOfDay.hour >= 21 &&
                                  _timeOfDay.hour < 24) ||
                              (day == 3 &&
                                  _timeOfDay.hour >= 0 &&
                                  _timeOfDay.hour < 15))
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final targetDay = 2;
                                      final now = DateTime(
                                        GlobalVariables.today.year,
                                        GlobalVariables.today.month,
                                        GlobalVariables.today.day,
                                        GlobalVariables.timeOfDay.hour,
                                        GlobalVariables.timeOfDay.minute,
                                      );

                                      final int deltaDays = targetDay - day;
                                      final aksesDateBase = GlobalVariables
                                          .today
                                          .add(Duration(days: deltaDays));
                                      final aksesTime = DateTime(
                                        aksesDateBase.year,
                                        aksesDateBase.month,
                                        aksesDateBase.day,
                                        15,
                                        0,
                                      );

                                      if (now.isBefore(aksesTime)) {
                                        showCustomSnackBar(
                                          context,
                                          'Tidak bisa akses komitmen sebelum ${DateFormatter.ubahTanggal(aksesTime.toIso8601String().substring(0, 10))} pukul 15:00',
                                        );
                                        return;
                                      }

                                      try {
                                        final komitmenProgress =
                                            await ApiService.getKomitmenByPesertaByDay(
                                              context,
                                              userId,
                                              targetDay,
                                            );
                                        final done =
                                            komitmenProgress['success'] ??
                                            false;
                                        if (done) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      EvaluasiKomitmenViewScreen(
                                                        type: 'Komitmen',
                                                        userId: userId,
                                                        acaraHariId: targetDay,
                                                      ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      FormKomitmenScreen(
                                                        userId: userId,
                                                        acaraHariId: targetDay,
                                                      ),
                                            ),
                                          ).then((result) {
                                            if (result == 'reload') {
                                              initAll(forceRefresh: true);
                                            }
                                          });
                                        }
                                      } catch (e) {
                                        showCustomSnackBar(
                                          context,
                                          'Gagal memeriksa status komitmen. Coba lagi.',
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 180,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                'assets/images/card_dashboard_komitmen.png',
                                              ),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 16.0,
                                                        bottom: 16.0,
                                                        left: 64,
                                                      ),
                                                  child: Text(
                                                    _komitmenDone
                                                        ? 'Terima kasih telah mengisi komitmen hari ini!'
                                                        : 'Jangan lupa mengisi komitmen harianmu!',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (_komitmenDone)
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        16,
                                                      ),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                    ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              child: Row(
                                                children: const [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Selesai',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topRight: Radius.circular(
                                                      16,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      8,
                                                    ),
                                                  ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              DateFormatter.ubahTanggal(
                                                GlobalVariables.today
                                                    .toIso8601String()
                                                    .substring(0, 10),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),

                          // Kartu 3: day 3 hour 21 - 24 AND day 4 hour 0 - 15 (targetDay = 3)
                          if ((day == 3 &&
                                  _timeOfDay.hour >= 21 &&
                                  _timeOfDay.hour < 24) ||
                              (GlobalVariables.today.year == 2026 &&
                                  GlobalVariables.today.month == 1 &&
                                  GlobalVariables.today.day == 2 &&
                                  _timeOfDay.hour >= 0 &&
                                  _timeOfDay.hour < 15))
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final targetDay = 3;
                                      final now = DateTime(
                                        GlobalVariables.today.year,
                                        GlobalVariables.today.month,
                                        GlobalVariables.today.day,
                                        GlobalVariables.timeOfDay.hour,
                                        GlobalVariables.timeOfDay.minute,
                                      );

                                      final int deltaDays = targetDay - day;
                                      final aksesDateBase = GlobalVariables
                                          .today
                                          .add(Duration(days: deltaDays));
                                      final aksesTime = DateTime(
                                        aksesDateBase.year,
                                        aksesDateBase.month,
                                        aksesDateBase.day,
                                        15,
                                        0,
                                      );

                                      if (now.isBefore(aksesTime)) {
                                        showCustomSnackBar(
                                          context,
                                          'Tidak bisa akses komitmen sebelum ${DateFormatter.ubahTanggal(aksesTime.toIso8601String().substring(0, 10))} pukul 15:00',
                                        );
                                        return;
                                      }

                                      try {
                                        final komitmenProgress =
                                            await ApiService.getKomitmenByPesertaByDay(
                                              context,
                                              userId,
                                              targetDay,
                                            );
                                        final done =
                                            komitmenProgress['success'] ??
                                            false;
                                        if (done) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      EvaluasiKomitmenViewScreen(
                                                        type: 'Komitmen',
                                                        userId: userId,
                                                        acaraHariId: targetDay,
                                                      ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      FormKomitmenScreen(
                                                        userId: userId,
                                                        acaraHariId: targetDay,
                                                      ),
                                            ),
                                          ).then((result) {
                                            if (result == 'reload') {
                                              initAll(forceRefresh: true);
                                            }
                                          });
                                        }
                                      } catch (e) {
                                        showCustomSnackBar(
                                          context,
                                          'Gagal memeriksa status komitmen. Coba lagi.',
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 180,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                'assets/images/card_dashboard_komitmen.png',
                                              ),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 16.0,
                                                        bottom: 16.0,
                                                        left: 64,
                                                      ),
                                                  child: Text(
                                                    _komitmenDone
                                                        ? 'Terima kasih telah mengisi komitmen hari ini!'
                                                        : 'Jangan lupa mengisi komitmen harianmu!',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (_komitmenDone)
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        16,
                                                      ),
                                                      bottomRight:
                                                          Radius.circular(8),
                                                    ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              child: Row(
                                                children: const [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Selesai',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topRight: Radius.circular(
                                                      16,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      8,
                                                    ),
                                                  ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              DateFormatter.ubahTanggal(
                                                GlobalVariables.today
                                                    .toIso8601String()
                                                    .substring(0, 10),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                        ],

                        // if ((day >= 1 && day <= 3) &&
                        //     !role.toLowerCase().contains('panitia') &&
                        //     !role.toLowerCase().contains('pembimbing') &&
                        //     !role.toLowerCase().contains('pembina') &&
                        //     (_timeOfDay.hour >= 20 && _timeOfDay.hour < 24))
                        //   const SizedBox(height: 24),

                        // Notifikasi
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 24),
                        //   child: Column(
                        //     children: [
                        //       // Test Notification Button
                        //       SizedBox(
                        //         width: double.infinity,
                        //         child: ElevatedButton.icon(
                        //           onPressed: () {
                        //             print('🔔 Test Notification Button Pressed');
                        //             print('🔔 Test Notification Button Pressed');
                        //             print('Datetime now: ${DateTime.now()}');
                        //             NotificationService().showNotification(
                        //               title: 'Test Notification',
                        //               body:
                        //                   'This is a text notification from SYC App.',
                        //               payload: 'splash',
                        //             );
                        //           },
                        //           icon: const Icon(Icons.notifications, size: 16),
                        //           label: const Text('Test Notifications'),
                        //           style: ElevatedButton.styleFrom(
                        //             backgroundColor: AppColors.secondary,
                        //             foregroundColor: Colors.white,
                        //             padding: const EdgeInsets.symmetric(
                        //               vertical: 12,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       const SizedBox(height: 12),
                        //       // Schedule Notification Button (5s)
                        //       SizedBox(
                        //         width: double.infinity,
                        //         child: ElevatedButton.icon(
                        //           onPressed: () {
                        //             NotificationService().scheduledNotification(
                        //               title:
                        //                   'Scheduled Notification: 5 seconds later',
                        //               body:
                        //                   'This notification is scheduled for 5 seconds later.',
                        //               scheduledTime: DateTime.now().add(
                        //                 const Duration(seconds: 5),
                        //               ),
                        //               payload: 'splash',
                        //             );
                        //           },
                        //           icon: const Icon(Icons.schedule, size: 16),
                        //           label: const Text(
                        //             'Schedule Notification: 5 Later',
                        //           ),
                        //           style: ElevatedButton.styleFrom(
                        //             backgroundColor: AppColors.secondary,
                        //             foregroundColor: Colors.white,
                        //             padding: const EdgeInsets.symmetric(
                        //               vertical: 12,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       const SizedBox(height: 12),
                        //       // Schedule Notification Button (9 July 2025 07:40 WIB)
                        //       SizedBox(
                        //         width: double.infinity,
                        //         child: ElevatedButton.icon(
                        //           onPressed: () {
                        //             // 07:40 WIB = UTC+7
                        //             final scheduledTime = DateTime.utc(
                        //               2025,
                        //               7,
                        //               14,
                        //               6,
                        //               26,
                        //             );
                        //             NotificationService().scheduledNotification(
                        //               title: 'Notifikasi Terjadwal',
                        //               body:
                        //                   'Ini notifikasi untuk 14 Juli 2025 jam 13.26 WIB.',
                        //               scheduledTime: scheduledTime,
                        //               payload: 'splash',
                        //             );
                        //             showCustomSnackBar(
                        //               context,
                        //               'Notifikasi berhasil dijadwalkan pada ${scheduledTime.toLocal()}',
                        //             );
                        //           },
                        //           icon: const Icon(Icons.schedule_send, size: 16),
                        //           label: const Text(
                        //             'Schedule Notif 14 Juli 2025 13.26 WIB',
                        //           ),
                        //           style: ElevatedButton.styleFrom(
                        //             backgroundColor: AppColors.secondary,
                        //             foregroundColor: Colors.white,
                        //             padding: const EdgeInsets.symmetric(
                        //               vertical: 12,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 16),
                        // if (day >= 1 && day <= 4) const SizedBox(height: 24),

                        // // Acara Mendatang (batasi sampai hari ke-4, hari 99 gausah)
                        // if (day >= 1 && day <= 4)
                        //   _isLoading
                        //       ? buildAcaraShimmer()
                        //       : _acaraList.isEmpty
                        //       ? Center(
                        //         child: const CustomNotFound(
                        //           text: "Gagal memuat data acara mendatang :(",
                        //           textColor: AppColors.brown1,
                        //           imagePath: 'assets/images/data_not_found.png',
                        //         ),
                        //       )
                        //       : Padding(
                        //         padding: const EdgeInsets.only(left: 24),
                        //         child: Container(
                        //           decoration: const BoxDecoration(
                        //             color: AppColors.grey1, // abu-abu muda
                        //             borderRadius: BorderRadius.only(
                        //               topLeft: Radius.circular(24),
                        //               bottomLeft: Radius.circular(24),
                        //             ),
                        //           ),
                        //           padding: const EdgeInsets.all(16.0),
                        //           child: Column(
                        //             crossAxisAlignment: CrossAxisAlignment.start,
                        //             children: [
                        //               InkWell(
                        //                 onTap: () {
                        //                   setState(() {
                        //                     GlobalVariables.currentIndex = 1;
                        //                   });
                        //                   Navigator.push(
                        //                     context,
                        //                     MaterialPageRoute(builder: (context) => const MainScreen()),
                        //                   );
                        //                 },
                        //                 borderRadius: BorderRadius.circular(8),
                        //                 child: Row(
                        //                   children: [
                        //                     Padding(
                        //                       padding: const EdgeInsets.only(left: 8.0),
                        //                       child: Text(
                        //                         'Acara Mendatang',
                        //                         style: TextStyle(
                        //                           fontSize: 24,
                        //                           fontWeight: FontWeight.w900,
                        //                           color: AppColors.brown1,
                        //                         ),
                        //                       ),
                        //                     ),
                        //                     const Spacer(),
                        //                     const Icon(Icons.arrow_forward_ios, color: AppColors.black1),
                        //                   ],
                        //                 ),
                        //               ),
                        //               const SizedBox(height: 8),
                        //               SizedBox(
                        //                 height: 160,
                        //                 child: ListView.builder(
                        //                   controller: _acaraController,
                        //                   scrollDirection: Axis.horizontal,
                        //                   itemCount: countAcara,
                        //                   itemBuilder: (context, index) {
                        //                     return Padding(
                        //                       padding: const EdgeInsets.only(right: 8.0),
                        //                       child: GestureDetector(
                        //                         onTap: () {
                        //                           Navigator.push(
                        //                             context,
                        //                             MaterialPageRoute(
                        //                               builder:
                        //                                   (context) => DetailAcaraScreen(
                        //                                     id: _acaraList[index]["id"].toString(),
                        //                                     userId: userId,
                        //                                   ),
                        //                             ),
                        //                           );
                        //                         },
                        //                         child: Padding(
                        //                           padding: const EdgeInsets.all(8.0),
                        //                           child: Stack(
                        //                             clipBehavior: Clip.none,
                        //                             children: [
                        //                               Container(
                        //                                 height: 160,
                        //                                 width: 160,
                        //                                 decoration: BoxDecoration(
                        //                                   color: Colors.white,
                        //                                   borderRadius: const BorderRadius.only(
                        //                                     bottomRight: Radius.circular(16),
                        //                                     topLeft: Radius.circular(16),
                        //                                     bottomLeft: Radius.circular(16),
                        //                                     topRight: Radius.circular(16),
                        //                                   ),
                        //                                   image: DecorationImage(
                        //                                     image: () {
                        //                                       final acara = _acaraList[index];
                        //                                       final nama = acara['acara_nama']?.toString() ?? '';
                        //                                       if (nama == 'Pendaftaran Ulang dan Kedatangan') {
                        //                                         return Image.asset('assets/mockups/daftar.jpg').image;
                        //                                       } else if (nama == 'Opening') {
                        //                                         return Image.asset('assets/mockups/opening.jpg').image;
                        //                                       } else if (nama == 'KKR 1') {
                        //                                         return Image.asset('assets/mockups/kkr1.jpg').image;
                        //                                       } else if (nama == 'KKR 2') {
                        //                                         return Image.asset('assets/mockups/kkr2.jpg').image;
                        //                                       } else if (nama == 'KKR 3') {
                        //                                         return Image.asset('assets/mockups/kkr3.jpg').image;
                        //                                       } else if (nama == 'Saat Teduh') {
                        //                                         return Image.asset(
                        //                                           'assets/mockups/saat_teduh1.jpg',
                        //                                         ).image;
                        //                                       } else if (nama == 'Drama Musikal') {
                        //                                         return Image.asset(
                        //                                           'assets/mockups/drama_musikal.jpg',
                        //                                         ).image;
                        //                                       } else if (nama == 'New Year Countdown') {
                        //                                         return Image.asset('assets/mockups/new_year.jpg').image;
                        //                                       } else if (nama == 'Closing') {
                        //                                         return Image.asset('assets/mockups/closing.jpg').image;
                        //                                       } else {
                        //                                         return Image.asset('assets/images/event.jpg').image;
                        //                                       }
                        //                                     }(),
                        //                                     fit: BoxFit.cover,
                        //                                   ),
                        //                                 ),
                        //                                 child: Stack(
                        //                                   children: [
                        //                                     // Gradient overlay
                        //                                     Container(
                        //                                       decoration: BoxDecoration(
                        //                                         gradient: LinearGradient(
                        //                                           begin: Alignment.bottomCenter,
                        //                                           end: Alignment.center,
                        //                                           colors: [
                        //                                             Colors.black.withAlpha(100),
                        //                                             Colors.black.withAlpha(10),
                        //                                           ],
                        //                                         ),
                        //                                         borderRadius: const BorderRadius.only(
                        //                                           bottomRight: Radius.circular(16),
                        //                                           topLeft: Radius.circular(16),
                        //                                           bottomLeft: Radius.circular(16),
                        //                                           topRight: Radius.circular(16),
                        //                                         ),
                        //                                       ),
                        //                                     ),
                        //                                     Padding(
                        //                                       padding: const EdgeInsets.only(
                        //                                         left: 8,
                        //                                         right: 8,
                        //                                         bottom: 8,
                        //                                       ),
                        //                                       child: Align(
                        //                                         alignment: Alignment.bottomLeft,
                        //                                         child: Column(
                        //                                           crossAxisAlignment: CrossAxisAlignment.start,
                        //                                           mainAxisAlignment: MainAxisAlignment.end,
                        //                                           children: [
                        //                                             Flexible(
                        //                                               child: Text(
                        //                                                 _acaraList[index]['acara_nama'] ??
                        //                                                     // 'Acara ${index + 1}???',
                        //                                                     '',
                        //                                                 textAlign: TextAlign.left,
                        //                                                 style: const TextStyle(
                        //                                                   fontSize: 18,
                        //                                                   fontWeight: FontWeight.w900,
                        //                                                   color: Colors.white,
                        //                                                   overflow: TextOverflow.ellipsis,
                        //                                                 ),
                        //                                               ),
                        //                                             ),
                        //                                             Row(
                        //                                               children: [
                        //                                                 const Icon(
                        //                                                   Icons.location_on,
                        //                                                   color: Colors.white,
                        //                                                   size: 12,
                        //                                                 ),
                        //                                                 const SizedBox(width: 4),
                        //                                                 Flexible(
                        //                                                   child: Text(
                        //                                                     _acaraList[index]['tempat'] ?? '',
                        //                                                     style: const TextStyle(
                        //                                                       fontSize: 14,
                        //                                                       color: Colors.white,
                        //                                                       fontWeight: FontWeight.w300,
                        //                                                     ),
                        //                                                     overflow: TextOverflow.ellipsis,
                        //                                                   ),
                        //                                                 ),
                        //                                               ],
                        //                                             ),
                        //                                           ],
                        //                                         ),
                        //                                       ),
                        //                                     ),
                        //                                   ],
                        //                                 ),
                        //                               ),
                        //                               // text waktu
                        //                               Positioned(
                        //                                 top: -5,
                        //                                 right: -5,
                        //                                 child: Card(
                        //                                   color: AppColors.secondary,
                        //                                   shape: const RoundedRectangleBorder(
                        //                                     borderRadius: BorderRadius.only(
                        //                                       bottomLeft: Radius.circular(16),
                        //                                       topRight: Radius.circular(16),
                        //                                     ),
                        //                                   ),
                        //                                   elevation: 0,
                        //                                   child: SizedBox(
                        //                                     width: 72,
                        //                                     height: 36,
                        //                                     child: Center(
                        //                                       child: Row(
                        //                                         mainAxisAlignment: MainAxisAlignment.center,
                        //                                         children: [
                        //                                           const Icon(
                        //                                             Icons.access_time_filled_rounded,
                        //                                             color: AppColors.primary,
                        //                                             size: 16,
                        //                                           ),
                        //                                           const SizedBox(width: 4),
                        //                                           Text(
                        //                                             _acaraList[index]['waktu'] ?? '',
                        //                                             style: const TextStyle(
                        //                                               color: AppColors.primary,
                        //                                               fontWeight: FontWeight.bold,
                        //                                               fontSize: 12,
                        //                                             ),
                        //                                             textAlign: TextAlign.center,
                        //                                           ),
                        //                                         ],
                        //                                       ),
                        //                                     ),
                        //                                   ),
                        //                                 ),
                        //                               ),
                        //                               // text nama acara dan tempat
                        //                               // Positioned(
                        //                               //   bottom: -5,
                        //                               //   right: -5,
                        //                               //   left: -5,
                        //                               //   child: Card(
                        //                               //     color: Colors.white,
                        //                               //     shape: const RoundedRectangleBorder(
                        //                               //       borderRadius:
                        //                               //           BorderRadius.only(
                        //                               //             bottomLeft:
                        //                               //                 Radius.circular(
                        //                               //                   16,
                        //                               //                 ),
                        //                               //             bottomRight:
                        //                               //                 Radius.circular(
                        //                               //                   16,
                        //                               //                 ),
                        //                               //           ),
                        //                               //     ),
                        //                               //     elevation: 0,
                        //                               //     child: SizedBox(
                        //                               //       width: 72,
                        //                               //       height: 48,
                        //                               //       child: Center(
                        //                               //         child: Padding(
                        //                               //           padding:
                        //                               //               const EdgeInsets.all(
                        //                               //                 8.0,
                        //                               //               ),
                        //                               //           child: Align(
                        //                               //             alignment:
                        //                               //                 Alignment
                        //                               //                     .bottomLeft,
                        //                               //             child: Column(
                        //                               //               crossAxisAlignment:
                        //                               //                   CrossAxisAlignment
                        //                               //                       .start,
                        //                               //               mainAxisAlignment:
                        //                               //                   MainAxisAlignment
                        //                               //                       .end,
                        //                               //               children: [
                        //                               //                 Flexible(
                        //                               //                   child: Text(
                        //                               //                     _acaraList[index]['acara_nama'] ??
                        //                               //                         'Acara ${index + 1}???',
                        //                               //                     textAlign:
                        //                               //                         TextAlign
                        //                               //                             .left,
                        //                               //                     style: const TextStyle(
                        //                               //                       fontSize:
                        //                               //                           12,
                        //                               //                       fontWeight:
                        //                               //                           FontWeight.w900,
                        //                               //                       color:
                        //                               //                           AppColors.primary,
                        //                               //                       overflow:
                        //                               //                           TextOverflow.ellipsis,
                        //                               //                     ),
                        //                               //                   ),
                        //                               //                 ),
                        //                               //                 Row(
                        //                               //                   children: [
                        //                               //                     const Icon(
                        //                               //                       Icons
                        //                               //                           .location_on,
                        //                               //                       color:
                        //                               //                           AppColors.primary,
                        //                               //                       size:
                        //                               //                           10,
                        //                               //                     ),
                        //                               //                     const SizedBox(
                        //                               //                       width:
                        //                               //                           4,
                        //                               //                     ),
                        //                               //                     Flexible(
                        //                               //                       child: Text(
                        //                               //                         _acaraList[index]['tempat'] ??
                        //                               //                             '',
                        //                               //                         style: const TextStyle(
                        //                               //                           fontSize:
                        //                               //                               10,
                        //                               //                           color:
                        //                               //                               AppColors.primary,
                        //                               //                           fontWeight:
                        //                               //                               FontWeight.w300,
                        //                               //                         ),
                        //                               //                         overflow:
                        //                               //                             TextOverflow.ellipsis,
                        //                               //                       ),
                        //                               //                     ),
                        //                               //                   ],
                        //                               //                 ),
                        //                               //               ],
                        //                               //             ),
                        //                               //           ),
                        //                               //         ),
                        //                               //       ),
                        //                               //     ),
                        //                               //   ),
                        //                               // ),
                        //                             ],
                        //                           ),
                        //                         ),
                        //                       ),
                        //                     );
                        //                   },
                        //                 ),
                        //               ),
                        //               const SizedBox(height: 16),

                        //               if (countAcara > 1)
                        //                 Center(
                        //                   child: Row(
                        //                     mainAxisAlignment: MainAxisAlignment.center,
                        //                     children: List.generate(countAcara, (index) {
                        //                       return AnimatedContainer(
                        //                         duration: const Duration(milliseconds: 300),
                        //                         margin: const EdgeInsets.symmetric(horizontal: 4),
                        //                         width: _currentAcaraPage == index ? 16 : 8,
                        //                         height: 8,
                        //                         decoration: BoxDecoration(
                        //                           color: _currentAcaraPage == index ? AppColors.primary : Colors.grey,
                        //                           borderRadius: BorderRadius.circular(4),
                        //                         ),
                        //                       );
                        //                     }),
                        //                   ),
                        //                 ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),

                        // Bacaan Hari Ini (BRM)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child:
                              _isLoadingBrm
                                  ? buildBrmShimmer()
                                  : _dataBrm.isEmpty
                                  ? Center(
                                    child: const CustomNotFound(
                                      text: "Gagal memuat data brm hari ini :(",
                                      textColor: AppColors.brown1,
                                      imagePath:
                                          'assets/images/data_not_found.png',
                                    ),
                                  )
                                  : Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      BibleReadingMoreScreen(
                                                        userId: userId,
                                                        date: DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          DateTime.now().day,
                                                        ),
                                                      ),
                                            ),
                                          ).then((result) {
                                            if (result == 'reload') {
                                              initAll(
                                                forceRefresh: true,
                                              ); // reload dashboard
                                            }
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: 180,
                                              padding: const EdgeInsets.only(
                                                left: 24,
                                                right: 24,
                                                bottom: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withAlpha(70),
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.center,
                                                  colors: [
                                                    Colors.black.withAlpha(100),
                                                    Colors.black.withAlpha(10),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                image: const DecorationImage(
                                                  image: AssetImage(
                                                    'assets/mockups/bible_reading.jpg',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    if (_dataBrm
                                                        .isNotEmpty) ...[
                                                      Text(
                                                        'Bacaan Hari Ini',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        _dataBrm[0]['passage'] ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      const Text(
                                                        "Tidak ada data BRM hari ini",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (_dataBrm[0]['read']
                                                    .toString() ==
                                                "1")
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                16,
                                                              ),
                                                          bottomRight:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  child: Row(
                                                    children: const [
                                                      Icon(
                                                        Icons.check_circle,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Sudah dibaca',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.secondary,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(16),
                                                        bottomLeft:
                                                            Radius.circular(8),
                                                      ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                child: Text(
                                                  _dataBrm.isNotEmpty
                                                      ? DateFormatter.ubahTanggal(
                                                        _dataBrm[0]['tanggal'],
                                                      )
                                                      : '',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                        if (acaraStatisHari1.isNotEmpty &&
                                _today == acaraStatisHari1[0]["tanggal"] ||
                            acaraStatisHari2.isNotEmpty &&
                                _today == acaraStatisHari2[0]["tanggal"] ||
                            acaraStatisHari3.isNotEmpty &&
                                _today == acaraStatisHari3[0]["tanggal"] ||
                            acaraStatisHari4.isNotEmpty &&
                                _today == acaraStatisHari4[0]["tanggal"])
                          const SizedBox(height: 24),
                        // Acara Statis Hari ke 1: tampilkan hanya jika _today == acaraStatisHari1[0]["tanggal"]
                        if (acaraStatisHari1.isNotEmpty &&
                            _today == acaraStatisHari1[0]["tanggal"])
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.grey1, // abu-abu muda
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                ),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        GlobalVariables.currentIndex = 1;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const MainScreen(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: Text(
                                            'Acara Hari ke-1',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.brown1,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: AppColors.black1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Filter acaraStatisHari1 agar hanya menampilkan acara yang waktu-nya belum lewat
                                  Builder(
                                    builder: (context) {
                                      final now = _timeOfDay;
                                      // Filter acara yang waktu-nya >= sekarang
                                      final filteredAcara =
                                          acaraStatisHari1.where((acara) {
                                            final waktu = acara['waktu'];
                                            TimeOfDay? acaraTime;
                                            if (waktu is TimeOfDay) {
                                              acaraTime = waktu;
                                            } else if (waktu is String) {
                                              if (waktu.isEmpty) return false;
                                              final parts = waktu.split(':');
                                              if (parts.length < 2)
                                                return false;
                                              final jam =
                                                  int.tryParse(parts[0]) ?? 0;
                                              final menit =
                                                  int.tryParse(parts[1]) ?? 0;
                                              acaraTime = TimeOfDay(
                                                hour: jam,
                                                minute: menit,
                                              );
                                            } else {
                                              return false;
                                            }
                                            // Tampilkan jika waktu acara >= sekarang
                                            return acaraTime.hour > now.hour ||
                                                (acaraTime.hour == now.hour &&
                                                    acaraTime.minute >=
                                                        now.minute);
                                          }).toList();
                                      if (filteredAcara.isEmpty) {
                                        return Center(
                                          child: CustomNotFound(
                                            text:
                                                "Tidak ada acara mendatang :(",
                                            textColor: AppColors.brown1,
                                            imagePath:
                                                'assets/images/data_not_found.png',
                                          ),
                                        );
                                      }
                                      return SizedBox(
                                        height: 160,
                                        child: ListView.builder(
                                          controller:
                                              _acaraStatisHari1Controller,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: filteredAcara.length,
                                          itemBuilder: (context, index) {
                                            final acara = filteredAcara[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => DetailAcaraScreen(
                                                            id:
                                                                acara["id"]
                                                                    .toString(),
                                                            userId: userId,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      Container(
                                                        height: 160,
                                                        width: 160,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: const BorderRadius.only(
                                                            bottomRight:
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
                                                            topRight:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                          image: DecorationImage(
                                                            image: AssetImage(
                                                              acara['gambar'] ??
                                                                  'assets/images/event.jpg',
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            // Gradient overlay
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  begin:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                  end:
                                                                      Alignment
                                                                          .center,
                                                                  colors: [
                                                                    Colors.black
                                                                        .withAlpha(
                                                                          100,
                                                                        ),
                                                                    Colors.black
                                                                        .withAlpha(
                                                                          10,
                                                                        ),
                                                                  ],
                                                                ),
                                                                borderRadius: const BorderRadius.only(
                                                                  bottomRight:
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
                                                                  topRight:
                                                                      Radius.circular(
                                                                        16,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    left: 8,
                                                                    right: 8,
                                                                    bottom: 8,
                                                                  ),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .bottomLeft,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Flexible(
                                                                      child: Text(
                                                                        acara['acara_nama'] ??
                                                                            '',
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w900,
                                                                          color:
                                                                              Colors.white,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .location_on,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              12,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              4,
                                                                        ),
                                                                        Flexible(
                                                                          child: Text(
                                                                            acara['tempat'] ??
                                                                                '',
                                                                            style: const TextStyle(
                                                                              fontSize:
                                                                                  14,
                                                                              color:
                                                                                  Colors.white,
                                                                              fontWeight:
                                                                                  FontWeight.w300,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
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
                                                      // text waktu
                                                      Positioned(
                                                        top: -5,
                                                        right: -5,
                                                        child: Card(
                                                          color:
                                                              AppColors
                                                                  .secondary,
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
                                                            width: 72,
                                                            height: 36,
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .access_time_filled_rounded,
                                                                    color:
                                                                        AppColors
                                                                            .primary,
                                                                    size: 16,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  Text(
                                                                    (acara['waktu']
                                                                            is TimeOfDay
                                                                        ? acara['waktu'].hour.toString().padLeft(
                                                                              2,
                                                                              '0',
                                                                            ) +
                                                                            ':' +
                                                                            acara['waktu'].minute.toString().padLeft(
                                                                              2,
                                                                              '0',
                                                                            )
                                                                        : (acara['waktu']?.toString() ??
                                                                            '')),
                                                                    style: const TextStyle(
                                                                      color:
                                                                          AppColors
                                                                              .primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
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
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),

                        // Acara Statis Hari ke 2: tampilkan hanya jika _today == acaraStatisHari2[0]["tanggal"]
                        if (acaraStatisHari2.isNotEmpty &&
                            _today == acaraStatisHari2[0]["tanggal"])
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.grey1, // abu-abu muda
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                ),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        GlobalVariables.currentIndex = 1;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const MainScreen(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: Text(
                                            'Acara Hari ke-2',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.brown1,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: AppColors.black1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Filter acaraStatisHari2 agar hanya menampilkan acara yang waktu-nya belum lewat
                                  Builder(
                                    builder: (context) {
                                      final now = _timeOfDay;
                                      // Filter acara yang waktu-nya >= sekarang
                                      final filteredAcara =
                                          acaraStatisHari2.where((acara) {
                                            final waktu = acara['waktu'];
                                            TimeOfDay? acaraTime;
                                            if (waktu is TimeOfDay) {
                                              acaraTime = waktu;
                                            } else if (waktu is String) {
                                              if (waktu.isEmpty) return false;
                                              final parts = waktu.split(':');
                                              if (parts.length < 2)
                                                return false;
                                              final jam =
                                                  int.tryParse(parts[0]) ?? 0;
                                              final menit =
                                                  int.tryParse(parts[1]) ?? 0;
                                              acaraTime = TimeOfDay(
                                                hour: jam,
                                                minute: menit,
                                              );
                                            } else {
                                              return false;
                                            }
                                            // Tampilkan jika waktu acara >= sekarang
                                            return acaraTime.hour > now.hour ||
                                                (acaraTime.hour == now.hour &&
                                                    acaraTime.minute >=
                                                        now.minute);
                                          }).toList();
                                      if (filteredAcara.isEmpty) {
                                        return Center(
                                          child: CustomNotFound(
                                            text:
                                                "Tidak ada acara mendatang :(",
                                            textColor: AppColors.brown1,
                                            imagePath:
                                                'assets/images/data_not_found.png',
                                          ),
                                        );
                                      }
                                      return SizedBox(
                                        height: 160,
                                        child: ListView.builder(
                                          controller:
                                              _acaraStatisHari2Controller,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: filteredAcara.length,
                                          itemBuilder: (context, index) {
                                            final acara = filteredAcara[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => DetailAcaraScreen(
                                                            id:
                                                                acara["id"]
                                                                    .toString(),
                                                            userId: userId,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      Container(
                                                        height: 160,
                                                        width: 160,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: const BorderRadius.only(
                                                            bottomRight:
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
                                                            topRight:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                          image: DecorationImage(
                                                            image: AssetImage(
                                                              acara['gambar'] ??
                                                                  'assets/images/event.jpg',
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            // Gradient overlay
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  begin:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                  end:
                                                                      Alignment
                                                                          .center,
                                                                  colors: [
                                                                    Colors.black
                                                                        .withAlpha(
                                                                          100,
                                                                        ),
                                                                    Colors.black
                                                                        .withAlpha(
                                                                          10,
                                                                        ),
                                                                  ],
                                                                ),
                                                                borderRadius: const BorderRadius.only(
                                                                  bottomRight:
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
                                                                  topRight:
                                                                      Radius.circular(
                                                                        16,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    left: 8,
                                                                    right: 8,
                                                                    bottom: 8,
                                                                  ),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .bottomLeft,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Flexible(
                                                                      child: Text(
                                                                        acara['acara_nama'] ??
                                                                            '',
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w900,
                                                                          color:
                                                                              Colors.white,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .location_on,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              12,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              4,
                                                                        ),
                                                                        Flexible(
                                                                          child: Text(
                                                                            acara['tempat'] ??
                                                                                '',
                                                                            style: const TextStyle(
                                                                              fontSize:
                                                                                  14,
                                                                              color:
                                                                                  Colors.white,
                                                                              fontWeight:
                                                                                  FontWeight.w300,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
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
                                                      // text waktu
                                                      Positioned(
                                                        top: -5,
                                                        right: -5,
                                                        child: Card(
                                                          color:
                                                              AppColors
                                                                  .secondary,
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
                                                            width: 72,
                                                            height: 36,
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .access_time_filled_rounded,
                                                                    color:
                                                                        AppColors
                                                                            .primary,
                                                                    size: 16,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  Text(
                                                                    (acara['waktu']
                                                                            is TimeOfDay
                                                                        ? acara['waktu'].hour.toString().padLeft(
                                                                              2,
                                                                              '0',
                                                                            ) +
                                                                            ':' +
                                                                            acara['waktu'].minute.toString().padLeft(
                                                                              2,
                                                                              '0',
                                                                            )
                                                                        : (acara['waktu']?.toString() ??
                                                                            '')),
                                                                    style: const TextStyle(
                                                                      color:
                                                                          AppColors
                                                                              .primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
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
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),

                        // Acara Statis Hari ke 3: tampilkan hanya jika _today == acaraStatisHari3[0]["tanggal"]
                        if (acaraStatisHari3.isNotEmpty &&
                            _today == acaraStatisHari3[0]["tanggal"])
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.grey1, // abu-abu muda
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                ),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        GlobalVariables.currentIndex = 1;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const MainScreen(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: Text(
                                            'Acara Hari ke-3',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.brown1,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: AppColors.black1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Filter acaraStatisHari3 agar hanya menampilkan acara yang waktu-nya belum lewat
                                  Builder(
                                    builder: (context) {
                                      final now = _timeOfDay;
                                      // Filter acara yang waktu-nya >= sekarang
                                      final filteredAcara =
                                          acaraStatisHari3.where((acara) {
                                            final waktu = acara['waktu'];
                                            TimeOfDay? acaraTime;
                                            if (waktu is TimeOfDay) {
                                              acaraTime = waktu;
                                            } else if (waktu is String) {
                                              if (waktu.isEmpty) return false;
                                              final parts = waktu.split(':');
                                              if (parts.length < 2)
                                                return false;
                                              final jam =
                                                  int.tryParse(parts[0]) ?? 0;
                                              final menit =
                                                  int.tryParse(parts[1]) ?? 0;
                                              acaraTime = TimeOfDay(
                                                hour: jam,
                                                minute: menit,
                                              );
                                            } else {
                                              return false;
                                            }
                                            // Tampilkan jika waktu acara >= sekarang
                                            return acaraTime.hour > now.hour ||
                                                (acaraTime.hour == now.hour &&
                                                    acaraTime.minute >=
                                                        now.minute);
                                          }).toList();
                                      if (filteredAcara.isEmpty) {
                                        return Center(
                                          child: CustomNotFound(
                                            text:
                                                "Tidak ada acara mendatang :(",
                                            textColor: AppColors.brown1,
                                            imagePath:
                                                'assets/images/data_not_found.png',
                                          ),
                                        );
                                      }
                                      return SizedBox(
                                        height: 160,
                                        child: ListView.builder(
                                          controller:
                                              _acaraStatisHari3Controller,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: filteredAcara.length,
                                          itemBuilder: (context, index) {
                                            final acara = filteredAcara[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => DetailAcaraScreen(
                                                            id:
                                                                acara["id"]
                                                                    .toString(),
                                                            userId: userId,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      Container(
                                                        height: 160,
                                                        width: 160,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: const BorderRadius.only(
                                                            bottomRight:
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
                                                            topRight:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                          image: DecorationImage(
                                                            image: AssetImage(
                                                              acara['gambar'] ??
                                                                  'assets/images/event.jpg',
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            // Gradient overlay
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  begin:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                  end:
                                                                      Alignment
                                                                          .center,
                                                                  colors: [
                                                                    Colors.black
                                                                        .withAlpha(
                                                                          100,
                                                                        ),
                                                                    Colors.black
                                                                        .withAlpha(
                                                                          10,
                                                                        ),
                                                                  ],
                                                                ),
                                                                borderRadius: const BorderRadius.only(
                                                                  bottomRight:
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
                                                                  topRight:
                                                                      Radius.circular(
                                                                        16,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    left: 8,
                                                                    right: 8,
                                                                    bottom: 8,
                                                                  ),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .bottomLeft,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Flexible(
                                                                      child: Text(
                                                                        acara['acara_nama'] ??
                                                                            '',
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w900,
                                                                          color:
                                                                              Colors.white,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .location_on,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              12,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              4,
                                                                        ),
                                                                        Flexible(
                                                                          child: Text(
                                                                            acara['tempat'] ??
                                                                                '',
                                                                            style: const TextStyle(
                                                                              fontSize:
                                                                                  14,
                                                                              color:
                                                                                  Colors.white,
                                                                              fontWeight:
                                                                                  FontWeight.w300,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
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
                                                      // text waktu
                                                      Positioned(
                                                        top: -5,
                                                        right: -5,
                                                        child: Card(
                                                          color:
                                                              AppColors
                                                                  .secondary,
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
                                                            width: 72,
                                                            height: 36,
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .access_time_filled_rounded,
                                                                    color:
                                                                        AppColors
                                                                            .primary,
                                                                    size: 16,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  Text(
                                                                    (acara['waktu']
                                                                            is TimeOfDay
                                                                        ? acara['waktu'].hour.toString().padLeft(
                                                                              2,
                                                                              '0',
                                                                            ) +
                                                                            ':' +
                                                                            acara['waktu'].minute.toString().padLeft(
                                                                              2,
                                                                              '0',
                                                                            )
                                                                        : (acara['waktu']?.toString() ??
                                                                            '')),
                                                                    style: const TextStyle(
                                                                      color:
                                                                          AppColors
                                                                              .primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
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
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),

                        // Acara Statis Hari ke 4: tampilkan hanya jika _today == acaraStatisHari4[0]["tanggal"]
                        if (acaraStatisHari4.isNotEmpty &&
                            _today == acaraStatisHari4[0]["tanggal"])
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.grey1, // abu-abu muda
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                ),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        GlobalVariables.currentIndex = 1;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const MainScreen(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: Text(
                                            'Acara Hari ke-4',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.brown1,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: AppColors.black1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Filter acaraStatisHari4 agar hanya menampilkan acara yang waktu-nya belum lewat
                                  Builder(
                                    builder: (context) {
                                      final now = _timeOfDay;
                                      // Filter acara yang waktu-nya >= sekarang
                                      final filteredAcara =
                                          acaraStatisHari4.where((acara) {
                                            final waktu = acara['waktu'];
                                            TimeOfDay? acaraTime;
                                            if (waktu is TimeOfDay) {
                                              acaraTime = waktu;
                                            } else if (waktu is String) {
                                              if (waktu.isEmpty) return false;
                                              final parts = waktu.split(':');
                                              if (parts.length < 2)
                                                return false;
                                              final jam =
                                                  int.tryParse(parts[0]) ?? 0;
                                              final menit =
                                                  int.tryParse(parts[1]) ?? 0;
                                              acaraTime = TimeOfDay(
                                                hour: jam,
                                                minute: menit,
                                              );
                                            } else {
                                              return false;
                                            }
                                            // Tampilkan jika waktu acara >= sekarang
                                            return acaraTime.hour > now.hour ||
                                                (acaraTime.hour == now.hour &&
                                                    acaraTime.minute >=
                                                        now.minute);
                                          }).toList();
                                      if (filteredAcara.isEmpty) {
                                        return Center(
                                          child: CustomNotFound(
                                            text:
                                                "Tidak ada acara mendatang :(",
                                            textColor: AppColors.brown1,
                                            imagePath:
                                                'assets/images/data_not_found.png',
                                          ),
                                        );
                                      }
                                      return SizedBox(
                                        height: 160,
                                        child: ListView.builder(
                                          controller:
                                              _acaraStatisHari4Controller,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: filteredAcara.length,
                                          itemBuilder: (context, index) {
                                            final acara = filteredAcara[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => DetailAcaraScreen(
                                                            id:
                                                                acara["id"]
                                                                    .toString(),
                                                            userId: userId,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      Container(
                                                        height: 160,
                                                        width: 160,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: const BorderRadius.only(
                                                            bottomRight:
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
                                                            topRight:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                          image: DecorationImage(
                                                            image: AssetImage(
                                                              acara['gambar'] ??
                                                                  'assets/images/event.jpg',
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            // Gradient overlay
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  begin:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                  end:
                                                                      Alignment
                                                                          .center,
                                                                  colors: [
                                                                    Colors.black
                                                                        .withAlpha(
                                                                          100,
                                                                        ),
                                                                    Colors.black
                                                                        .withAlpha(
                                                                          10,
                                                                        ),
                                                                  ],
                                                                ),
                                                                borderRadius: const BorderRadius.only(
                                                                  bottomRight:
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
                                                                  topRight:
                                                                      Radius.circular(
                                                                        16,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    left: 8,
                                                                    right: 8,
                                                                    bottom: 8,
                                                                  ),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .bottomLeft,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Flexible(
                                                                      child: Text(
                                                                        acara['acara_nama'] ??
                                                                            '',
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w900,
                                                                          color:
                                                                              Colors.white,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .location_on,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              12,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              4,
                                                                        ),
                                                                        Flexible(
                                                                          child: Text(
                                                                            acara['tempat'] ??
                                                                                '',
                                                                            style: const TextStyle(
                                                                              fontSize:
                                                                                  14,
                                                                              color:
                                                                                  Colors.white,
                                                                              fontWeight:
                                                                                  FontWeight.w300,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
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
                                                      // text waktu
                                                      Positioned(
                                                        top: -5,
                                                        right: -5,
                                                        child: Card(
                                                          color:
                                                              AppColors
                                                                  .secondary,
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
                                                            width: 72,
                                                            height: 36,
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .access_time_filled_rounded,
                                                                    color:
                                                                        AppColors
                                                                            .primary,
                                                                    size: 16,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  Text(
                                                                    (acara['waktu']
                                                                            is TimeOfDay
                                                                        ? acara['waktu'].hour.toString().padLeft(
                                                                              2,
                                                                              '0',
                                                                            ) +
                                                                            ':' +
                                                                            acara['waktu'].minute.toString().padLeft(
                                                                              2,
                                                                              '0',
                                                                            )
                                                                        : (acara['waktu']?.toString() ??
                                                                            '')),
                                                                    style: const TextStyle(
                                                                      color:
                                                                          AppColors
                                                                              .primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
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
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        // Pengumuman
                        _isLoadingPengumuman
                            ? buildPengumumanShimmer()
                            : _pengumumanList.isEmpty
                            ? const SizedBox.shrink()
                            : Column(
                              children: [
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 140,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _pengumumanList.length,
                                    itemBuilder: (context, index) {
                                      final pengumuman = _pengumumanList[index];
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      PengumumanListScreen(),
                                            ),
                                          ).then((result) {
                                            if (result == 'reload') {
                                              initAll(forceRefresh: true);
                                            }
                                          });
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary,
                                              ),
                                              padding: const EdgeInsets.all(
                                                16.0,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8,
                                                  right: 128,
                                                  top: 8,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            pengumuman["judul"] ??
                                                                '',
                                                            style: const TextStyle(
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            pengumuman["detail"]
                                                                .replaceAll(
                                                                  RegExp(
                                                                    r'<[^>]*>',
                                                                  ),
                                                                  '',
                                                                )
                                                                .trim(),
                                                            style: const TextStyle(
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                              fontSize: 12,
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: -15,
                                              right: -15,
                                              child: Image.asset(
                                                'assets/images/megaphone.png',
                                                width: 180,
                                                height: 180,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                        // Dokumentasi Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ListTutorialScreen(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 180,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                            'assets/images/card_tutorial.png',
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.secondary,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'Tutorial Aplikasi',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Dokumentasi Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              InkWell(
                                onTap: () async {
                                  const url =
                                      'https://drive.google.com/drive/folders/1J7qIoUL7aI2YGy7tR_ZFQxX-7ylzVZrg?usp=sharing';
                                  final uri = Uri.parse(url);
                                  bool launched = false;
                                  try {
                                    launched = await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } catch (_) {}
                                  if (!launched) {
                                    try {
                                      launched = await launchUrl(
                                        uri,
                                        mode: LaunchMode.platformDefault,
                                      );
                                    } catch (_) {}
                                  }
                                  if (!launched) {
                                    showCustomSnackBar(
                                      context,
                                      'Tidak dapat membuka link. Pastikan ada browser di perangkat Anda.',
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 180,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                            'assets/images/card_dokumentasi.jpg',
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.secondary,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'Dokumentasi Acara',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ],
                                          ),
                                        ),
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
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 96.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                backgroundColor: AppColors.floating_button,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PengumumanListScreen(),
                    ),
                  ).then((result) {
                    if (result == 'reload') {
                      initAll(forceRefresh: true);
                    }
                  });
                },
                child: const Icon(
                  Icons.campaign, // megaphone icon
                  color: AppColors.brown1,
                ),
              ),
              if (_pengumumanList.length > 0)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      _pengumumanList.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildBrmShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    period: const Duration(milliseconds: 800),
    child: Column(
      children: [
        const SizedBox(height: 24),
        Container(
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
      ],
    ),
  );
}

Widget buildAcaraShimmer() {
  return Padding(
    padding: const EdgeInsets.only(left: 24.0),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 800),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.grey1, // abu-abu muda
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 84.0,
                  bottom: 8.0,
                ),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 80, height: 16, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 60, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

Widget buildPengumumanShimmer() {
  return Column(
    children: [
      const SizedBox(height: 24),
      SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                period: const Duration(milliseconds: 800),
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 128,
                          top: 8,
                          bottom: 8,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 180,
                              height: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 120,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 100,
                              height: 16,
                              color: Colors.white,
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
      ),
    ],
  );
}
