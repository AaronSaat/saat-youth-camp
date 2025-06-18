import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:syc/screens/form_evaluasi_screen.dart';
import 'package:syc/screens/form_komitmen_screen.dart';
import 'package:syc/widgets/custom_snackbar.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'evaluasi_komitmen_list_screen.dart';

class DetailAcaraScreen extends StatefulWidget {
  final int id;
  final int hari;
  final String userId;
  const DetailAcaraScreen({super.key, required this.id, required this.hari, required this.userId});

  @override
  State<DetailAcaraScreen> createState() => _DetailAcaraScreenState();
}

class _DetailAcaraScreenState extends State<DetailAcaraScreen> {
  bool _isLoading = true;
  List<dynamic>? _dataAcara;
  Map<String, String>? _userData;
  bool _evaluasiDone = false;
  bool _komitmenDone = false;

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
      final List<dynamic> acaraList = await ApiService.getAcaraById(context, widget.id);
      final komitmenDone = await ApiService.getKomitmenByPesertaByDay(context, widget.userId, widget.hari);
      final evaluasiDone = await ApiService.getEvaluasiByPesertaByAcara(context, widget.userId, widget.id);

      print('User list: $userData');
      print('Acara list: $acaraList');
      if (!mounted) return;
      setState(() {
        _dataAcara = acaraList.isNotEmpty ? acaraList : null;
        _userData = userData;
        _evaluasiDone = evaluasiDone['status'] == 404 ? false : (evaluasiDone['success'] ?? false);
        _komitmenDone = komitmenDone['status'] == 404 ? false : (komitmenDone['success'] ?? false);
        print('Data Acara : $_dataAcara');
        print('User Data dari SharedPreferences: $_userData');
        print('Evaluasi Done: $_evaluasiDone');
        print('Komitmen Done: $_komitmenDone');
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
                : Text(_dataAcara?[0]["acara_nama"] ?? '-', style: TextStyle(fontSize: 18, color: Colors.white)),
        leading: Navigator.canPop(context) ? BackButton(color: Colors.white) : null,
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
                              _dataAcara?[0]["acara_nama"] ?? '-',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hari ke-${_dataAcara?[0]["hari"] ?? '-'}, Jam ${_dataAcara?[0]["waktu"] ?? '-'}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                            ),
                            const SizedBox(height: 8),
                            Text('Tempat: ${_dataAcara?[0]["tempat"] ?? '-'}', style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_dataAcara?[0]["acara_deskripsi"] ?? '-', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 16),
                            if (_dataAcara != null &&
                                _dataAcara![0]["pembicara"] != null &&
                                (_dataAcara![0]["pembicara"] as String).isNotEmpty) ...[
                              const Divider(),
                              const SizedBox(height: 16),
                              const Text('Pembicara', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _dataAcara![0]["pembicara"],
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        const Text('Title / Jabatan Pembicara', style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 24),
                            if (_userData != null && (_userData!['role']?.toLowerCase() == 'peserta') && !_evaluasiDone)
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.brown1,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => FormEvaluasiScreen(
                                                    userId: _userData!['id']!,
                                                    acaraHariId: _dataAcara![0]['id'],
                                                  ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'EVALUASI',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
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
