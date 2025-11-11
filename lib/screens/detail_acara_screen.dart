import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:syc/screens/form_evaluasi_screen.dart';
import 'package:syc/screens/evaluasi_komitmen_view_screen.dart';
import 'package:syc/widgets/custom_count_up.dart';
import 'package:syc/widgets/custom_snackbar.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import '../utils/global_variables.dart';

class DetailAcaraScreen extends StatefulWidget {
  final String id;
  final String userId;
  const DetailAcaraScreen({super.key, required this.id, required this.userId});

  @override
  State<DetailAcaraScreen> createState() => _DetailAcaraScreenState();
}

class _DetailAcaraScreenState extends State<DetailAcaraScreen> {
  bool _isLoading = true;
  List<dynamic>? _dataAcara;
  Map<String, String>? _userData;
  bool _evaluasiDone = false;

  // Notification preferences for this acara
  bool _notifReminderEnabled = false; // 15 minutes before
  bool _notifEvaluasiEnabled = false; // 1 hour after
  final NotificationService _notificationService = NotificationService();
  DateTime? _scheduledReminderTime;
  DateTime? _scheduledEvaluasiTime;

  // progress
  Map<String, String> _evaluasiDoneMap = {};
  Map<String, String> _countUserMapPanitia = {};

  // [DEVELOPMENT NOTES] nanti hapus
  // DateTime _today = DateTime.now();
  late DateTime _today;
  late TimeOfDay _timeOfDay;
  late DateTime _now;

  @override
  void initState() {
    super.initState();

    //[DEVELOPMENT NOTES] untuk testing, nanti dihapus
    setState(() {
      _today = GlobalVariables.today;
      _timeOfDay = GlobalVariables.timeOfDay;
      _now = DateTime(
        _today.year,
        _today.month,
        _today.day,
        _timeOfDay.hour,
        _timeOfDay.minute,
      );
    });
    print(
      '🎯 DetailAcaraScreen initialized with: ID=${widget.id}, UserId=${widget.userId}',
    );
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await loadUserData();
      await loadAcaraDetail();
      await _loadNotifPref();
      if (_userData!['role']!.toLowerCase().contains('panitia')) {
        print('Evaluasi done: sebagai panitia');
        await loadEvaluasiProgresByPesertaByAcara();
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error in initAll: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showCustomSnackBar(
        context,
        'Gagal memuat data. Silakan coba lagi.',
        isSuccess: false,
      );
    }
  }

  Future<void> _loadNotifPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reminderKey = 'notif_acara_${widget.id}_reminder';
      final evalKey = 'notif_acara_${widget.id}_evaluasi';
      final enabledReminder = prefs.getBool(reminderKey) ?? false;
      final enabledEval = prefs.getBool(evalKey) ?? false;
      final timeKey = 'notif_acara_${widget.id}_time';
      final evalTimeKey = 'notif_acara_${widget.id}_eval_time';
      final timeStr = prefs.getString(timeKey);
      final evalTimeStr = prefs.getString(evalTimeKey);
      final parsedTime = timeStr != null ? DateTime.tryParse(timeStr) : null;
      final parsedEvalTime =
          evalTimeStr != null ? DateTime.tryParse(evalTimeStr) : null;
      if (!mounted) return;
      setState(() {
        _notifReminderEnabled = enabledReminder;
        _notifEvaluasiEnabled = enabledEval;
        _scheduledReminderTime = parsedTime;
        _scheduledEvaluasiTime = parsedEvalTime;
      });
    } catch (e) {
      print('❌ Failed to load notif pref: $e');
    }
  }

  // Handler for reminder (15 minutes before)
  Future<void> _onReminderToggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final reminderKey = 'notif_acara_${widget.id}_reminder';

    final notifId =
        int.tryParse(widget.id.toString()) ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (value) {
      if (_dataAcara == null || _dataAcara!.isEmpty) {
        showCustomSnackBar(
          context,
          'Data acara belum dimuat',
          isSuccess: false,
        );
        return;
      }
      final acara = _dataAcara![0];
      final tanggalStr = acara['tanggal'] ?? '';
      final waktuStr = acara['waktu'] ?? '';
      if (tanggalStr.isEmpty || waktuStr.isEmpty) {
        showCustomSnackBar(
          context,
          'Data waktu acara tidak tersedia',
          isSuccess: false,
        );
        return;
      }
      DateTime eventStart;
      try {
        eventStart = DateTime.parse(
          '$tanggalStr ${waktuStr.length == 5 ? waktuStr : '00:00'}:00',
        );
      } catch (e) {
        showCustomSnackBar(
          context,
          'Format tanggal/waktu acara tidak valid',
          isSuccess: false,
        );
        return;
      }
      final scheduled = eventStart.subtract(const Duration(minutes: 15));
      if (scheduled.isBefore(DateTime.now())) {
        showCustomSnackBar(
          context,
          'Waktu acara sudah lewat. Tidak dapat menjadwalkan notifikasi.',
        );
        return;
      }
      await _notificationService.initialize();
      await _notificationService.scheduledNotification(
        id: notifId,
        title: '⏰ ${acara['acara_nama'] ?? 'Acara'} akan dimulai',
        body: '${acara['acara_nama'] ?? 'Acara'} akan dimulai dalam 15 menit',
        scheduledTime: scheduled,
        payload: 'splash',
      );
      await prefs.setBool(reminderKey, true);
      await prefs.setString(
        'notif_acara_${widget.id}_time',
        scheduled.toIso8601String(),
      );
      print('✅ Scheduled reminder notif (ID: $notifId) for $scheduled');
      if (!mounted) return;
      setState(() {
        _notifReminderEnabled = true;
        _scheduledReminderTime = scheduled;
      });
      showCustomSnackBar(
        context,
        'Notifikasi acara berhasil dijadwalkan pada ${_formatDateTime(scheduled.toLocal())}',
      );
    } else {
      try {
        await _notificationService.cancelNotificationById(notifId);
        await prefs.remove(reminderKey);
        await prefs.remove('notif_acara_${widget.id}_time');
        if (!mounted) return;
        setState(() {
          _notifReminderEnabled = false;
          _scheduledReminderTime = null;
        });
        showCustomSnackBar(context, 'Notifikasi acara dibatalkan');
      } catch (e) {
        print('❌ Error cancelling reminder: $e');
        showCustomSnackBar(
          context,
          'Gagal membatalkan notifikasi',
          isSuccess: false,
        );
      }
    }
  }

  // Handler for evaluasi (1 hour after event start)
  Future<void> _onEvaluasiToggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final evalKey = 'notif_acara_${widget.id}_evaluasi';

    final notifId =
        int.tryParse(widget.id.toString()) ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final evalNotifId = notifId + 1000000;

    if (value) {
      if (_dataAcara == null || _dataAcara!.isEmpty) {
        showCustomSnackBar(
          context,
          'Data acara belum dimuat',
          isSuccess: false,
        );
        return;
      }
      final acara = _dataAcara![0];
      final tanggalStr = acara['tanggal'] ?? '';
      final waktuStr = acara['waktu'] ?? '';
      if (tanggalStr.isEmpty || waktuStr.isEmpty) {
        showCustomSnackBar(
          context,
          'Data waktu acara tidak tersedia',
          isSuccess: false,
        );
        return;
      }
      DateTime eventStart;
      try {
        eventStart = DateTime.parse(
          '$tanggalStr ${waktuStr.length == 5 ? waktuStr : '00:00'}:00',
        );
      } catch (e) {
        showCustomSnackBar(
          context,
          'Format tanggal/waktu acara tidak valid',
          isSuccess: false,
        );
        return;
      }
      final scheduledEval = eventStart.add(const Duration(hours: 1));
      if (scheduledEval.isBefore(DateTime.now())) {
        showCustomSnackBar(
          context,
          'Waktu evaluasi sudah lewat. Tidak dapat menjadwalkan notifikasi.',
        );
        return;
      }
      await _notificationService.initialize();
      await _notificationService.scheduledNotification(
        id: evalNotifId,
        title: '📝 Waktu Evaluasi',
        body:
            'Silakan isi evaluasi untuk acara: ${acara['acara_nama'] ?? 'Acara'}',
        scheduledTime: scheduledEval,
        payload: 'splash',
      );
      await prefs.setBool(evalKey, true);
      await prefs.setString(
        'notif_acara_${widget.id}_eval_time',
        scheduledEval.toIso8601String(),
      );
      print('✅ Scheduled evaluasi notif (ID: $evalNotifId) for $scheduledEval');
      if (!mounted) return;
      setState(() {
        _notifEvaluasiEnabled = true;
        _scheduledEvaluasiTime = scheduledEval;
      });
      showCustomSnackBar(
        context,
        'Notifikasi evaluasi berhasil dijadwalkan pada ${_formatDateTime(scheduledEval.toLocal())}',
      );
    } else {
      try {
        await _notificationService.cancelNotificationById(evalNotifId);
        await prefs.remove(evalKey);
        await prefs.remove('notif_acara_${widget.id}_eval_time');
        if (!mounted) return;
        setState(() {
          _notifEvaluasiEnabled = false;
          _scheduledEvaluasiTime = null;
        });
        showCustomSnackBar(context, 'Notifikasi evaluasi dibatalkan');
      } catch (e) {
        print('❌ Error cancelling evaluasi: $e');
        showCustomSnackBar(
          context,
          'Gagal membatalkan notifikasi',
          isSuccess: false,
        );
      }
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _formatDateTime(DateTime dt) {
    // Format: yyyy-MM-dd HH:mm (no milliseconds)
    return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
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
      _userData = userData;
    });
  }

  Future<void> loadAcaraDetail() async {
    if (!mounted) return;
    setState(() {});

    try {
      final List<dynamic> acaraList = await ApiService.getAcaraById(
        context,
        widget.id,
      );
      if (!mounted) return;
      if (acaraList.isEmpty) {
        // Jika data kosong, isi dummy agar tidak error/freeze
        final dummy = [
          {
            "id": widget.id,
            "acara_nama": "(Data tidak ditemukan)",
            "hari": "-",
            "waktu": "-",
            "tempat": "-",
            "acara_deskripsi": "Data acara tidak tersedia.",
            "pembicara": "-",
            "tanggal": "-",
          },
        ];
        setState(() {
          _dataAcara = dummy;
        });
      } else {
        setState(() {
          _dataAcara = acaraList;
          print('✅ Data Acara loaded: $_dataAcara');
        });
      }
    } catch (e) {
      print('❌ Error loading acara detail: $e');
      if (!mounted) return;
      // Jika error, isi dummy juga
      final dummy = [
        {
          "id": widget.id,
          "acara_nama": "(Data tidak ditemukan)",
          "hari": "-",
          "waktu": "-",
          "tempat": "-",
          "acara_deskripsi": "Data acara tidak tersedia.",
          "pembicara": "-",
          "tanggal": "-",
        },
      ];
      setState(() {
        _dataAcara = dummy;
      });
      showCustomSnackBar(
        context,
        'Gagal memuat detail acara. Menampilkan data kosong.',
        isSuccess: false,
      );
    }
  }

  Future<void> loadEvaluasiProgresByPesertaByAcara() async {
    if (!mounted) return;
    setState(() {});

    try {
      final evaluasiDone = await ApiService.getEvaluasiByPesertaByAcara(
        context,
        widget.userId,
        widget.id,
      );

      final evaluasiList = await ApiService.getCountEvaluasiAnsweredByAcara(
        context,
        widget.id.toString(),
      );

      final _countUser = await ApiService.getCountUser(context);
      if (!mounted) return;
      setState(() {
        _evaluasiDone =
            evaluasiDone['status'] == 404
                ? false
                : (evaluasiDone['success'] ?? false);

        _evaluasiDoneMap = evaluasiList.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
        _countUserMapPanitia = _countUser.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );

        print('✅ Evaluasi Done: $_evaluasiDone');
        print('✅ Count User Map: $_countUserMapPanitia');
        print('✅ Evaluasi Done Map: $_evaluasiDoneMap');
      });
    } catch (e) {
      print('❌ Error loading evaluasi progress: $e');
      if (!mounted) return;
      setState(() {
        _evaluasiDone = false;
        _evaluasiDoneMap = {};
        _countUserMapPanitia = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            _isLoading
                ? const SizedBox.shrink()
                : Text(
                  _dataAcara?[0]["acara_nama"] ?? '-',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
        leading:
            Navigator.canPop(context) ? BackButton(color: Colors.white) : null,
      ),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_fade.jpg',
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
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                    top: 250.0,
                  ),
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : (_dataAcara == null || _dataAcara!.isEmpty)
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/data_not_found.png',
                                  height: 100,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Gagal memuat detail acara :(",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.brown1,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _dataAcara?[0]["acara_nama"] ?? '-',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hari ke-${_dataAcara?[0]["hari"] ?? '-'}, Jam ${_dataAcara?[0]["waktu"] ?? '-'}'
                                '${_dataAcara?[0]["waktu_end"] != null && (_dataAcara?[0]["waktu_end"] as String).isNotEmpty ? ' - ${_dataAcara?[0]["waktu_end"]}' : ''}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tempat: ${_dataAcara?[0]["tempat"] ?? '-'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              const Text(
                                'Deskripsi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _dataAcara?[0]["acara_deskripsi"] ?? '-',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 16),
                              if ((_dataAcara![0]["pembicara"] as String?) !=
                                      null &&
                                  (_dataAcara![0]["pembicara"] as String)
                                      .trim()
                                      .isNotEmpty) ...[
                                const Divider(),
                                const SizedBox(height: 16),
                                const Text(
                                  'Pembicara',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        'assets/logos/stt_saat.png',
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _dataAcara![0]["pembicara"],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            'Title / Jabatan Pembicara',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              if (Platform.isIOS) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Pengingat notifikasi',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Two switches: Reminder (15m before) and Evaluasi (1h after)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                _notifReminderEnabled
                                                    ? 'On'
                                                    : 'Off',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Switch.adaptive(
                                                value: _notifReminderEnabled,
                                                onChanged: (val) {
                                                  _onReminderToggle(val);
                                                },
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Acara',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          // Tampilkan switch "Evaluasi" hanya jika user adalah panitia
                                          if (_userData != null &&
                                              _userData!['role'] != null &&
                                              (_userData!['role']!
                                                      .toLowerCase()
                                                      .contains('peserta') ||
                                                  _userData!['role']!
                                                      .toLowerCase()
                                                      .contains('pembina')) &&
                                              _dataAcara != null &&
                                              _dataAcara!.isNotEmpty &&
                                              _dataAcara![0]['is_eval']
                                                      ?.toString() ==
                                                  '1') ...[
                                            const SizedBox(width: 12),
                                            Column(
                                              children: [
                                                Text(
                                                  _notifEvaluasiEnabled
                                                      ? 'On'
                                                      : 'Off',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Switch.adaptive(
                                                  value: _notifEvaluasiEnabled,
                                                  onChanged: (val) {
                                                    _onEvaluasiToggle(val);
                                                  },
                                                ),
                                                const SizedBox(height: 4),
                                                const Text(
                                                  'Evaluasi',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Show scheduled times if available
                                if (_scheduledReminderTime != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: Text(
                                      'Reminder: ${_formatDateTime(_scheduledReminderTime!.toLocal())}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                if (_scheduledEvaluasiTime != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                      vertical: 4.0,
                                    ),
                                    child: Text(
                                      'Evaluasi: ${_formatDateTime(_scheduledEvaluasiTime!.toLocal())}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                              ],
                              // DEBUG: tombol untuk scheduling cepat (hapus sebelum release)
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //     horizontal: 4.0,
                              //     vertical: 8.0,
                              //   ),
                              //   child: ElevatedButton.icon(
                              //     style: ElevatedButton.styleFrom(
                              //       backgroundColor: Colors.orange,
                              //     ),
                              //     icon: const Icon(Icons.bug_report, size: 16),
                              //     label: const Text(
                              //       'DEBUG: Schedule quick test (15s / 30s)',
                              //     ),
                              //     onPressed: () async {
                              //       try {
                              //         final notifId =
                              //             int.tryParse(widget.id) ??
                              //             DateTime.now()
                              //                     .millisecondsSinceEpoch ~/
                              //                 1000;
                              //         final evalNotifId = notifId + 1000000;
                              //         await _notificationService.initialize();
                              //         await _notificationService
                              //             .scheduledNotification(
                              //               id: notifId,
                              //               title: '🔔 Test Reminder',
                              //               body:
                              //                   'Test reminder untuk acara ${widget.id}',
                              //               scheduledTime: DateTime.now().add(
                              //                 const Duration(seconds: 15),
                              //               ),
                              //               payload: 'splash',
                              //             );
                              //         await _notificationService
                              //             .scheduledNotification(
                              //               id: evalNotifId,
                              //               title: '📝 Test Evaluasi',
                              //               body:
                              //                   'Test evaluasi untuk acara ${widget.id}',
                              //               scheduledTime: DateTime.now().add(
                              //                 const Duration(seconds: 30),
                              //               ),
                              //               payload:
                              //                   'splash',
                              //             );
                              //         showCustomSnackBar(
                              //           context,
                              //           'Test notifications scheduled: 15s (reminder), 30s (evaluasi)',
                              //         );
                              //       } catch (e) {
                              //         print('❌ Debug schedule failed: $e');
                              //         showCustomSnackBar(
                              //           context,
                              //           'Gagal menjadwalkan test notifications',
                              //           isSuccess: false,
                              //         );
                              //       }
                              //     },
                              //   ),
                              // ),
                              const SizedBox(height: 24),
                              if (_userData != null &&
                                  _userData!['role'] != null &&
                                  (_userData!['role']!.toLowerCase().contains(
                                        'peserta',
                                      ) ||
                                      _userData!['role']!
                                          .toLowerCase()
                                          .contains('pembina')) &&
                                  !_evaluasiDone)
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: Builder(
                                          builder: (context) {
                                            // Ambil tanggal dan waktu dari _dataAcara[0]
                                            final acara = _dataAcara![0];
                                            final tanggalStr =
                                                acara['tanggal'] ?? '';
                                            final waktuStr =
                                                acara['waktu'] ?? '';
                                            DateTime? acaraDateTime;
                                            try {
                                              // Asumsi format tanggal: yyyy-MM-dd, waktu: HH:mm
                                              acaraDateTime = DateTime.parse(
                                                '$tanggalStr $waktuStr '
                                                    .trim()
                                                    .replaceAll('/', '-')
                                                    .replaceAll('.', ':'),
                                              ).add(
                                                const Duration(hours: 1),
                                              ); // tambah 1 jam
                                            } catch (_) {
                                              acaraDateTime = null;
                                            }
                                            final diff =
                                                acaraDateTime != null
                                                    ? _now
                                                        .difference(
                                                          acaraDateTime,
                                                        )
                                                        .inMinutes
                                                    : null;
                                            final canEvaluate =
                                                diff != null && diff >= 60;
                                            print(
                                              'Acara DateTime: $acaraDateTime, Now: $_now, Diff: $diff minutes, Can Evaluate: $canEvaluate',
                                            );
                                            return FutureBuilder(
                                              future:
                                                  canEvaluate
                                                      ? ApiService.getEvaluasiByPesertaByAcara(
                                                        context,
                                                        _userData!['id']!,
                                                        _dataAcara![0]['id'],
                                                      )
                                                      : null,
                                              builder: (context, snapshot) {
                                                bool evaluasiDone = false;
                                                if (snapshot.connectionState ==
                                                        ConnectionState.done &&
                                                    snapshot.hasData) {
                                                  final result = snapshot.data;
                                                  evaluasiDone =
                                                      result != null &&
                                                      result['success'] == true;
                                                }
                                                if (_dataAcara![0]['is_eval']
                                                        ?.toString() ==
                                                    '1') {
                                                  return ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          canEvaluate
                                                              ? AppColors.brown1
                                                              : AppColors.grey4,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              32,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed:
                                                        canEvaluate
                                                            ? () async {
                                                              try {
                                                                final result =
                                                                    await ApiService.getEvaluasiByPesertaByAcara(
                                                                      context,
                                                                      _userData!['id']!,
                                                                      _dataAcara![0]['id'],
                                                                    );
                                                                bool
                                                                evaluasiDone =
                                                                    result['success'] ==
                                                                    true;
                                                                if (evaluasiDone) {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (
                                                                            context,
                                                                          ) => EvaluasiKomitmenViewScreen(
                                                                            type:
                                                                                'Evaluasi',
                                                                            userId:
                                                                                _userData!['id']!,
                                                                            acaraHariId:
                                                                                int.tryParse(
                                                                                  _dataAcara![0]['id'].toString(),
                                                                                ) ??
                                                                                0,
                                                                          ),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (
                                                                            context,
                                                                          ) => FormEvaluasiScreen(
                                                                            userId:
                                                                                _userData!['id']!,
                                                                            acaraHariId:
                                                                                _dataAcara![0]['id'],
                                                                          ),
                                                                    ),
                                                                  ).then((
                                                                    result,
                                                                  ) {
                                                                    if (result ==
                                                                        'reload') {
                                                                      initAll();
                                                                    }
                                                                  });
                                                                }
                                                              } catch (e) {
                                                                showCustomSnackBar(
                                                                  context,
                                                                  'Gagal memeriksa status evaluasi. Silakan coba lagi.',
                                                                  isSuccess:
                                                                      false,
                                                                );
                                                              }
                                                            }
                                                            : () {
                                                              showCustomSnackBar(
                                                                context,
                                                                'Evaluasi dapat dilakukan 1 jam setelah acara.\nWaktu acara: $tanggalStr $waktuStr WIB',
                                                              );
                                                            },
                                                    child: Text(
                                                      evaluasiDone
                                                          ? 'REVIEW EVALUASI'
                                                          : 'EVALUASI',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return const SizedBox.shrink();
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              // counter evaluasi card
                              if (_userData!['role']!.toLowerCase().contains(
                                'panitia',
                              ))
                                Center(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: AppColors.primary,
                                        width: 1,
                                      ),
                                    ),
                                    elevation: 1,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Konter evaluasi acara ini:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CustomCountUp(
                                                target:
                                                    int.tryParse(
                                                      _evaluasiDoneMap["count"] ??
                                                          '0',
                                                    ) ??
                                                    0,
                                                duration: Duration(seconds: 2),
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                '/',
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${_countUserMapPanitia["count"]}',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
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
    );
  }
}
