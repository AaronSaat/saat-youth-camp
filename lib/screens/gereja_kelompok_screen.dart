import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart' show AppColors;
import '../services/api_service.dart';

class GerejaKelompokScreen extends StatefulWidget {
  const GerejaKelompokScreen({super.key});

  @override
  State<GerejaKelompokScreen> createState() => _GerejaKelompokScreenState();
}

class _GerejaKelompokScreenState extends State<GerejaKelompokScreen> with SingleTickerProviderStateMixin {
  String? role;
  String? currentEmail;
  List<dynamic> gerejaList = [];
  List<dynamic> kelompokList = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _fetchUsers();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
      currentEmail = prefs.getString('email');
    });
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await ApiService.getAllUsers(context);
      setState(() {
        gerejaList = response['gereja'];
        kelompokList = response['kelompok'];
      });
      debugPrint('Gereja List: $gerejaList');
    } catch (e) {
      print('Error fetching data: $e');
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

  Widget _buildGerejaList() {
    return ListView.builder(
      itemCount: gerejaList.length,
      itemBuilder: (context, index) {
        final gereja = gerejaList[index];
        final anggota = gereja['anggota'] as List;

        return Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gereja['gereja_nama'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...anggota.map((user) {
                  final isCurrentUser = user['email'] == currentEmail;
                  return ListTile(
                    title: Row(
                      children: [
                        Text(user['username']),
                        if (isCurrentUser)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                            child: const Text('ANDA', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                      ],
                    ),
                    subtitle: Text('${user['email']} • ${user['roles']}'),
                    leading: Icon(getRoleIcon(user['roles'])),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKelompokList() {
    return ListView.builder(
      itemCount: kelompokList.length,
      itemBuilder: (context, index) {
        final kelompok = kelompokList[index];
        final anggota = kelompok['anggota'] as List;

        return Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kelompok['nama_kelompok'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...anggota.map((user) {
                  final isCurrentUser = user['email'] == currentEmail;
                  return ListTile(
                    title: Row(
                      children: [
                        Text(user['username']),
                        if (isCurrentUser)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                            child: const Text('ANDA', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                      ],
                    ),
                    subtitle: Text('${user['email']} • ${user['roles']} '),
                    leading: Icon(getRoleIcon(user['roles'])),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (role != 'Panitia') {
      return const Scaffold(body: Center(child: Text('Akses ditolak. Hanya untuk admin.')));
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Gereja'), Tab(text: 'Kelompok')]),
      ),
      body: TabBarView(controller: _tabController, children: [_buildGerejaList(), _buildKelompokList()]),
    );
  }
}
