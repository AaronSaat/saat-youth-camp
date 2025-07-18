import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/screens/form_komitmen_screen.dart';
import 'package:syc/screens/main_screen.dart';
import 'package:syc/services/notification_service.dart' show NotificationService;
import 'package:syc/services/background_task_service.dart';
import 'package:syc/utils/global_variables.dart';
import 'package:syc/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, LaunchMode, launchUrl;
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_not_found.dart';
import 'daftar_acara_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'package:syc/utils/app_colors.dart';

import 'detail_acara_screen.dart';
import 'bible_reading_more_screen.dart';
import 'evaluasi_komitmen_view_screen.dart';
import 'pengumuman_detail_screen.dart';
import 'pengumuman_list_screen.dart';

import 'package:html/parser.dart' as html_parser;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Static data untuk acara hari ke-1

  String _email = '';
  bool isPanitia = false;
  ScrollController _acaraController = ScrollController();
  int _currentAcaraPage = 0;
  List<dynamic> _acaraList = [];
  List<dynamic> _acaraListAll = [];
  List<dynamic> _komitmenListAll = [];
  List<dynamic> _acaraDateList = [];
  List<Map<String, dynamic>> _pengumumanList = [];
  int day = 1;
  int countAcara = 5;
  int countUnreadPengumuman = 0;
  bool _isLoading = true;
  bool _isLoadingBrm = true;
  List<Map<String, dynamic>> _dataBrm = [];
  Map<String, dynamic> _dataBrm10Hari = {}; //load dari shared preferences
  Map<String, String> _dataUser = {};
  bool _komitmenDone = false;
  // DateTime _today = DateTime.now();

  // ini dipakai untuk acara hari ini statis, kartu komitmen, kartu dokumentasi
  // [DEVELOPMENT NOTES] nanti hapus
  // untuk testing, set di global variables.dart
  // DateTime _today = DateTime.now();
  // DateTime _today = DateTime(2025, 12, 31);
  late DateTime _today;
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
      'acara_nama': 'Pendaftaran',
      'tanggal': DateTime(2025, 12, 30),
      'waktu': TimeOfDay(hour: 8, minute: 0),
      'tempat': 'Aula Utama',
      'gambar': 'assets/mockups/daftar.jpg',
    },
    {
      'id': 2,
      'acara_nama': 'Opening Ceremony',
      'tanggal': DateTime(2025, 12, 30),
      'waktu': TimeOfDay(hour: 10, minute: 0),
      'tempat': 'Aula Utama',
      'gambar': 'assets/mockups/opening.jpg',
    },
    {
      'id': 3,
      'acara_nama': 'KKR 1',
      'tanggal': DateTime(2025, 12, 30),
      'waktu': TimeOfDay(hour: 13, minute: 0),
      'tempat': 'Aula Utama',
      'gambar': 'assets/mockups/kkr1.jpg',
    },
  ];

  //static data
  final List<Map<String, dynamic>> acaraStatisHari2 = [
    {
      'id': 4,
      'acara_nama': 'Saat Teduh',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 4, minute: 0),
      'tempat': 'Aula Utama',
      'gambar': 'assets/mockups/saat_teduh1.jpg',
    },
    {
      'id': 5,
      'acara_nama': 'KKR 2',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 7, minute: 0),
      'tempat': 'Aula Utama',
      'gambar': 'assets/mockups/kkr2.jpg',
    },
    {
      'id': 6,
      'acara_nama': 'Drama Musikal',
      'tanggal': DateTime(2025, 12, 31),
      'waktu': TimeOfDay(hour: 19, minute: 0),
      'tempat': 'Aula Utama',
      'gambar': 'assets/mockups/drama_musikal.jpg',
    },
  ];

  //static data
  final List<Map<String, dynamic>> acaraStatisHari3 = [
    {
      'id': 7,
      'acara_nama': 'New Year Countdown',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 4, minute: 0),
      'tempat': 'Aula Utama',
      'gambar': 'assets/mockups/new_year.jpg',
    },
    {
      'id': 8,
      'acara_nama': 'Saat Teduh',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 7, minute: 0),
      'tempat': 'Aula Utama',
      'gambar': 'assets/mockups/saat_teduh1.jpg',
    },
    {
      'id': 9,
      'acara_nama': 'KKR 3',
      'tanggal': DateTime(2026, 01, 01),
      'waktu': TimeOfDay(hour: 19, minute: 0),
      'tempat': 'Aula Utama',
      'gambar': 'assets/mockups/kkr3.jpg',
    },
  ];

  //static data
  final List<Map<String, dynamic>> acaraStatisHari4 = [
    {
      'id': 10,
      'acara_nama': 'Saat Teduh',
      'tanggal': DateTime(2026, 01, 02),
      'waktu': TimeOfDay(hour: 7, minute: 0),
      'tempat': 'Aula Utama',
      'gambar': 'assets/mockups/saat_teduh1.jpg',
    },
    {
      'id': 11,
      'acara_nama': 'Closing',
      'tanggal': DateTime(2026, 01, 02),
      'waktu': TimeOfDay(hour: 11, minute: 0),
      'tempat': 'Aula Utama',
      'gambar': 'assets/mockups/closing.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();

    //[DEVELOPMENT NOTES] untuk testing, nanti dihapus
    setState(() {
      _today = GlobalVariables.today;
      _timeOfDay = GlobalVariables.timeOfDay;
    });

    initNotificationService();
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
      setState(() {
        _currentAcaraPage = (_acaraController.offset / itemWidth).round();
      });
    });
  }

  Future<void> initNotificationService() async {
    final notificationService = NotificationService();
    await notificationService.initialize();

    print('🔔[NotificationService] Initialized');
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
      _isLoadingBrm = true;
    });
    print(
      '_today: ${_today.toIso8601String().substring(0, 10)}, acaraStatisHari1[0][tanggal]: ${acaraStatisHari1[0]["tanggal"]}, eq: ${_today.toIso8601String().substring(0, 10) == acaraStatisHari1[0]["tanggal"].toString().substring(0, 10)}',
    );
    try {
      await loadUserData();
      await loadBrm();
      await loadDayHariIni(); //untuk ambil tangggal hari ini
      await loadAcaraByDay();
      await loadReportBrmByPesertaByDay();
      await loadPengumumanByUserId();
      await checkKomitmenDone();

      // untuk keperluan notifikasi
      await loadAllAcara();
      await loadAllKomitmen();

      //setup notifications
      // await setupDailyNotification();

      // ini adalah notifikasi pasti yaitu:
      // 1. Notifikasi acara 15 menit sebelum acara hari 1 - 4 (untuk semua role)
      // 2. Notifikasi evaluasi 2 jam menit setelah acara dimulai hari 1 - 4 (untuk peserta, pembina)
      // 3. Notifikasi evaluasi keseluruhan 1x hari terakhir jam 12 siang (untuk peserta, pembina)
      // 4. Notifikasi komitmen setiap hari tiap jam 8 malam (untuk peserta)
      await setupAllNotification();
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isLoadingBrm = false;
    });
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      'email',
      'group_id',
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

  // Setup background sync untuk pengumuman
  // Future<void> setupBackgroundSync() async {
  //   try {
  //     print(
  //       '[BackgroundSync] setupBackgroundSync dipanggil pada: ${DateTime.now()}',
  //     );
  //     // Initialize pengumuman sync (set last check time pertama kali)
  //     await NotificationService.initializePengumumanSync();

  //     // Register periodic background task (workmanager)
  //     await BackgroundTaskService.registerPeriodicTask();

  //     // Configure background fetch (iOS dan Android)
  //     BackgroundFetch.configure(
  //           BackgroundFetchConfig(
  //             minimumFetchInterval: 15, // 15 menit (minimum yang diizinkan)
  //             forceAlarmManager: false,
  //             stopOnTerminate: false,
  //             startOnBoot: true,
  //             enableHeadless: true,
  //           ),
  //           (String taskId) async {
  //             print('[BackgroundFetch] Event received: $taskId');
  //             // Check pengumuman terbaru
  //             await NotificationService.checkLatestPengumuman();
  //             // Always finish task
  //             BackgroundFetch.finish(taskId);
  //           },
  //         )
  //         .then((int status) {
  //           print('[BackgroundFetch] configure success: $status');
  //         })
  //         .catchError((e) {
  //           print('[BackgroundFetch] configure ERROR: $e');
  //         });

  //     // Start background fetch
  //     BackgroundFetch.start()
  //         .then((int status) {
  //           print('[BackgroundFetch] start success: $status');
  //         })
  //         .catchError((e) {
  //           print('[BackgroundFetch] start ERROR: $e');
  //         });

  //     print('Background sync setup completed');
  //   } catch (e) {
  //     print('Error setting up background sync: $e');
  //   }
  // }

  Future<void> loadBrm() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final brm = await ApiService.getBrmToday(context);
      if (!mounted) return;
      setState(() {
        final dataBrm = brm['data_brm'];
        if (dataBrm != null && dataBrm is Map<String, dynamic>) {
          _dataBrm = [dataBrm];
        } else {
          _dataBrm = [];
        }
        // print('Data BRM: $_dataBrm');
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // count read tidak bisa disimpan 10 hari, harus terupdate setiap hari
  Future<void> loadReportBrmByPesertaByDay() async {
    if (!mounted) return;
    setState(() => _isLoadingBrm = true);
    // ambil data bacaan dari shared preferences (nanti hapus)
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    for (int i = 0; i < 10; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final dateStr = date.toIso8601String().substring(0, 10);
      final bacaanKey = 'bacaan_$dateStr';
      final bacaan = prefs.getString(bacaanKey);
      print('[BRM Shared Pref] $bacaanKey = $bacaan');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final bacaanKey = 'bacaan_' + today;
      final bacaan = prefs.getString(bacaanKey);

      if (bacaan != null) {
        // Jika ada di shared preferences, gunakan data ini
        print('[BRM] Bacaan hari ini ($today) diambil dari SharedPreferences: passage="$bacaan"');
        if (!mounted) return;
        setState(() {
          _dataBrm = [
            {'tanggal': today, 'passage': bacaan},
          ];
          _isLoadingBrm = false;
        });
        return;
      }

      // Jika tidak ada, ambil 10x data dari API (10 hari ke belakang)
      print('[BRM] Bacaan hari ini ($today) tidak ditemukan di SharedPreferences, fetch 10 hari terakhir dari API...');
      List<Map<String, dynamic>> brmList = [];
      for (int i = 0; i < 10; i++) {
        final date = DateTime.now().add(Duration(days: i));
        final dateStr = date.toIso8601String().substring(0, 10);
        final report = await ApiService.getBrmByDay(context, dateStr);
        String passage = '';
        if (report != null && report['data_brm'] != null) {
          passage = report['data_brm']['passage'] ?? '';
        }
        // Jika response 404 atau success false, passage tetap kosong
        await prefs.setString('bacaan_' + dateStr, passage);
        // Untuk hari ini, update state
        if (i == 0) {
          brmList.add({'tanggal': dateStr, 'passage': passage});
        }
      }
      print(
        '[BRM] Bacaan hari ini ($today) diambil dari hasil fetch API, passage="${brmList.isNotEmpty ? brmList[0]['passage'] : ''}"',
      );
      if (!mounted) return;
      setState(() {
        _dataBrm = brmList.isNotEmpty ? brmList : [];
        _isLoadingBrm = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingBrm = false);
    }
  }

  // untuk load acara berdasarkan hari ini
  Future<void> loadDayHariIni() async {
    if (!mounted) return;
    setState(() {});
    try {
      final acaraList = await ApiService.getAcara(context);
      if (!mounted) return;
      setState(() {
        print('Acara Date List: $acaraList');

        // Ambil list tanggal dan hari unik
        final List<Map<String, dynamic>> tanggalHariList = [];
        final Set<String> tanggalHariSet = {};

        for (var acara in acaraList) {
          final tanggal = acara['tanggal'];
          final hari = acara['hari'];
          final key = '$tanggal|$hari';
          if (!tanggalHariSet.contains(key)) {
            tanggalHariSet.add(key);
            tanggalHariList.add({'tanggal': tanggal, 'hari': hari});
          }
        }

        _acaraDateList = tanggalHariList;
        print("$_acaraDateList");

        // Cek apakah today ada di tanggalHariList
        final todayEntry = tanggalHariList.firstWhere(
          (item) => item['tanggal'] == _today.toIso8601String().substring(0, 10),
          orElse: () => {},
        );
        if (todayEntry.isNotEmpty) {
          day = todayEntry['hari'] ?? 0;
          print('Hari ini: $day');
        } else {
          day = 0; //  default
        }
      });
    } catch (e) {
      print('❌ Gagal memuat tanggal acara: $e');
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> loadAcaraByDay() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final acaraList = await ApiService.getAcaraByDay(context, day);
      if (!mounted) return;
      setState(() {
        _acaraList = acaraList;
        _isLoading = false;
        countAcara = _acaraList.length;
        print('Acara List: $_acaraList');
        print('Jumlah Acara: ${_acaraList.length}');
      });
    } catch (e) {
      print('❌ Gagal memuat acara: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // untuk notifikasi
  Future<void> loadAllAcara() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final acaraList = await ApiService.getAcara(context);
      if (!mounted) return;
      setState(() {
        _acaraListAll = acaraList;
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

  // untuk notifikasi
  Future<void> loadAllKomitmen() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final komitmenList = await ApiService.getKomitmen(context);
      if (!mounted) return;
      setState(() {
        _komitmenListAll = komitmenList;
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

  Future<void> loadPengumumanByUserId() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final pengumumanList = await ApiService.getPengumuman(context, _dataUser['id']);
      if (!mounted) return;
      setState(() {
        final pengumumanList2 = List<Map<String, dynamic>>.from(pengumumanList);
        _pengumumanList = pengumumanList2;
        // Hitung jumlah pengumuman dengan count_read == 0
        countUnreadPengumuman = _pengumumanList.where((p) => (p['count_read'] ?? 1) == 0).length;
        _isLoading = false;
        print('Unread Pengumuman: $countUnreadPengumuman');
      });
    } catch (e) {
      print('❌ Gagal memuat pengumuman: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> checkKomitmenDone() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final komitmenProgress = await ApiService.getKomitmenByPesertaByDay(
        context,
        _dataUser['id'],
        1, //hardcoded
      );
      if (!mounted) return;
      setState(() {
        // Ambil status komitmen dari response
        final dataKomitmen = komitmenProgress['success'] ?? false;
        _komitmenDone = dataKomitmen;
        print('Status komitmen: $_komitmenDone');
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat progress komitmen: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> setupDailyNotification() async {
  //   try {
  //     final notificationService = NotificationService();
  //     await notificationService.initialize();

  //     // ⬅️ CANCEL SEMUA NOTIFIKASI LAMA TERLEBIH DAHULU
  //     await notificationService.cancelNotification();

  //     // Setup notifikasi baru
  //     await notificationService.scheduledNotification(
  //       title: '📖 Waktu Bacaan Harian!',
  //       body:
  //           'Jangan lupa baca Alkitab hari ini. Tuhan menunggu waktu bersamamu!',
  //       scheduledTime: _getNext9AM(),
  //       payload: 'splash',
  //     );

  //     print(
  //       '✅ Daily BRM notification setup completed (old notifications cancelled)',
  //     );
  //   } catch (e) {
  //     print('❌ Error setting up daily notifications: $e');
  //   }
  // }

  // ini adalah notifikasi pasti yaitu:
  // 1. Notifikasi acara 15 menit sebelum acara hari 1 - 4 (untuk semua role)
  // 2. Notifikasi evaluasi 1 jam setelah acara dimulai hari 1 - 4 (untuk peserta, pembina)
  // 3. Notifikasi evaluasi keseluruhan 1x hari terakhir jam 12 siang (untuk peserta, pembina)
  // 4. Notifikasi komitmen setiap hari tiap jam 3 sore (untuk peserta)
  Future<void> setupAllNotification() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      // CANCEL SEMUA NOTIFIKASI LAMA TERLEBIH DAHULU
      await notificationService.cancelNotification();

      // Debug: Jadwalkan notifikasi dengan waktu yang diinputkan sendiri
      // Ganti tanggal dan waktu sesuai kebutuhan debug
      final debugScheduledTime = DateTime(2025, 7, 14, 13, 28, 0); // contoh: 20 Juli 2025 jam 10:00
      if (debugScheduledTime.isAfter(DateTime.now())) {
        await notificationService.scheduledNotification(
          title: '🔔 Debug Notification',
          body: 'Ini adalah notifikasi debug pada $debugScheduledTime',
          scheduledTime: debugScheduledTime,
          payload: 'splash',
        );
        print('🔔 Debug notification scheduled at $debugScheduledTime');
      }

      // 15 menit sebelum acara
      for (final acara in _acaraListAll) {
        final hari = acara['hari']?.toString();
        if (hari == "99") continue; // skip hari 99
        final tanggal = acara['tanggal'] ?? '';
        final waktu = acara['waktu'] ?? '';
        final namaAcara = acara['acara_nama'] ?? 'Acara';
        DateTime? scheduledTime;
        try {
          scheduledTime = DateTime.parse('$tanggal ${waktu.length == 5 ? waktu : '00:00'}:00');
          scheduledTime = scheduledTime.subtract(const Duration(minutes: 15));
        } catch (e) {
          continue;
        }
        print('🔔 Jadwalkan notif 15 menit sebelum acara "$namaAcara" pada $scheduledTime');
        if (scheduledTime.isAfter(DateTime.now())) {
          await notificationService.scheduledNotification(
            title: '⏰ Acara akan dimulai!',
            body: '${namaAcara} akan dimulai dalam 15 menit!',
            scheduledTime: scheduledTime,
            payload: 'splash',
          );
        }
      }

      final userRole = _dataUser['role']?.toLowerCase() ?? '';
      // Evaluasi
      // Notifikasi evaluasi 1 jam setelah acara dimulai
      // Hanya untuk role peserta atau pembina
      if (userRole == 'peserta' || userRole == 'pembina') {
        for (final acara in _acaraListAll) {
          final hari = acara['hari']?.toString();
          if (hari == "99") continue; // skip hari 99
          final tanggal = acara['tanggal'] ?? '';
          final waktu = acara['waktu'] ?? '';
          final namaAcara = acara['acara_nama'] ?? 'Acara';
          DateTime? scheduledTime;
          try {
            // Gabungkan tanggal dan waktu, misal: '2025-12-31' + '07:30'
            scheduledTime = DateTime.parse('$tanggal ${waktu.length == 5 ? waktu : '00:00'}:00');
            // Tambahkan 1 jam setelah acara dimulai
            scheduledTime = scheduledTime.add(const Duration(hours: 1));
          } catch (e) {
            print('❌ Gagal parsing tanggal/waktu evaluasi: $tanggal $waktu ($e)');
            continue;
          }
          print('🔔 Jadwalkan notif evaluasi 1 jam setelah acara "$namaAcara" pada $scheduledTime');
          if (scheduledTime.isAfter(DateTime.now())) {
            await notificationService.scheduledNotification(
              title: '📝 Reminder Evaluasi!',
              body: 'Jangan lupa mengisi evaluasi acara : ${namaAcara}',
              scheduledTime: scheduledTime,
              payload: 'splash',
            );
          }
        }
      }

      // Evaluasi keseluruhan
      // Evaluasi keseluruhan: cari acara dengan hari == "99"
      // Evaluasi keseluruhan: hanya untuk role peserta atau pembina
      if (userRole == 'peserta' || userRole == 'pembina') {
        final acaraEvaluasi = _acaraListAll.firstWhere(
          (acara) => acara['hari']?.toString() == "99",
          orElse: () => null,
        );

        if (acaraEvaluasi != null) {
          final tanggal = acaraEvaluasi['tanggal'];
          try {
            // Set jam 12:00 siang pada tanggal tersebut
            // Jika tanggal == '2026-01-02', set scheduledTime ke 2 Januari 2026 jam 12:00:00
            final scheduledTime = DateTime.parse('2025-07-17 12:00:00');
            print('🔔 Jadwalkan notif evaluasi keseluruhan pada $scheduledTime');
            if (scheduledTime.isAfter(DateTime.now())) {
              await notificationService.scheduledNotification(
                title: 'Thank you for attending SYC 2025 - Redeemed!',
                body: '📝 Jangan lupa mengisi evaluasi keseluruhan pada profil kamu 😊',
                scheduledTime: scheduledTime,
                payload: 'splash',
              );
            }
          } catch (e) {
            print('❌ Gagal parsing tanggal evaluasi keseluruhan: $tanggal ($e)');
          }
        }
      }

      // Komitmen harian
      // Notifikasi komitmen harian: iterasi semua komitmen, jadwalkan pada tanggal terkait jam 15:00
      // Komitmen harian: hanya untuk role peserta
      if (userRole == 'peserta') {
        for (final komitmen in _komitmenListAll) {
          final tanggal = komitmen['tanggal'];
          final hariKomitmen = komitmen['hari'] ?? '0';
          if (tanggal != null && tanggal is String && tanggal.isNotEmpty) {
            try {
              // Set jam 15:00 (3 sore) pada tanggal tersebut
              final scheduledTime = DateTime.parse('$tanggal 15:00:00');
              if (scheduledTime.isAfter(DateTime.now())) {
                await notificationService.scheduledNotification(
                  title: '🙏 Reminder Komitmen!',
                  body: 'Jangan lupa mengisi komitmen hari ke : ${hariKomitmen}',
                  scheduledTime: scheduledTime,
                  payload: 'splash',
                );
              }
            } catch (e) {
              print('❌ Gagal parsing tanggal komitmen: $tanggal ($e)');
            }
          }
        }
      }
      print('Notificaton setup completed');
    } catch (e) {
      print('❌ Error setting up daily notifications: $e');
    }
  }

  DateTime _getNext9AM() {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, 9, 03); // 09:00

    // Jika sudah lewat jam 9 hari ini, jadwalkan untuk besok
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }

  @override
  void dispose() {
    _acaraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _dataUser['id'] ?? '-';
    final role = _dataUser['role'] ?? '-';
    final gereja = _dataUser['gereja_nama'] ?? '-';
    final kelompok = _dataUser['nama_kelompok'] ?? '-';

    return Scaffold(
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
              onRefresh: () => initAll(),
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
                          children: [Image.asset('assets/texts/hello.png', height: 72)],
                        ),
                      ),

                      //[DEVELOPMENT NOTES] untuk testing, nanti dihapus
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: const Text(
                          "Tombol Testing (nanti dihapus)",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ),

                      //[DEVELOPMENT NOTES] untuk testing, nanti dihapus
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      GlobalVariables.today = DateTime(2025, 12, 30);
                                      GlobalVariables.timeOfDay = const TimeOfDay(hour: 6, minute: 0);
                                      _today = GlobalVariables.today;
                                      _timeOfDay = GlobalVariables.timeOfDay;
                                      setState(() {});
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const MainScreen()),
                                        );
                                      }
                                    },
                                    child: const Text('30-12-2025\n06:00', textAlign: TextAlign.center),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      GlobalVariables.today = DateTime(2025, 12, 30);
                                      GlobalVariables.timeOfDay = const TimeOfDay(hour: 21, minute: 0);
                                      _today = GlobalVariables.today;
                                      _timeOfDay = GlobalVariables.timeOfDay;
                                      setState(() {});
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const MainScreen()),
                                        );
                                      }
                                    },
                                    child: const Text('30-12-2025\n21:00', textAlign: TextAlign.center),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      GlobalVariables.today = DateTime(2025, 12, 31);
                                      GlobalVariables.timeOfDay = const TimeOfDay(hour: 3, minute: 0);
                                      _today = GlobalVariables.today;
                                      _timeOfDay = GlobalVariables.timeOfDay;
                                      setState(() {});
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const MainScreen()),
                                        );
                                      }
                                    },
                                    child: const Text('31-12-2025\n03:00', textAlign: TextAlign.center),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      GlobalVariables.today = DateTime(2025, 12, 31);
                                      GlobalVariables.timeOfDay = const TimeOfDay(hour: 21, minute: 0);
                                      _today = GlobalVariables.today;
                                      _timeOfDay = GlobalVariables.timeOfDay;
                                      setState(() {});
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const MainScreen()),
                                        );
                                      }
                                    },
                                    child: const Text('31-12-2025\n21:00', textAlign: TextAlign.center),
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
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      GlobalVariables.today = DateTime(2026, 1, 1);
                                      GlobalVariables.timeOfDay = const TimeOfDay(hour: 3, minute: 0);
                                      _today = GlobalVariables.today;
                                      _timeOfDay = GlobalVariables.timeOfDay;
                                      setState(() {});
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const MainScreen()),
                                        );
                                      }
                                    },
                                    child: const Text('01-01-2026\n03:00', textAlign: TextAlign.center),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      GlobalVariables.today = DateTime(2026, 1, 1);
                                      GlobalVariables.timeOfDay = const TimeOfDay(hour: 21, minute: 0);
                                      _today = GlobalVariables.today;
                                      _timeOfDay = GlobalVariables.timeOfDay;
                                      setState(() {});
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const MainScreen()),
                                        );
                                      }
                                    },
                                    child: const Text('01-01-2026\n21:00', textAlign: TextAlign.center),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      GlobalVariables.today = DateTime(2026, 1, 2);
                                      GlobalVariables.timeOfDay = const TimeOfDay(hour: 3, minute: 0);
                                      _today = GlobalVariables.today;
                                      _timeOfDay = GlobalVariables.timeOfDay;
                                      setState(() {});
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const MainScreen()),
                                        );
                                      }
                                    },
                                    child: const Text('02-01-2026\n03:00', textAlign: TextAlign.center),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      GlobalVariables.today = DateTime(2026, 1, 2);
                                      GlobalVariables.timeOfDay = const TimeOfDay(hour: 16, minute: 0);
                                      _today = GlobalVariables.today;
                                      _timeOfDay = GlobalVariables.timeOfDay;
                                      setState(() {});
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const MainScreen()),
                                        );
                                      }
                                    },
                                    child: const Text('02-01-2026\n16:00', textAlign: TextAlign.center),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //[DEVELOPMENT NOTES] untuk testing, nanti dihapus
                      const SizedBox(height: 24),

                      // [DEVELOPMENT NOTES] Nanti setting
                      if ((_today.isAfter(DateTime(2026, 1, 2)) || _today == DateTime(2026, 1, 2)) &&
                          _timeOfDay.hour >= 12)
                        // Dokumentasi Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  const url =
                                      'https://drive.google.com/drive/folders/1J7qIoUL7aI2YGy7tR_ZFQxX-7ylzVZrg?usp=sharing';
                                  final uri = Uri.parse(url);
                                  bool launched = false;
                                  try {
                                    launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } catch (_) {}
                                  if (!launched) {
                                    try {
                                      launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
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
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: const DecorationImage(
                                          image: AssetImage('assets/images/card_dokumentasi.jpg'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.secondary,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(12),
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

                      if ((_today.isAfter(DateTime(2026, 1, 2)) || _today == DateTime(2026, 1, 2)) &&
                          _timeOfDay.hour >= 12)
                        const SizedBox(height: 24),

                      // Pembina Pembimbing Card
                      if (role.toLowerCase().contains('pembina') == true ||
                          role.toLowerCase().contains('pembimbing') == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: AssetImage('assets/images/card_dashboard_role.png'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 16.0, bottom: 16.0, left: 48),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              (_dataUser['role']?.toLowerCase().contains('pembimbing') == true)
                                                  ? 'Pembimbing'
                                                  : (_dataUser['role']?.toLowerCase().contains('pembina') == true)
                                                  ? 'Pembina'
                                                  : '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                            Text(
                                              (_dataUser['role']?.toLowerCase().contains('pembimbing') == true)
                                                  ? '${_dataUser['kelompok_nama'] ?? ''}'
                                                  : (_dataUser['role']?.toLowerCase().contains('pembina') == true)
                                                  ? '${_dataUser['gereja_nama'] ?? ''}'
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
                            ],
                          ),
                        ),

                      if (role.toLowerCase().contains('pembina') == true ||
                          role.toLowerCase().contains('pembimbing') == true)
                        const SizedBox(height: 24),

                      // Komitmen Card untuk Peserta
                      // Card ini muncul di jam 20 - 00
                      // Tampilkan Komitmen Card hanya jika:
                      // - BUKAN panitia, pembimbing, pembina
                      // - day antara 1 sampai 3 (inklusif)
                      if ((day >= 1 && day <= 3) &&
                          !role.toLowerCase().contains('panitia') &&
                          !role.toLowerCase().contains('pembimbing') &&
                          !role.toLowerCase().contains('pembina') &&
                          (_timeOfDay.hour >= 20 && _timeOfDay.hour < 24))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  // Cek apakah sudah jam 15:00 pada hari ini
                                  final now = DateTime.now();
                                  final aksesTime = DateTime(now.year, now.month, now.day, 15, 0);
                                  if (now.isBefore(aksesTime)) {
                                    // Belum jam 15:00, tampilkan custom snackbar
                                    showCustomSnackBar(
                                      context,
                                      'Tidak bisa akses komitmen sebelum ${DateFormatter.ubahTanggal(now.toIso8601String().substring(0, 10))} pukul 15:00',
                                    );
                                    return;
                                  }
                                  if (_komitmenDone) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EvaluasiKomitmenViewScreen(
                                              type: 'Komitmen',
                                              userId: userId,
                                              acaraHariId: day,
                                            ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FormKomitmenScreen(userId: userId, acaraHariId: day),
                                      ),
                                    ).then((result) {
                                      if (result == 'reload') {
                                        initAll();
                                      }
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 180,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: const DecorationImage(
                                          image: AssetImage('assets/images/card_dashboard_komitmen.png'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 16.0, bottom: 16.0, left: 64),
                                              child: Text(
                                                _komitmenDone
                                                    ? 'Terima kasih telah mengisi komitmen hari ini!'
                                                    : 'Jangan lupa mengisi komitmen harianmu!',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
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
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              bottomRight: Radius.circular(8),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                'Selesai',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
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
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(16),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        child: Text(
                                          DateFormatter.ubahTanggal(DateTime.now().toIso8601String().substring(0, 10)),
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

                      if ((day >= 1 && day <= 3) &&
                          !role.toLowerCase().contains('panitia') &&
                          !role.toLowerCase().contains('pembimbing') &&
                          !role.toLowerCase().contains('pembina') &&
                          (_timeOfDay.hour >= 20 && _timeOfDay.hour < 24))
                        const SizedBox(height: 24),

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
                                    imagePath: 'assets/images/data_not_found.png',
                                  ),
                                )
                                : InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => BibleReadingMoreScreen(userId: userId)),
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
                                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withAlpha(70),
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.center,
                                            colors: [Colors.black.withAlpha(100), Colors.black.withAlpha(10)],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          image: const DecorationImage(
                                            image: AssetImage('assets/mockups/bible_reading.jpg'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              if (_dataBrm.isNotEmpty) ...[
                                                Text(
                                                  'Bacaan Hari Ini',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _dataBrm[0]['passage'] ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ] else ...[
                                                const Text(
                                                  "Tidak ada data BRM hari ini",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      // if (countRead > 0)
                                      //   Positioned(
                                      //     top: 0,
                                      //     left: 0,
                                      //     child: Container(
                                      //       decoration: BoxDecoration(
                                      //         color: Colors.green,
                                      //         borderRadius:
                                      //             const BorderRadius.only(
                                      //               topLeft: Radius.circular(
                                      //                 16,
                                      //               ),
                                      //               bottomRight:
                                      //                   Radius.circular(8),
                                      //             ),
                                      //       ),
                                      //       padding: const EdgeInsets.symmetric(
                                      //         horizontal: 12,
                                      //         vertical: 8,
                                      //       ),
                                      //       child: Row(
                                      //         children: const [
                                      //           Icon(
                                      //             Icons.check_circle,
                                      //             color: Colors.white,
                                      //             size: 16,
                                      //           ),
                                      //           SizedBox(width: 4),
                                      //           Text(
                                      //             'Sudah dibaca',
                                      //             style: TextStyle(
                                      //               fontSize: 12,
                                      //               color: Colors.white,
                                      //               fontWeight: FontWeight.bold,
                                      //             ),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary,
                                            borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(16),
                                              bottomLeft: Radius.circular(8),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Text(
                                            _dataBrm.isNotEmpty
                                                ? DateFormatter.ubahTanggal(_dataBrm[0]['tanggal'])
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
                      ),

                      // Komitmen Card untuk Peserta
                      // Card ini muncul di jam 00 - 20
                      // Tampilkan Komitmen Card hanya jika:
                      // - BUKAN panitia, pembimbing, pembina
                      // - day antara 1 sampai 3 (inklusif)
                      if ((day >= 1 && day <= 3) &&
                          !role.toLowerCase().contains('panitia') &&
                          !role.toLowerCase().contains('pembimbing') &&
                          !role.toLowerCase().contains('pembina') &&
                          (_timeOfDay.hour >= 0 && _timeOfDay.hour < 20))
                        const SizedBox(height: 24),

                      if ((day >= 1 && day <= 3) &&
                          !role.toLowerCase().contains('panitia') &&
                          !role.toLowerCase().contains('pembimbing') &&
                          !role.toLowerCase().contains('pembina') &&
                          (_timeOfDay.hour >= 0 && _timeOfDay.hour < 20))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  // Cek apakah sudah jam 15:00 pada hari ini
                                  final now = DateTime.now();
                                  final aksesTime = DateTime(now.year, now.month, now.day, 15, 0);
                                  if (now.isBefore(aksesTime)) {
                                    // Belum jam 15:00, tampilkan custom snackbar
                                    showCustomSnackBar(
                                      context,
                                      'Tidak bisa akses komitmen sebelum ${DateFormatter.ubahTanggal(now.toIso8601String().substring(0, 10))} pukul 15:00',
                                    );
                                    return;
                                  }
                                  if (_komitmenDone) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EvaluasiKomitmenViewScreen(
                                              type: 'Komitmen',
                                              userId: userId,
                                              acaraHariId: day,
                                            ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FormKomitmenScreen(userId: userId, acaraHariId: day),
                                      ),
                                    ).then((result) {
                                      if (result == 'reload') {
                                        initAll();
                                      }
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 180,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: const DecorationImage(
                                          image: AssetImage('assets/images/card_dashboard_komitmen.png'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 16.0, bottom: 16.0, left: 64),
                                              child: Text(
                                                _komitmenDone
                                                    ? 'Terima kasih telah mengisi komitmen hari ini!'
                                                    : 'Jangan lupa mengisi komitmen harianmu!',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
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
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              bottomRight: Radius.circular(8),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                'Selesai',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
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
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(16),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        child: Text(
                                          DateFormatter.ubahTanggal(DateTime.now().toIso8601String().substring(0, 10)),
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
                      const SizedBox(height: 24),

                      // Acara Statis Hari ke 1: tampilkan hanya jika _today == acaraStatisHari1[0]["tanggal"]
                      if (acaraStatisHari1.isNotEmpty && _today == acaraStatisHari1[0]["tanggal"])
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
                                      MaterialPageRoute(builder: (context) => const MainScreen()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
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
                                      const Icon(Icons.arrow_forward_ios, color: AppColors.black1),
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
                                            if (parts.length < 2) return false;
                                            final jam = int.tryParse(parts[0]) ?? 0;
                                            final menit = int.tryParse(parts[1]) ?? 0;
                                            acaraTime = TimeOfDay(hour: jam, minute: menit);
                                          } else {
                                            return false;
                                          }
                                          // Tampilkan jika waktu acara >= sekarang
                                          return acaraTime.hour > now.hour ||
                                              (acaraTime.hour == now.hour && acaraTime.minute >= now.minute);
                                        }).toList();
                                    if (filteredAcara.isEmpty) {
                                      return Center(
                                        child: CustomNotFound(
                                          text: "Tidak ada acara mendatang :(",
                                          textColor: AppColors.brown1,
                                          imagePath: 'assets/images/data_not_found.png',
                                        ),
                                      );
                                    }
                                    return SizedBox(
                                      height: 160,
                                      child: ListView.builder(
                                        controller: _acaraStatisHari1Controller,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: filteredAcara.length,
                                        itemBuilder: (context, index) {
                                          final acara = filteredAcara[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) => DetailAcaraScreen(
                                                          id: acara["id"].toString(),
                                                          userId: userId,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Container(
                                                      height: 160,
                                                      width: 160,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: const BorderRadius.only(
                                                          bottomRight: Radius.circular(16),
                                                          topLeft: Radius.circular(16),
                                                          bottomLeft: Radius.circular(16),
                                                          topRight: Radius.circular(16),
                                                        ),
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                            acara['gambar'] ?? 'assets/images/event.jpg',
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
                                                                begin: Alignment.bottomCenter,
                                                                end: Alignment.center,
                                                                colors: [
                                                                  Colors.black.withAlpha(100),
                                                                  Colors.black.withAlpha(10),
                                                                ],
                                                              ),
                                                              borderRadius: const BorderRadius.only(
                                                                bottomRight: Radius.circular(16),
                                                                topLeft: Radius.circular(16),
                                                                bottomLeft: Radius.circular(16),
                                                                topRight: Radius.circular(16),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                              left: 8,
                                                              right: 8,
                                                              bottom: 8,
                                                            ),
                                                            child: Align(
                                                              alignment: Alignment.bottomLeft,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      acara['acara_nama'] ?? '',
                                                                      textAlign: TextAlign.left,
                                                                      style: const TextStyle(
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.w900,
                                                                        color: Colors.white,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons.location_on,
                                                                        color: Colors.white,
                                                                        size: 12,
                                                                      ),
                                                                      const SizedBox(width: 4),
                                                                      Flexible(
                                                                        child: Text(
                                                                          acara['tempat'] ?? '',
                                                                          style: const TextStyle(
                                                                            fontSize: 14,
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w300,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
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
                                                        color: AppColors.secondary,
                                                        shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.only(
                                                            bottomLeft: Radius.circular(16),
                                                            topRight: Radius.circular(16),
                                                          ),
                                                        ),
                                                        elevation: 0,
                                                        child: SizedBox(
                                                          width: 72,
                                                          height: 36,
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                const Icon(
                                                                  Icons.access_time_filled_rounded,
                                                                  color: AppColors.primary,
                                                                  size: 16,
                                                                ),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  (acara['waktu'] is TimeOfDay
                                                                      ? acara['waktu'].hour.toString().padLeft(2, '0') +
                                                                          ':' +
                                                                          acara['waktu'].minute.toString().padLeft(
                                                                            2,
                                                                            '0',
                                                                          )
                                                                      : (acara['waktu']?.toString() ?? '')),
                                                                  style: const TextStyle(
                                                                    color: AppColors.primary,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 12,
                                                                  ),
                                                                  textAlign: TextAlign.center,
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
                      if (acaraStatisHari2.isNotEmpty && _today == acaraStatisHari2[0]["tanggal"])
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
                                      MaterialPageRoute(builder: (context) => const MainScreen()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
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
                                      const Icon(Icons.arrow_forward_ios, color: AppColors.black1),
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
                                            if (parts.length < 2) return false;
                                            final jam = int.tryParse(parts[0]) ?? 0;
                                            final menit = int.tryParse(parts[1]) ?? 0;
                                            acaraTime = TimeOfDay(hour: jam, minute: menit);
                                          } else {
                                            return false;
                                          }
                                          // Tampilkan jika waktu acara >= sekarang
                                          return acaraTime.hour > now.hour ||
                                              (acaraTime.hour == now.hour && acaraTime.minute >= now.minute);
                                        }).toList();
                                    if (filteredAcara.isEmpty) {
                                      return Center(
                                        child: CustomNotFound(
                                          text: "Tidak ada acara mendatang :(",
                                          textColor: AppColors.brown1,
                                          imagePath: 'assets/images/data_not_found.png',
                                        ),
                                      );
                                    }
                                    return SizedBox(
                                      height: 160,
                                      child: ListView.builder(
                                        controller: _acaraStatisHari2Controller,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: filteredAcara.length,
                                        itemBuilder: (context, index) {
                                          final acara = filteredAcara[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) => DetailAcaraScreen(
                                                          id: acara["id"].toString(),
                                                          userId: userId,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Container(
                                                      height: 160,
                                                      width: 160,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: const BorderRadius.only(
                                                          bottomRight: Radius.circular(16),
                                                          topLeft: Radius.circular(16),
                                                          bottomLeft: Radius.circular(16),
                                                          topRight: Radius.circular(16),
                                                        ),
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                            acara['gambar'] ?? 'assets/images/event.jpg',
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
                                                                begin: Alignment.bottomCenter,
                                                                end: Alignment.center,
                                                                colors: [
                                                                  Colors.black.withAlpha(100),
                                                                  Colors.black.withAlpha(10),
                                                                ],
                                                              ),
                                                              borderRadius: const BorderRadius.only(
                                                                bottomRight: Radius.circular(16),
                                                                topLeft: Radius.circular(16),
                                                                bottomLeft: Radius.circular(16),
                                                                topRight: Radius.circular(16),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                              left: 8,
                                                              right: 8,
                                                              bottom: 8,
                                                            ),
                                                            child: Align(
                                                              alignment: Alignment.bottomLeft,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      acara['acara_nama'] ?? '',
                                                                      textAlign: TextAlign.left,
                                                                      style: const TextStyle(
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.w900,
                                                                        color: Colors.white,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons.location_on,
                                                                        color: Colors.white,
                                                                        size: 12,
                                                                      ),
                                                                      const SizedBox(width: 4),
                                                                      Flexible(
                                                                        child: Text(
                                                                          acara['tempat'] ?? '',
                                                                          style: const TextStyle(
                                                                            fontSize: 14,
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w300,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
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
                                                        color: AppColors.secondary,
                                                        shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.only(
                                                            bottomLeft: Radius.circular(16),
                                                            topRight: Radius.circular(16),
                                                          ),
                                                        ),
                                                        elevation: 0,
                                                        child: SizedBox(
                                                          width: 72,
                                                          height: 36,
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                const Icon(
                                                                  Icons.access_time_filled_rounded,
                                                                  color: AppColors.primary,
                                                                  size: 16,
                                                                ),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  (acara['waktu'] is TimeOfDay
                                                                      ? acara['waktu'].hour.toString().padLeft(2, '0') +
                                                                          ':' +
                                                                          acara['waktu'].minute.toString().padLeft(
                                                                            2,
                                                                            '0',
                                                                          )
                                                                      : (acara['waktu']?.toString() ?? '')),
                                                                  style: const TextStyle(
                                                                    color: AppColors.primary,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 12,
                                                                  ),
                                                                  textAlign: TextAlign.center,
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
                      if (acaraStatisHari3.isNotEmpty && _today == acaraStatisHari3[0]["tanggal"])
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
                                      MaterialPageRoute(builder: (context) => const MainScreen()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
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
                                      const Icon(Icons.arrow_forward_ios, color: AppColors.black1),
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
                                            if (parts.length < 2) return false;
                                            final jam = int.tryParse(parts[0]) ?? 0;
                                            final menit = int.tryParse(parts[1]) ?? 0;
                                            acaraTime = TimeOfDay(hour: jam, minute: menit);
                                          } else {
                                            return false;
                                          }
                                          // Tampilkan jika waktu acara >= sekarang
                                          return acaraTime.hour > now.hour ||
                                              (acaraTime.hour == now.hour && acaraTime.minute >= now.minute);
                                        }).toList();
                                    if (filteredAcara.isEmpty) {
                                      return Center(
                                        child: CustomNotFound(
                                          text: "Tidak ada acara mendatang :(",
                                          textColor: AppColors.brown1,
                                          imagePath: 'assets/images/data_not_found.png',
                                        ),
                                      );
                                    }
                                    return SizedBox(
                                      height: 160,
                                      child: ListView.builder(
                                        controller: _acaraStatisHari3Controller,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: filteredAcara.length,
                                        itemBuilder: (context, index) {
                                          final acara = filteredAcara[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) => DetailAcaraScreen(
                                                          id: acara["id"].toString(),
                                                          userId: userId,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Container(
                                                      height: 160,
                                                      width: 160,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: const BorderRadius.only(
                                                          bottomRight: Radius.circular(16),
                                                          topLeft: Radius.circular(16),
                                                          bottomLeft: Radius.circular(16),
                                                          topRight: Radius.circular(16),
                                                        ),
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                            acara['gambar'] ?? 'assets/images/event.jpg',
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
                                                                begin: Alignment.bottomCenter,
                                                                end: Alignment.center,
                                                                colors: [
                                                                  Colors.black.withAlpha(100),
                                                                  Colors.black.withAlpha(10),
                                                                ],
                                                              ),
                                                              borderRadius: const BorderRadius.only(
                                                                bottomRight: Radius.circular(16),
                                                                topLeft: Radius.circular(16),
                                                                bottomLeft: Radius.circular(16),
                                                                topRight: Radius.circular(16),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                              left: 8,
                                                              right: 8,
                                                              bottom: 8,
                                                            ),
                                                            child: Align(
                                                              alignment: Alignment.bottomLeft,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      acara['acara_nama'] ?? '',
                                                                      textAlign: TextAlign.left,
                                                                      style: const TextStyle(
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.w900,
                                                                        color: Colors.white,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons.location_on,
                                                                        color: Colors.white,
                                                                        size: 12,
                                                                      ),
                                                                      const SizedBox(width: 4),
                                                                      Flexible(
                                                                        child: Text(
                                                                          acara['tempat'] ?? '',
                                                                          style: const TextStyle(
                                                                            fontSize: 14,
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w300,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
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
                                                        color: AppColors.secondary,
                                                        shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.only(
                                                            bottomLeft: Radius.circular(16),
                                                            topRight: Radius.circular(16),
                                                          ),
                                                        ),
                                                        elevation: 0,
                                                        child: SizedBox(
                                                          width: 72,
                                                          height: 36,
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                const Icon(
                                                                  Icons.access_time_filled_rounded,
                                                                  color: AppColors.primary,
                                                                  size: 16,
                                                                ),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  (acara['waktu'] is TimeOfDay
                                                                      ? acara['waktu'].hour.toString().padLeft(2, '0') +
                                                                          ':' +
                                                                          acara['waktu'].minute.toString().padLeft(
                                                                            2,
                                                                            '0',
                                                                          )
                                                                      : (acara['waktu']?.toString() ?? '')),
                                                                  style: const TextStyle(
                                                                    color: AppColors.primary,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 12,
                                                                  ),
                                                                  textAlign: TextAlign.center,
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
                      if (acaraStatisHari4.isNotEmpty && _today == acaraStatisHari4[0]["tanggal"])
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
                                      MaterialPageRoute(builder: (context) => const MainScreen()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
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
                                      const Icon(Icons.arrow_forward_ios, color: AppColors.black1),
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
                                            if (parts.length < 2) return false;
                                            final jam = int.tryParse(parts[0]) ?? 0;
                                            final menit = int.tryParse(parts[1]) ?? 0;
                                            acaraTime = TimeOfDay(hour: jam, minute: menit);
                                          } else {
                                            return false;
                                          }
                                          // Tampilkan jika waktu acara >= sekarang
                                          return acaraTime.hour > now.hour ||
                                              (acaraTime.hour == now.hour && acaraTime.minute >= now.minute);
                                        }).toList();
                                    if (filteredAcara.isEmpty) {
                                      return Center(
                                        child: CustomNotFound(
                                          text: "Tidak ada acara mendatang :(",
                                          textColor: AppColors.brown1,
                                          imagePath: 'assets/images/data_not_found.png',
                                        ),
                                      );
                                    }
                                    return SizedBox(
                                      height: 160,
                                      child: ListView.builder(
                                        controller: _acaraStatisHari4Controller,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: filteredAcara.length,
                                        itemBuilder: (context, index) {
                                          final acara = filteredAcara[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) => DetailAcaraScreen(
                                                          id: acara["id"].toString(),
                                                          userId: userId,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Container(
                                                      height: 160,
                                                      width: 160,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: const BorderRadius.only(
                                                          bottomRight: Radius.circular(16),
                                                          topLeft: Radius.circular(16),
                                                          bottomLeft: Radius.circular(16),
                                                          topRight: Radius.circular(16),
                                                        ),
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                            acara['gambar'] ?? 'assets/images/event.jpg',
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
                                                                begin: Alignment.bottomCenter,
                                                                end: Alignment.center,
                                                                colors: [
                                                                  Colors.black.withAlpha(100),
                                                                  Colors.black.withAlpha(10),
                                                                ],
                                                              ),
                                                              borderRadius: const BorderRadius.only(
                                                                bottomRight: Radius.circular(16),
                                                                topLeft: Radius.circular(16),
                                                                bottomLeft: Radius.circular(16),
                                                                topRight: Radius.circular(16),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                              left: 8,
                                                              right: 8,
                                                              bottom: 8,
                                                            ),
                                                            child: Align(
                                                              alignment: Alignment.bottomLeft,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      acara['acara_nama'] ?? '',
                                                                      textAlign: TextAlign.left,
                                                                      style: const TextStyle(
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.w900,
                                                                        color: Colors.white,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons.location_on,
                                                                        color: Colors.white,
                                                                        size: 12,
                                                                      ),
                                                                      const SizedBox(width: 4),
                                                                      Flexible(
                                                                        child: Text(
                                                                          acara['tempat'] ?? '',
                                                                          style: const TextStyle(
                                                                            fontSize: 14,
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w300,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
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
                                                        color: AppColors.secondary,
                                                        shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.only(
                                                            bottomLeft: Radius.circular(16),
                                                            topRight: Radius.circular(16),
                                                          ),
                                                        ),
                                                        elevation: 0,
                                                        child: SizedBox(
                                                          width: 72,
                                                          height: 36,
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                const Icon(
                                                                  Icons.access_time_filled_rounded,
                                                                  color: AppColors.primary,
                                                                  size: 16,
                                                                ),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  (acara['waktu'] is TimeOfDay
                                                                      ? acara['waktu'].hour.toString().padLeft(2, '0') +
                                                                          ':' +
                                                                          acara['waktu'].minute.toString().padLeft(
                                                                            2,
                                                                            '0',
                                                                          )
                                                                      : (acara['waktu']?.toString() ?? '')),
                                                                  style: const TextStyle(
                                                                    color: AppColors.primary,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 12,
                                                                  ),
                                                                  textAlign: TextAlign.center,
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

                      const SizedBox(height: 24),

                      // Pengumuman
                      _isLoading
                          ? buildPengumumanShimmer()
                          : _pengumumanList.isEmpty
                          ? Center(
                            child: const CustomNotFound(
                              text: "Gagal memuat data pengumuman :(",
                              textColor: AppColors.brown1,
                              imagePath: 'assets/images/data_not_found.png',
                            ),
                          )
                          : SizedBox(
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
                                      MaterialPageRoute(builder: (context) => PengumumanListScreen()),
                                    ).then((result) {
                                      if (result == 'reload') {
                                        initAll();
                                      }
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 140,
                                        decoration: BoxDecoration(color: AppColors.secondary),
                                        padding: const EdgeInsets.all(16.0),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8, right: 128, top: 8, bottom: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      pengumuman["judul"] ?? '',
                                                      style: const TextStyle(
                                                        color: AppColors.primary,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      pengumuman["detail"].replaceAll(RegExp(r'<[^>]*>'), '').trim(),
                                                      style: const TextStyle(color: AppColors.primary, fontSize: 14),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
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
                      const SizedBox(height: 16),
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
              backgroundColor: AppColors.brown1,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PengumumanListScreen())).then((result) {
                  if (result == 'reload') {
                    initAll();
                  }
                });
              },
              child: const Icon(
                Icons.campaign, // megaphone icon
                color: Colors.white,
              ),
            ),
            if (countUnreadPengumuman > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    countUnreadPengumuman.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
          ],
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
    child: Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 84.0, bottom: 8.0),
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
  return SizedBox(
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
                  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 128, top: 8, bottom: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 180, height: 24, color: Colors.white),
                        const SizedBox(height: 12),
                        Container(width: 120, height: 16, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 100, height: 16, color: Colors.white),
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
  );
}
