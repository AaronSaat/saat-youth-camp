import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:syc/screens/form_evaluasi_screen.dart';
import 'package:syc/screens/form_komitmen_screen.dart';
import 'package:syc/widgets/custom_count_up.dart';
import 'package:syc/widgets/custom_snackbar.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'evaluasi_komitmen_list_screen.dart';

class DetailAcaraScreen extends StatefulWidget {
  final int id;
  final int hari;
  final String userId;
  const DetailAcaraScreen({
    super.key,
    required this.id,
    required this.hari,
    required this.userId,
  });

  @override
  State<DetailAcaraScreen> createState() => _DetailAcaraScreenState();
}

class _DetailAcaraScreenState extends State<DetailAcaraScreen> {
  bool _isLoading = true;
  List<dynamic>? _dataAcara;
  Map<String, String>? _userData;
  bool _evaluasiDone = false;

  // progress
  Map<String, String> _evaluasiDoneMap = {};
  Map<String, String> _countUserMapPanitia = {};

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final Map<String, String> userData = await loadUserFromPrefs();
      final List<dynamic> acaraList = await ApiService.getAcaraById(
        context,
        widget.id,
      );

      if (userData['role']!.toLowerCase().contains('peserta')) {
        final evaluasiDone = await ApiService.getEvaluasiByPesertaByAcara(
          context,
          widget.userId,
          widget.id,
        );

        if (!mounted) return;
        setState(() {
          _evaluasiDone =
              evaluasiDone['status'] == 404
                  ? false
                  : (evaluasiDone['success'] ?? false);
          print('Evaluasi Done: $_evaluasiDone');
        });
      }

      if (userData['role']!.toLowerCase().contains('panitia')) {
        final evaluasiList = await ApiService.getCountEvaluasiAnsweredByAcara(
          context,
          widget.id.toString(),
        );
        final _countUser = await ApiService.getCountUser(context);
        if (!mounted) return;
        setState(() {
          _evaluasiDoneMap = evaluasiList.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          );
          _countUserMapPanitia = _countUser.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          );
          print('Count User Map: $_countUserMapPanitia');
          print('Evaluasi Done: $_evaluasiDoneMap');
        });
      }

      print('User list: $userData');
      print('Acara list: $acaraList');
      if (!mounted) return;
      setState(() {
        _dataAcara = acaraList.isNotEmpty ? acaraList : null;
        _userData = userData;

        print('Data Acara : $_dataAcara');
        print('User Data dari SharedPreferences: $_userData');
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      // Bisa tampilkan error snackbar jika perlu
    }
  }

  Future<Map<String, String>> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, String> userData = {};
    for (final key in keys) {
      final value = prefs.getString(key);
      if (value != null) {
        userData[key] = value;
      }
    }
    return userData;
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
                                'Hari ke-${_dataAcara?[0]["hari"] ?? '-'}, Jam ${_dataAcara?[0]["waktu"] ?? '-'}',
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
                              if (_dataAcara != null &&
                                  _dataAcara![0]["pembicara"] != null &&
                                  (_dataAcara![0]["pembicara"] as String)
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
                                                '$tanggalStr $waktuStr'
                                                    .trim()
                                                    .replaceAll('/', '-')
                                                    .replaceAll('.', ':'),
                                              );
                                            } catch (_) {
                                              acaraDateTime = null;
                                            }
                                            // final now = DateTime.now();
                                            final now = DateTime(
                                              2026,
                                              1,
                                              1,
                                              4,
                                              45,
                                              0,
                                            ); // hardcode, [DEVELOPMENT NOTES] nanti hapus
                                            final diff =
                                                acaraDateTime != null
                                                    ? now
                                                        .difference(
                                                          acaraDateTime,
                                                        )
                                                        .inMinutes
                                                    : null;
                                            final canEvaluate =
                                                diff != null && diff > 60;
                                            print(
                                              'MBEK: $acaraDateTime, Now: $now, Diff: $diff, Can Evaluate: $canEvaluate, timezone device: ${now.timeZoneName}',
                                            );
                                            return ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    canEvaluate
                                                        ? AppColors.brown1
                                                        : AppColors.grey4,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(32),
                                                ),
                                              ),
                                              onPressed:
                                                  canEvaluate
                                                      ? () {
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
                                                        );
                                                      }
                                                      : () {
                                                        showCustomSnackBar(
                                                          context,
                                                          'Evaluasi dapat diakses 1 jam setelah acara dimulai.',
                                                        );
                                                      },
                                              child: const Text(
                                                'EVALUASI',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
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
