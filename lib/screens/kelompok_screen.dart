import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart' show AppColors;
import '../services/api_service.dart';

class KelompokScreen extends StatefulWidget {
  const KelompokScreen({super.key});

  @override
  State<KelompokScreen> createState() => _KelompokScreenState();
}

class _KelompokScreenState extends State<KelompokScreen> {
  String? currentEmail;
  List<dynamic> anggotaKelompok = [];
  String? namaKelompok;

  @override
  void initState() {
    super.initState();
    _fetchMyGroup();
    _loadUserData();
  }

  Future<void> _fetchMyGroup() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null) return;

    try {
      final response = await ApiService.getMyGroupMembers(context, email);
      setState(() {
        namaKelompok = response['nama_kelompok'];
        anggotaKelompok = response['anggota'];
      });
    } catch (e) {
      print('Gagal mengambil data kelompok: $e');
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentEmail = prefs.getString('email');
    });
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
        // toolbarHeight: 0,
      ),
      body:
          anggotaKelompok.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaKelompok ?? 'Nama Kelompok',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: anggotaKelompok.length,
                            itemBuilder: (context, index) {
                              final user = anggotaKelompok[index];
                              final isCurrentUser = user['email'] == currentEmail;
                              return ListTile(
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
                                        child: const Text('ANDA', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ),
                                  ],
                                ),
                                subtitle: Text('${user['email']} • ${user['roles']}'),
                                leading: Icon(getRoleIcon(user['roles'])),
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
