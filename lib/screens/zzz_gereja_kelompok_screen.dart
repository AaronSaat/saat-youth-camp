import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart' show AppColors;
import '../services/api_service.dart';

class GerejaKelompokScreen extends StatefulWidget {
  const GerejaKelompokScreen({super.key});

  @override
  State<GerejaKelompokScreen> createState() => _GerejaKelompokScreenState();
}

class _GerejaKelompokScreenState extends State<GerejaKelompokScreen>
    with SingleTickerProviderStateMixin {
  String? role;
  String? currentEmail;
  List<dynamic> gerejaList = [];
  List<dynamic> kelompokList = [];
  List<dynamic> allUsersList = []; // Menambahkan list untuk semua user
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // Menambahkan 1 tab lagi
    _loadUserData();
    // _fetchGroupAndChurch();
    // _fetchAllUsers();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
      currentEmail = prefs.getString('email');
    });
  }

  // Future<void> _fetchGroupAndChurch() async {
  //   try {
  //     final response = await ApiService.getGroupAndChurchMembers(context);
  //     setState(() {
  //       gerejaList = response['gereja'];
  //       kelompokList = response['kelompok'];
  //     });
  //     debugPrint('Gereja List: $gerejaList');
  //   } catch (e) {
  //     print('Error fetching group/church data: $e');
  //   }
  // }

  // Future<void> _fetchAllUsers() async {
  //   try {
  //     final response = await ApiService.getAllUsers(context);
  //     setState(() {
  //       allUsersList = response;
  //     });
  //   } catch (e) {
  //     print('Error fetching all users: $e');
  //   }
  // }

  IconData getRoleIcon(String role) {
    switch (role) {
      case 'Pembina':
        return Icons.church;
      case 'Panitia':
        return Icons.admin_panel_settings;
      case 'Pembimbing Kelompok':
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
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gereja['gereja_nama'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...anggota.map((user) {
                  final isCurrentUser = user['email'] == currentEmail;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            getRoleIcon(user['roles']),
                            size: 28,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user['username'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isCurrentUser)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ANDA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 20, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            user['email'] ?? '-',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_user,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user['roles'] ?? '-',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.male, size: 20, color: Colors.blue),
                          const SizedBox(width: 6),
                          const Text(
                            'Laki-laki',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.cake, size: 20, color: Colors.orange),
                          const SizedBox(width: 6),
                          const Text(
                            '20 Tahun',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('Progress: 70/100'),
                      const SizedBox(height: 4),
                      const LinearProgressIndicator(
                        value: 0.7,
                        backgroundColor: Colors.grey,
                        color: Colors.green,
                      ),
                      const Divider(height: 20, color: AppColors.primary),
                    ],
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
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kelompok['nama_kelompok'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...anggota.map((user) {
                  final isCurrentUser = user['email'] == currentEmail;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            getRoleIcon(user['roles']),
                            size: 28,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user['username'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isCurrentUser)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ANDA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 20, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            user['email'] ?? '-',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_user,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user['roles'] ?? '-',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.female, size: 20, color: Colors.pink),
                          const SizedBox(width: 6),
                          const Text(
                            'Perempuan',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          Icon(Icons.cake, size: 20, color: Colors.orange),
                          const SizedBox(width: 6),
                          const Text(
                            '20 Tahun',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('Progress: 70/100'),
                      const SizedBox(height: 4),
                      const LinearProgressIndicator(
                        value: 0.7,
                        backgroundColor: Colors.grey,
                        color: Colors.green,
                      ),
                      const Divider(height: 20, color: AppColors.primary),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllUsersList() {
    return ListView.builder(
      itemCount: allUsersList.length,
      itemBuilder: (context, index) {
        final user = allUsersList[index];
        final isCurrentUser = user['email'] == currentEmail;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(getRoleIcon(user['roles']), color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(
                      user['username'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.email, size: 20, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      user['email'] ?? '-',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      getRoleIcon(user['roles']),
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user['roles'] ?? '-',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                if (user['gereja'] != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_city,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user['gereja'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
                if (user['kelompok'] != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.group, size: 20, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        user['kelompok'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
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
      return const Scaffold(
        body: Center(child: Text('Akses ditolak. Hanya untuk admin.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {},
          child: AbsorbPointer(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari user...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Gereja'),
            Tab(text: 'Kelompok'),
            Tab(text: 'Semua User'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGerejaList(),
          _buildKelompokList(),
          _buildAllUsersList(),
        ],
      ),
    );
  }
}
