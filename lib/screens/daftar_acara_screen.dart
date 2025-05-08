import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
import 'komitmen_screen.dart';
import 'evaluasi_screen.dart';
import 'detail_acara_screen.dart';

class DaftarAcaraScreen extends StatefulWidget {
  const DaftarAcaraScreen({super.key});

  @override
  State<DaftarAcaraScreen> createState() => _DaftarAcaraScreenState();
}

class _DaftarAcaraScreenState extends State<DaftarAcaraScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String currentRole = ""; // Role akan diambil dari SharedPreferences

  final Map<String, List<Map<String, String>>> rundownPerHari = {
    'Day 1': [
      {'title': 'KKR Pembukaan', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Sesi 1', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Komitmen'},
    ],
    'Day 2': [
      {'title': 'Sesi 2', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Games 1', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Komitmen'},
    ],
    'Day 3': [
      {'title': 'Games 2', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Sesi 3', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Komitmen'},
    ],
    'Day 4': [
      {'title': 'Sesi 4', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'KKR Penutupan', 'acara': 'Detail Acara, Evaluasi'},
      {'title': 'Komitmen'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _getRoleFromSharedPreferences(); // Ambil role dari SharedPreferences
  }

  // Fungsi untuk mengambil role dari SharedPreferences
  Future<void> _getRoleFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentRole = prefs.getString('role') ?? ''; // Ambil role dari SharedPreferences
    });
  }

  Widget _buildRundownList(List<Map<String, String>> rundown) {
    return ListView.builder(
      itemCount: rundown.length,
      itemBuilder: (context, index) {
        final item = rundown[index];
        final title = item['title'] ?? '';
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
                  isKomitmen ? 'assets/images/komitmen.jpg' : 'assets/images/event.jpg',
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
                          ElevatedButton.icon(
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
                        if (item['acara']?.contains('Evaluasi') ?? false)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const EvaluasiScreen()));
                            },
                            icon: const Icon(Icons.assignment, color: Colors.white),
                            label: const Text(
                              'Evaluasi',
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
      floatingActionButton:
          currentRole == "Panitia"
              ? FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add, color: Colors.white),
                backgroundColor: AppColors.primary,
              )
              : null,
    );
  }
}
