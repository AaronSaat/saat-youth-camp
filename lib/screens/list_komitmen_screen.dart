import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/global_variables.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_snackbar.dart';
import 'form_komitmen_screen.dart';
import 'evaluasi_komitmen_view_screen.dart';

class ListKomitmenScreen extends StatefulWidget {
  final String userId;

  const ListKomitmenScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ListKomitmenScreenState createState() => _ListKomitmenScreenState();
}

class _ListKomitmenScreenState extends State<ListKomitmenScreen> {
  List<dynamic> _komitmenList = [];
  List<dynamic> _komitmenDoneList = [];
  Map<String, String> _dataUser = {};
  bool _isLoading = true;
  // Komitmen notification setting (default OFF)
  bool _notifKomitmenEnabled = false;
  // final NotificationService _notificationService = NotificationService();

  // [DEVELOPMENT NOTES] nanti hapus
  // DateTime _today = DateTime.now();
  // DateTime _now = DateTime(2025, 12, 31, 0, 0, 0);
  late DateTime _today;
  late TimeOfDay _timeOfDay;
  late DateTime _now;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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
    initAll();
  }

  Future<void> initAll({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await loadUserData();
      // Load notif setting early so the AppBar icon reflects user preference
      await _loadNotifSetting();
      // load komitmen (notification scheduling will run after komitmen is loaded)
      await loadKomitmen(forceRefresh: forceRefresh);
      // After komitmen is available, schedule notifications if the pref is enabled
      await _maybeScheduleKomitmenNotifications();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotifSetting() async {
    try {
      if (!mounted) return;
      setState(() {
        _notifKomitmenEnabled = false;
      });
      final prefs = await SharedPreferences.getInstance();
      final key = 'notif_komitmen_${widget.userId}';
      // If pref missing, default to disabled (false)
      final enabled = prefs.getBool(key) ?? false;
      if (!mounted) return;
      setState(() {
        _notifKomitmenEnabled = enabled;
      });
    } catch (e) {
      // ignore errors and keep default false
      print('Error loading komitmen notif setting: $e');
    }
  }

  /// After komitmen list is loaded, schedule notifications if the user has
  /// enabled komitmen notifications and we don't already have saved notif ids.
  Future<void> _maybeScheduleKomitmenNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifIdsKey = 'notif_komitmen_ids_${widget.userId}';
      final existingIds = prefs.getStringList(notifIdsKey) ?? [];
      if (_notifKomitmenEnabled &&
          (existingIds.isEmpty) &&
          _komitmenList.isNotEmpty) {
        await _scheduleKomitmenNotifications();
      }
    } catch (e) {
      print('Error checking/scheduling komitmen notifications: $e');
    }
  }

  Future<void> _toggleNotifKomitmen(bool enabled) async {
    // Only allow peserta role to toggle this setting
    final role = _dataUser['role'] ?? '';
    if (role.toString().toLowerCase() != 'peserta') {
      showCustomSnackBar(
        context,
        'Hanya peserta yang dapat mengatur notifikasi komitmen.',
        isSuccess: false,
      );
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'notif_komitmen_${widget.userId}';
      await prefs.setBool(key, enabled);
      if (!mounted) return;
      setState(() {
        _notifKomitmenEnabled = enabled;
      });
      if (enabled) {
        await _scheduleKomitmenNotifications();
      } else {
        await _cancelKomitmenNotifications();
      }
      showCustomSnackBar(
        context,
        enabled
            ? 'Notifikasi Komitmen diaktifkan'
            : 'Notifikasi Komitmen dinonaktifkan',
        isSuccess: true,
      );
    } catch (e) {
      print('Error saving komitmen notif setting: $e');
      showCustomSnackBar(
        context,
        'Gagal menyimpan pengaturan notifikasi',
        isSuccess: false,
      );
    }
  }

  /// Schedule up to 3 reminders (one per day) at 21:00 before each komitmen date.
  /// Assumption: schedule reminders for the 3 days prior to the komitmen date
  /// (i.e. -3, -2, -1 days) at 21:00 local time. Only future scheduled times
  /// will be created. Persist the notification ids so they can be cancelled.
  Future<void> _scheduleKomitmenNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifIdsKey = 'notif_komitmen_ids_${widget.userId}';
      final now = DateTime.now();
      final List<String> scheduledIds = [];

      for (final komitmen in _komitmenList) {
        final tanggal = komitmen['tanggal']?.toString() ?? '';
        final hari = komitmen['hari']?.toString() ?? '';
        if (tanggal.isEmpty) continue;

        // Parse komitmen date and schedule ONE reminder at 21:00 on that date
        try {
          final scheduledDate = DateTime.parse('$tanggal 21:00:00');

          if (scheduledDate.isBefore(now)) continue; // skip past

          // Build a deterministic id per komitmen: userBucket * 100 + hariNum
          final baseUser =
              int.tryParse(widget.userId) ??
              DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final hariNum = int.tryParse(hari) ?? 0;
          final notifId = baseUser.abs() % 100000 * 100 + hariNum;

          final title = '🙏 Komitmen Hari ke-$hari';
          final body = 'Jangan lupa mengisi komitmen untuk tanggal $tanggal.';
          final payload = 'splash';

          // await _notificationService.scheduledNotification(
          //   id: notifId,
          //   title: title,
          //   body: body,
          //   scheduledTime: scheduledDate,
          //   payload: payload,
          // );
          print('Scheduled komitmen notif (ID: $notifId) for $scheduledDate');

          scheduledIds.add(notifId.toString());
        } catch (e) {
          print('Error scheduling komitmen reminder for $komitmen: $e');
        }
      }

      if (scheduledIds.isNotEmpty) {
        await prefs.setStringList(notifIdsKey, scheduledIds);
      }
    } catch (e) {
      print('Error scheduling komitmen notifications: $e');
    }
  }

  Future<void> _cancelKomitmenNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifIdsKey = 'notif_komitmen_ids_${widget.userId}';
      final ids = prefs.getStringList(notifIdsKey) ?? [];
      for (final idStr in ids) {
        final id = int.tryParse(idStr);
        if (id != null) {
          // await _notificationService.cancelNotificationById(id);
        }
      }
      await prefs.remove(notifIdsKey);
      print('Scheduled - cancel komitmen notifications: $ids');
    } catch (e) {
      print('Error cancelling komitmen notifications: $e');
    }
  }

  Future<void> loadKomitmen({bool forceRefresh = false}) async {
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    final komitmenKey = 'list_komitmen_${widget.userId}';
    final komitmenDoneKey = 'list_komitmen_done_${widget.userId}';

    if (!forceRefresh) {
      final cachedKomitmen = prefs.getString(komitmenKey);
      final cachedDone = prefs.getString(komitmenDoneKey);
      if (cachedKomitmen != null && cachedDone != null) {
        final komitmenList = jsonDecode(cachedKomitmen);
        final komitmenDoneList = jsonDecode(cachedDone);
        setState(() {
          _komitmenList = komitmenList ?? [];
          // For testing: override cached data with sample entries
          // try {
          //   komitmenList.clear();
          //   komitmenList.addAll([
          //     {'hari': 1, 'tanggal': '2025-10-20'},
          //     {'hari': 2, 'tanggal': '2025-10-21'},
          //     {'hari': 3, 'tanggal': '2025-10-22'},
          //   ]);
          // } catch (e) {
          //   // ignore if cached values are not mutable
          // }
          _komitmenDoneList = komitmenDoneList ?? [];
          _isLoading = false;
        });
        print(
          '[PREF_API] Scheduled Komitmen List (from shared pref): $_komitmenList',
        );
        print(
          '[PREF_API] Scheduled Komitmen Done List (from shared pref): $_komitmenDoneList',
        );
        return;
      }
    }

    try {
      final komitmenList = await ApiService().getKomitmen(context);
      _komitmenDoneList = List.filled(komitmenList.length, false);
      for (int i = 0; i < _komitmenDoneList.length; i++) {
        try {
          final result = await ApiService().getKomitmenByPesertaByDay(
            context,
            widget.userId,
            i + 1,
          );
          if (result['success'] == true) {
            _komitmenDoneList[i] = true;
          }
        } catch (e) {}
      }
      await prefs.setString(komitmenKey, jsonEncode(komitmenList));
      await prefs.setString(komitmenDoneKey, jsonEncode(_komitmenDoneList));
      setState(() {
        _komitmenList = komitmenList;
        // _komitmenDoneList sudah di-set di atas
        _isLoading = false;
      });
      print('[PREF_API] Komitmen List (from API): $_komitmenList');
      print('[PREF_API] Komitmen Done List (from API): $_komitmenDoneList');
    } catch (e) {
      print('❌ Gagal memuat list komitmen: $e');
      setState(() {});
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context, 'reload'),
          ),
        ),
        // actions: [
        //   // Only show the bell when the logged-in user is the owner of this
        //   // komitmen list and has role 'Peserta'. Otherwise hide it.
        //   if ((_dataUser['id'] ?? '') == widget.userId &&
        //       ((_dataUser['role'] ?? '').toString().toLowerCase() ==
        //               'peserta' ||
        //           (_dataUser['role'] ?? '').toString().toLowerCase() ==
        //               'pembina') &&
        //       Platform.isIOS)
        //     Padding(
        //       padding: const EdgeInsets.only(right: 8.0),
        //       child: IconButton(
        //         tooltip:
        //             _notifKomitmenEnabled
        //                 ? 'Nonaktifkan Notifikasi'
        //                 : 'Aktifkan Notifikasi',
        //         icon: Icon(
        //           _notifKomitmenEnabled
        //               ? Icons.notifications_active
        //               : Icons.notifications_none,
        //           color: Colors.white,
        //         ),
        //         onPressed: () => _toggleNotifKomitmen(!_notifKomitmenEnabled),
        //       ),
        //     )
        //   else
        //     const SizedBox.shrink(),
        // ],
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
              onRefresh: () => initAll(forceRefresh: true),
              color: AppColors.brown1,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),

                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    bottom: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Image.asset('assets/texts/komitmen.png', height: 96),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? buildShimmerList()
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _komitmenList.length,
                            itemBuilder: (context, index) {
                              final items = _komitmenList;
                              String item;
                              bool? status;
                              final komitmen = items[index];
                              final tanggal = komitmen['tanggal'] ?? '';
                              item = 'Komitmen Hari ${komitmen['hari'] ?? '-'}';
                              status = _komitmenDoneList[index];
                              return CustomCard(
                                text: item,
                                icon:
                                    status == true
                                        ? Icons.check
                                        : Icons.arrow_outward_rounded,
                                onTap: () {
                                  String userId = widget.userId;
                                  int acaraHariId;
                                  acaraHariId = _komitmenList[index]['hari'];
                                  if (status == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                EvaluasiKomitmenViewScreen(
                                                  type: "Komitmen",
                                                  userId: userId,
                                                  acaraHariId: acaraHariId,
                                                ),
                                      ),
                                    );
                                  } else {
                                    if (_dataUser['id'] != widget.userId) {
                                      setState(() {
                                        if (!mounted) return;
                                        showCustomSnackBar(
                                          context,
                                          'Komitmen hanya bisa diisi oleh pemiliknya.',
                                          isSuccess: false,
                                        );
                                      });
                                    } else {
                                      // [DEVELOPMENT NOTES] nanti setting
                                      DateTime tanggalKomitmen = DateTime.parse(
                                        '$tanggal 21:00:00',
                                      );

                                      // Komitmen hanya bisa diisi pada tanggal yang sama atau setelahnya, dan setelah jam 9 malam
                                      if (_now.isBefore(tanggalKomitmen)) {
                                        showCustomSnackBar(
                                          context,
                                          'Komitmen hanya dapat diisi pada tanggal ${tanggal} pukul 21:00.',
                                          isSuccess: false,
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => FormKomitmenScreen(
                                                  userId: userId,
                                                  acaraHariId: acaraHariId,
                                                ),
                                          ),
                                        ).then((result) {
                                          if (result == 'reload') {
                                            initAll(forceRefresh: true);
                                          }
                                        });
                                      }
                                    }
                                  }
                                },
                                iconBackgroundColor: AppColors.brown1,
                                showCheckIcon: status == true,
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

Widget buildShimmerList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(5, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }),
  );
}
