import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';

import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String email = '';
  String role = '';
  String gereja = '';
  String kelompok = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? 'No email found';
      role = prefs.getString('role') ?? 'No role found';
      gereja = prefs.getString('gereja') ?? 'No gereja found';
      kelompok = prefs.getString('kelompok') ?? 'No kelompok found';
    });
  }

  Future<void> logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Profil'), centerTitle: true,
        toolbarHeight: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil Header: Profile picture dan info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, // Memastikan card isi penuh lebar screen
                  child: Row(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/logos/stt_saat.png')),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('John Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.work, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(role, style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (gereja != 'Tidak ada gereja.') ...[
                              Row(
                                children: [
                                  const Icon(Icons.church, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(gereja, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (kelompok != 'Tidak ada kelompok.') ...[
                              Row(
                                children: [
                                  const Icon(Icons.group, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(kelompok, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                  ],
                ),
                const Divider(height: 24, thickness: 1, color: AppColors.primary),

                Row(
                  children: [
                    const Icon(Icons.settings, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('View Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                  ],
                ),
                const Divider(height: 24, thickness: 1, color: AppColors.primary),

                Row(
                  children: [
                    const Icon(Icons.help, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Help', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                  ],
                ),
                const Divider(height: 24, thickness: 1, color: AppColors.primary),

                GestureDetector(
                  onTap: () => logoutUser(context),
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: AppColors.accent),
                      SizedBox(width: 12),
                      Expanded(child: Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),

                const Divider(height: 24, thickness: 1, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
