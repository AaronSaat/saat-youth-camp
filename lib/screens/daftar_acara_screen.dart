import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
import 'evaluasi2_screen.dart';
import 'evaluasi3_screen.dart';
// import 'evaluasi4_screen.dart';
import 'evaluasi4_screen.dart';
import 'komitmen_screen.dart';
import 'evaluasi_screen.dart';
import 'detail_acara_screen.dart';
import 'review_evaluasi2_screen.dart';
import 'review_evaluasi3_screen.dart';
import 'review_evaluasi4_screen.dart';
import 'review_komitmen_screen.dart';

class DaftarAcaraScreen extends StatefulWidget {
  const DaftarAcaraScreen({super.key});

  @override
  State<DaftarAcaraScreen> createState() => _DaftarAcaraScreenState();
}

class _DaftarAcaraScreenState extends State<DaftarAcaraScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ambil dari shared preferences
  String currentRole = "";
  String evaluasi2_status = "";
  String evaluasi3_status = "";
  String evaluasi4_status = "";
  String komitmen_status = "";

  final Map<String, List<Map<String, String>>> rundownPerHari = {
    'Day 1': [
      {'title': 'Pendaftaran Ulang', 'evaluasi': 'Evaluasi 2'},
      {'title': 'Opening', 'acara': 'Detail Acara', 'evaluasi': 'Evaluasi 3'},
      {'title': 'KKR 1', 'acara': 'Detail Acara', 'evaluasi': 'Evaluasi 4'},
      {'title': 'Komitmen'},
    ],
    'Day 2': [
      {'title': 'Saat Teduh', 'acara': 'Evaluasi'},
      {'title': 'KKR 2', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Drama Musikal', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Komitmen'},
    ],
    'Day 3': [
      {'title': 'New Year Countdown', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Saat Teduh', 'acara': 'Evaluasi'},
      {'title': 'KKR 3', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Komitmen'},
    ],
    'Day 4': [
      {'title': 'Saat Teduh', 'acara': 'Evaluasi'},
      {'title': 'Closing', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Evaluasi Keseluruhan', 'acara': 'Evaluasi'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _getRoleFromSharedPreferences(); // Ambil role dari SharedPreferences
  }

  // Fungsi untuk mengambil role dari SharedPreferences
  // sekalian untuk progress eval dan
  Future<void> _getRoleFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentRole = prefs.getString('role') ?? '';
      evaluasi2_status = prefs.getString('evaluasi2_status') ?? '';
      evaluasi3_status = prefs.getString('evaluasi3_status') ?? '';
      evaluasi4_status = prefs.getString('evaluasi4_status') ?? '';
      komitmen_status = prefs.getString('komitmen_status') ?? '';
      print("Role: $currentRole");
      print("Evaluasi 2 Status: $evaluasi2_status");
      print("Evaluasi 3 Status: $evaluasi3_status");
      print("Evaluasi 4 Status: $evaluasi4_status");
      print("Komitmen Status: $komitmen_status");
    });
  }

  Widget _buildRundownList(List<Map<String, String>> rundown) {
    return ListView.builder(
      itemCount: rundown.length,
      itemBuilder: (context, index) {
        final item = rundown[index];
        final title = item['title'] ?? '';
        final evaluasi = item['evaluasi'] ?? '';
        final isKomitmen = item['title'] == 'Komitmen';

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  item["title"].toString().toLowerCase().contains('komitmen')
                      ? 'assets/images/komitmen.jpg'
                      : item["title"].toString().toLowerCase().contains('pendaftaran ulang')
                      ? 'assets/images/event_daftar.jpg'
                      : item["title"].toString().toLowerCase().contains('saat teduh')
                      ? 'assets/images/event_saat_teduh.jpg'
                      : item["title"].toString().toLowerCase().contains('new year countdown')
                      ? 'assets/images/event_new_year.jpg'
                      : item["title"].toString().toLowerCase().contains('opening')
                      ? 'assets/images/event_opening.jpg'
                      : item["title"].toString().toLowerCase().contains('drama musikal')
                      ? 'assets/images/event_drama.jpg'
                      : item["title"].toString().toLowerCase().contains('evaluasi')
                      ? 'assets/images/event_evaluasi.jpg'
                      : item["title"].toString().toLowerCase().contains('closing')
                      ? 'assets/images/event_closing.jpg'
                      : 'assets/images/event.jpg',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (title == 'Komitmen')
                          komitmen_status == 'completed'
                              ? ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ReviewKomitmenScreen()),
                                  );
                                },
                                icon: const Icon(Icons.visibility, color: Colors.white),
                                label: const Text(
                                  'Review Komitmen',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              )
                              : ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const KomitmenScreen()));
                                },
                                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                                label: const Text(
                                  'Isi Komitmen',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                        if (item['acara']?.contains('Detail Acara') ?? false)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailAcaraScreen()));
                            },
                            icon: const Icon(Icons.event, color: Colors.white),
                            label: const Text(
                              'Detail',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Tombol untuk Evaluasi 2
                        if (evaluasi == 'Evaluasi 2')
                          evaluasi2_status == 'completed'
                              ? ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ReviewEvaluasi2Screen()),
                                  );
                                },
                                icon: const Icon(Icons.visibility, color: Colors.white),
                                label: const Text(
                                  'Review Evaluasi Pendaftaran',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              )
                              : ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EvaluasiScreen2()));
                                },
                                icon: const Icon(Icons.assignment, color: Colors.white),
                                label: const Text(
                                  'Evaluasi Pendaftaran',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                        // Tombol untuk Evaluasi 3
                        if (evaluasi == 'Evaluasi 3')
                          evaluasi3_status == 'completed'
                              ? ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ReviewEvaluasi3Screen()),
                                  );
                                },
                                icon: const Icon(Icons.visibility, color: Colors.white),
                                label: const Text(
                                  'Review Evaluasi Opening',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              )
                              : ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EvaluasiScreen3()));
                                },
                                icon: const Icon(Icons.assignment, color: Colors.white),
                                label: const Text(
                                  'Evaluasi Opening',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                        // Tombol untuk Evaluasi 4
                        if (evaluasi == 'Evaluasi 4')
                          evaluasi4_status == 'completed'
                              ? ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ReviewEvaluasi4Screen()),
                                  );
                                },
                                icon: const Icon(Icons.visibility, color: Colors.white),
                                label: const Text(
                                  'Review Evaluasi KKR 1',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              )
                              : ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EvaluasiScreen4()));
                                },
                                icon: const Icon(Icons.assignment, color: Colors.white),
                                label: const Text(
                                  'Evaluasi KKR 1',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                        // Tombol untuk Evaluasi Lainnya
                        if (item['acara']?.contains('Evaluasi') ?? false)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const EvaluasiScreen()));
                            },
                            icon: const Icon(Icons.assignment, color: Colors.white),
                            label: const Text(
                              'Evaluasi Lain',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = rundownPerHari.keys.toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: days.map((day) => Tab(child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
          isScrollable: false,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: days.map((day) => _buildRundownList(rundownPerHari[day]!)).toList(),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'resetData',
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              // Hapus semua data evaluasi dan komitmen
              await prefs.remove('evaluasi2_status');
              await prefs.remove('evaluasi3_status');
              await prefs.remove('evaluasi4_status');
              await prefs.remove('komitmen_status');

              await prefs.remove('evaluasi2_answer1');
              await prefs.remove('evaluasi2_answer2');
              await prefs.remove('evaluasi2_answer3');
              await prefs.remove('evaluasi2_komentar');

              await prefs.remove('opening_slider1');
              await prefs.remove('opening_slider2');
              await prefs.remove('opening_answer_drama');
              await prefs.remove('opening_komentar_drama');
              await prefs.remove('opening_saran_ibadah');

              await prefs.remove('kkr1_slider1');
              await prefs.remove('kkr1_slider2');
              await prefs.remove('kkr1_answer_drama');
              await prefs.remove('kkr1_komentar_drama');
              await prefs.remove('kkr1_saran_ibadah');

              await prefs.remove('komitmen_answer1');
              await prefs.remove('komitmen_answer2');
              await prefs.remove('komitmen_answer3');
              await prefs.remove('komitmen_komentar');
              await prefs.remove('komitmen_slider');

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menghapus semua data...')));
              _getRoleFromSharedPreferences(); // Refresh status
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          const SizedBox(height: 16), // Jarak antar FAB
          FloatingActionButton(
            heroTag: 'customAction',
            onPressed: () {
              // Custom action here
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refreshing...')));
              _getRoleFromSharedPreferences();
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
