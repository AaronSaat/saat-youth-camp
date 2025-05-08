import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart' show AppColors;
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class GerejaScreen extends StatefulWidget {
  const GerejaScreen({super.key});

  @override
  State<GerejaScreen> createState() => _GerejaScreenState();
}

class _GerejaScreenState extends State<GerejaScreen> {
  List<dynamic> anggotaGereja = [];
  String? namaGereja;

  @override
  void initState() {
    super.initState();
    _fetchMyChurch();
  }

  Future<void> _fetchMyChurch() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null) return;

    try {
      final response = await ApiService.getMyChurchMembers(context, email);
      setState(() {
        namaGereja = response['gereja_nama'];
        anggotaGereja = response['anggota'];
      });
    } catch (e) {
      print('Gagal mengambil data gereja: $e');
    }
  }

  IconData getRoleIcon(String role) {
    switch (role) {
      case 'Pembina':
        return Icons.church;
      case 'Panitia':
        return Icons.admin_panel_settings;
      case 'Pembina Kelompok':
        return Icons.boy;
      case 'Peserta':
        return Icons.badge;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Profil'), centerTitle: true,
        toolbarHeight: 0,
      ),
      body:
          anggotaGereja.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaGereja ?? 'Nama Gereja',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: FutureBuilder<String?>(
                            future: SharedPreferences.getInstance().then((prefs) => prefs.getString('email')),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final currentEmail = snapshot.data;

                              return ListView.builder(
                                itemCount: anggotaGereja.length,
                                itemBuilder: (context, index) {
                                  final user = anggotaGereja[index];
                                  final isCurrentUser = user['email'] == currentEmail;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Row(
                                          children: [
                                            Text(user['username']),
                                            if (isCurrentUser)
                                              Container(
                                                margin: const EdgeInsets.only(left: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'ANDA',
                                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                              ),
                                          ],
                                        ),
                                        subtitle: Text('${user['email']} • ${user['roles']}'),
                                        leading: Icon(getRoleIcon(user['roles'])),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child:
                                            user['roles'] == 'Peserta'
                                                ? Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: const [
                                                    Text('Progress: 70/100'),
                                                    SizedBox(height: 4),
                                                    LinearProgressIndicator(
                                                      value: 0.7, // 70/100
                                                      backgroundColor: Colors.grey,
                                                      color: Colors.green,
                                                    ),
                                                  ],
                                                )
                                                : const SizedBox.shrink(), // widget kosong untuk non-peserta
                                      ),
                                      const Divider(),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
