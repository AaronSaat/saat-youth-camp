import 'package:flutter/material.dart';
import 'package:syc/utils/app_colors.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> adminCards = [
      {'icon': Icons.people, 'text': 'Kelola Panitia'},
      {'icon': Icons.security, 'text': 'Hak Akses'},
      {'icon': Icons.history, 'text': 'Log Aktivitas'},
      {'icon': Icons.announcement, 'text': 'Pengumuman'},
      {'icon': Icons.backup, 'text': 'Backup Data'},
      {'icon': Icons.add_task, 'text': 'Add New'},
      {'icon': Icons.add_task, 'text': 'Add New'},
      {'icon': Icons.add_task, 'text': 'Add New'},
      {'icon': Icons.add_task, 'text': 'Add New'},
      {'icon': Icons.add_task, 'text': 'Add New'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: adminCards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final item = adminCards[index];
            return Card(
              color: AppColors.primary.withAlpha(30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () {
                  // Tambahkan navigasi atau aksi
                },
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item['icon'], size: 40, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        item['text'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
