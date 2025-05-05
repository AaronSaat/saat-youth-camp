import 'package:flutter/material.dart';
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
  }

  Widget _buildRundownList(List<Map<String, String>> rundown) {
    return ListView.builder(
      itemCount: rundown.length,
      itemBuilder: (context, index) {
        final item = rundown[index];
        final isKomitmen = item['title'] == 'Komitmen';

        if (isKomitmen) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const KomitmenScreen()));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Komitmen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Column(
                      children: const [
                        Icon(Icons.arrow_forward_ios, size: 16),
                        SizedBox(height: 2),
                        Text('More info', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Untuk item selain Komitmen (tetap expandable)
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ExpansionTile(
            title: Text(item['title'] ?? ''),
            initiallyExpanded: true,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DetailAcaraScreen(
                            title: item['title'] ?? 'Detail Acara',
                            detail:
                                'Ini adalah detail dari acara ${item['title'] ?? ''}. Akan ada sesi penyampaian materi, diskusi, dan refleksi pribadi.',
                          ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.event_note, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          (item['acara'] ?? '').replaceAll(', Komitmen', '').replaceAll(', Evaluasi', ''),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Column(
                        children: const [
                          Icon(Icons.arrow_forward_ios, size: 16),
                          SizedBox(height: 2),
                          Text('More info', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (item['acara']?.contains('Evaluasi') ?? false)
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EvaluasiScreen()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Evaluasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        Column(
                          children: const [
                            Icon(Icons.arrow_forward_ios, size: 16),
                            SizedBox(height: 2),
                            Text('More info', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
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
        title: const Text('Daftar Acara'),
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
    );
  }
}
