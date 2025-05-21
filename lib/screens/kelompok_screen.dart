import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
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
  dynamic selectedUser;
  String selectedTab = 'komitmen';

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
        selectedUser = response['anggota'].firstWhere((u) => u['email'] == email, orElse: () => null);
      });
    } catch (e) {
      print('Gagal mengambil data kelompok: $e');
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
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
        backgroundColor: Colors.transparent,
        toolbarHeight: kToolbarHeight,
        title: Text(namaKelompok ?? 'Nama Kelompok'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body:
          anggotaKelompok.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Image.asset(
                    'assets/images/background_member.png',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: anggotaKelompok.length,
                            itemBuilder: (context, index) {
                              final user = anggotaKelompok[index];
                              final isCurrentUser = user['email'] == currentEmail;
                              final isSelected = selectedUser == user;

                              return GestureDetector(
                                onTap: () => setState(() => selectedUser = user),
                                child: Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    elevation: isSelected ? 4 : 1,
                                    child: Stack(
                                      children: [
                                        // Lingkaran + Icon (tengah atas)
                                        Positioned(
                                          top: 24,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColors.primary, width: 2),
                                              ),
                                              child: Icon(
                                                getRoleIcon(user['roles']),
                                                size: 50,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Info pribadi (tengah bawah)
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: AnimatedContainer(
                                            duration: Duration(milliseconds: 300),
                                            height: isSelected ? 100 : 50,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  user['username'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                if (isSelected) ...[
                                                  const SizedBox(height: 2),
                                                  Flexible(
                                                    child: Text(
                                                      user['email'] ?? '',
                                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                                      textAlign: TextAlign.center,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      user['roles'] ?? '',
                                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                                      textAlign: TextAlign.center,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      user['gereja'] ?? '',
                                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                                      textAlign: TextAlign.center,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Label ANDA (kanan atas)
                                        if (isCurrentUser)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              width: 40,
                                              height: 20,
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.accent,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'ANDA',
                                                style: TextStyle(color: Colors.white, fontSize: 10),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Scrollable content
                        Expanded(
                          child: Column(
                            children: [
                              // Tombol Komitmen & Evaluasi (tidak ikut scroll)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => selectedTab = 'komitmen'),
                                      child: Card(
                                        color: selectedTab == 'komitmen' ? AppColors.primary : Colors.white,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(color: AppColors.primary),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Center(
                                            child: Text(
                                              'Komitmen',
                                              style: TextStyle(
                                                color: selectedTab == 'komitmen' ? Colors.white : AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => selectedTab = 'evaluasi'),
                                      child: Card(
                                        color: selectedTab == 'evaluasi' ? AppColors.primary : Colors.white,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(color: AppColors.primary),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Center(
                                            child: Text(
                                              'Evaluasi',
                                              style: TextStyle(
                                                color: selectedTab == 'evaluasi' ? Colors.white : AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Scrollable content
                              Expanded(
                                child:
                                    selectedUser == null
                                        ? const Center(
                                          child: Text(
                                            'Pilih anggota untuk melihat detail.',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        )
                                        : SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.5,
                                          child: Card(
                                            color: Colors.transparent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              side: const BorderSide(color: Colors.white),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: SizedBox(
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: List.generate(
                                                      6,
                                                      (index) => Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '${selectedTab == 'komitmen' ? 'Komitmen' : 'Evaluasi'} Dummy ${index + 1}',
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            'Deskripsi ${selectedTab == 'komitmen' ? 'komitmen' : 'evaluasi'}...',
                                                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                                                          ),
                                                          if (index != 5) ...[
                                                            const SizedBox(height: 12),
                                                            const Divider(color: Colors.white),
                                                            const SizedBox(height: 12),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
