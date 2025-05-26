import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';

import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'kelompok_screen.dart';
import 'gereja_screen.dart';
import 'gereja_kelompok_screen.dart';
import 'profil_screen.dart';
import 'daftar_acara2_screen.dart';
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
  String? role;

  List<Widget> _pages = [];

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
        const DaftarAcara2Screen(),
        // const DaftarAcaraScreen(),
        const KelompokScreen(),
        const MateriScreen(),
        const ProfilScreen(),
      ];
    } else if (role == 'Pembina Kelompok') {
      _pages = [
        const DashboardScreen(),
        const DaftarAcaraScreen(),
        const KelompokScreen(),
        const MateriScreen(),
        const ProfilScreen(),
      ];
    } else if (role == 'Pembina') {
      _pages = [
        const DashboardScreen(),
        const DaftarAcaraScreen(),
        const GerejaScreen(),
        const MateriScreen(),
        const ProfilScreen(),
      ];
    } else if (role == 'Panitia') {
      _pages = [
        const DashboardScreen(),
        const GerejaKelompokScreen(),
        const BroadcastScreen(),
        const AdminScreen(),
        const ProfilScreen(),
      ];
    }

    setState(() {});
  }

  BottomNavigationBarItem buildSvgNavItem(String asset, String label, int index) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        asset,
        height: 28,
        width: 28,
        colorFilter: ColorFilter.mode(_currentIndex == index ? AppColors.primary : Colors.grey, BlendMode.srcIn),
      ),
      label: label,
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    if (role == 'Peserta' || role == 'Pembina Kelompok') {
      return [
        buildSvgNavItem('assets/icons/navigation_bar/dashboard.svg', 'Dashboard', 0),
        buildSvgNavItem('assets/icons/navigation_bar/list_acara.svg', 'Acara', 1),
        buildSvgNavItem('assets/icons/navigation_bar/kelompok.svg', 'Kelompok', 2),
        const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Materi'),
        buildSvgNavItem('assets/icons/navigation_bar/profile.svg', 'Profil', 4),
      ];
    } else if (role == 'Pembina') {
      return [
        buildSvgNavItem('assets/icons/navigation_bar/dashboard.svg', 'Dashboard', 0),
        buildSvgNavItem('assets/icons/navigation_bar/list_acara.svg', 'Acara', 1),
        buildSvgNavItem('assets/icons/navigation_bar/gereja.svg', 'Gereja', 2),
        const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Materi'),
        buildSvgNavItem('assets/icons/navigation_bar/profile.svg', 'Profil', 4),
      ];
    } else if (role == 'Panitia') {
      return [
        buildSvgNavItem('assets/icons/navigation_bar/dashboard.svg', 'Dashboard', 0),
        buildSvgNavItem('assets/icons/navigation_bar/all_user.svg', 'Peserta', 1),
        const BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Broadcast'),
        const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        buildSvgNavItem('assets/icons/navigation_bar/profile.svg', 'Profil', 4),
      ];
    }
    return [];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty || role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBody: true, // penting untuk floating nav di atas body
      body: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            bottom: MediaQuery.of(context).size.height * 0.03,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onItemTapped,
                  items: _buildNavItems(),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: Colors.grey,
                  showUnselectedLabels: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
