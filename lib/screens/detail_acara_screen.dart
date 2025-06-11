import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:syc/screens/form_evaluasi_screen.dart';
import 'package:syc/screens/form_komitmen_screen.dart';
import 'package:syc/widgets/custom_snackbar.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'evaluasi_komitmen_list_screen.dart';

class DetailAcaraScreen extends StatefulWidget {
  final int id;
  const DetailAcaraScreen({super.key, required this.id});

  @override
  State<DetailAcaraScreen> createState() => _DetailAcaraScreenState();
}

class _DetailAcaraScreenState extends State<DetailAcaraScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _dataAcara;
  Map<String, String>? _userData;

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
      final Map<String, dynamic> acaraList = await ApiService.getAcaraById(
        context,
        widget.id,
      );
      if (!mounted) return;
      setState(() {
        _dataAcara = acaraList.isNotEmpty ? acaraList['data_acara'] : null;
        _userData = userData;
        print('Data Acara: $_dataAcara');
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
                  _dataAcara?["acara_nama"] ?? '-',
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
          Container(
            margin: const EdgeInsets.only(top: 200),
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 108),
                            Text(
                              _dataAcara?["acara_nama"] ?? '-',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hari ke-${_dataAcara?["hari"] ?? '-'}, Jam ${_dataAcara?["waktu"] ?? '-'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tempat: ${_dataAcara?["tempat"] ?? '-'}',
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
                              _dataAcara?["acara_deskripsi"] ?? '-',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 16),
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
                                        (_dataAcara != null &&
                                                _dataAcara!["pembicara"] !=
                                                    null &&
                                                (_dataAcara!["pembicara"]
                                                        as String)
                                                    .isNotEmpty)
                                            ? _dataAcara!["pembicara"]
                                            : 'Belum ada pembicara',
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
                            const SizedBox(height: 24),
                            if (_userData != null &&
                                (_userData!['role']?.toLowerCase() ==
                                    'peserta'))
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.brown1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              32,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      FormKomitmenScreen(
                                                        userId:
                                                            _userData!['id']!,
                                                        acaraHariId:
                                                            _dataAcara!['hari'],
                                                      ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'KOMITMEN',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.brown1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              32,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      FormEvaluasiScreen(
                                                        userId:
                                                            _userData!['id']!,
                                                        acaraHariId:
                                                            _dataAcara!['id'],
                                                      ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'EVALUASI',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
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
        ],
      ),
    );
  }
}
