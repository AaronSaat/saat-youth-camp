import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'kelompok_screen.dart';
import 'gereja_screen.dart';
import 'gereja_kelompok_screen.dart';
import 'profil_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late String? role;

  List<Widget> _pages = [];
  List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _loadRoleAndSetup();
  }

  Future<void> _loadRoleAndSetup() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');

    if (role == 'Peserta' || role == 'Pembina Kelompok') {
      _pages = [const DashboardScreen(), const KelompokScreen(), const ProfilScreen()];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Kelompok'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
      ];
    } else if (role == 'Pembina') {
      _pages = [const DashboardScreen(), const GerejaScreen(), const ProfilScreen()];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.church), label: 'Gereja'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
      ];
    } else if (role == 'Panitia') {
      _pages = [const DashboardScreen(), const GerejaKelompokScreen(), const ProfilScreen()];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: 'Data User'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
      ];
    }

    setState(() {}); // Refresh tampilan setelah menentukan pages & navItems
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // Jika belum selesai load role
    if (_pages.isEmpty || _navItems.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SYC 2024 App'),
        backgroundColor: Colors.blueAccent,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(currentIndex: _currentIndex, onTap: _onItemTapped, items: _navItems),
    );
  }
}
