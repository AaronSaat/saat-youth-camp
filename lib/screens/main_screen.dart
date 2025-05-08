import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'kelompok_screen.dart';
import 'gereja_screen.dart';
import 'gereja_kelompok_screen.dart';
import 'profil_screen.dart';
import 'daftar_acara_screen.dart';
import 'navigasi_screen.dart';
import 'materi_screen.dart';
import 'broadcast_screen.dart';
import 'admin_screen.dart';

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

    if (role == 'Peserta') {
      _pages = [
        const DashboardScreen(),
        const DaftarAcaraScreen(),
        const NavigasiScreen(),
        const MateriScreen(),
        const ProfilScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Acara'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Navigasi'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Materi'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
      ];
    } else if (role == 'Pembina Kelompok') {
      _pages = [
        const DashboardScreen(),
        const DaftarAcaraScreen(),
        const KelompokScreen(),
        const MateriScreen(),
        const ProfilScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Acara'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Anggota'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Materi'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
      ];
    } else if (role == 'Pembina') {
      _pages = [const DashboardScreen(), const GerejaScreen(), const MateriScreen(), const ProfilScreen()];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.church), label: 'Anggota'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Materi'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
      ];
    } else if (role == 'Panitia') {
      _pages = [
        const DashboardScreen(),
        const GerejaKelompokScreen(),
        const BroadcastScreen(),
        const AdminScreen(),
        const ProfilScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Peserta'),
        BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Broadcast'),
        BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profil'),
      ];
    }

    setState(() {});
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
    if (_pages.isEmpty || _navItems.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: _navItems,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
