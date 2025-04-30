import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Mengambil data dari shared_preferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? 'No email found';
      role = prefs.getString('role') ?? 'No role found';
      gereja = prefs.getString('gereja') ?? 'No gereja found';
      kelompok = prefs.getString('kelompok') ?? 'No kelompok found';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 100, color: Colors.blue),
          const SizedBox(height: 20),
          Text('$email', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Role: $role', style: const TextStyle(fontSize: 18)),
          Text('Gereja: $gereja', style: const TextStyle(fontSize: 18)),
          Text('Kelompok: $kelompok', style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
