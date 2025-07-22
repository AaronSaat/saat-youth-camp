import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/screens/anggota_group_main_screen.dart';
import 'package:syc/screens/anggota_group_screen.dart';
import 'package:syc/screens/anggota_kelompok_main_screen.dart';
import 'package:syc/screens/anggota_kelompok_screen.dart';
import 'package:syc/screens/list_gereja_screen.dart';
import 'package:syc/screens/list_group_screen.dart';
import 'package:syc/screens/list_kelompok_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_alert_dialog.dart';

import '../services/api_service.dart';
import '../utils/global_variables.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'anggota_gereja_screen.dart';
import 'profile_screen.dart';
import 'daftar_acara_screen.dart';
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
  String? id;
  String? role;
  List<dynamic> _kelompokList = [];

  List<Widget> _pages = [];

  @override
  void initState() {
    _currentIndex = GlobalVariables.currentIndex;
    super.initState();
    loadRoleAndSetup();
  }

  Future<void> loadRoleAndSetup() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id');
    role = prefs.getString('role');

    if (role == 'Peserta') {
      id =
          prefs.getString('kelompok_id') ??
          "1"; // Default value if no kelompok found
    } else if (role == 'Pembimbing Kelompok') {
      id =
          prefs.getString('kelompok_id') ??
          "1"; // Default value if no kelompok found
    } else if (role == 'Pembina') {
      id =
          prefs.getString('group_id') ?? "1"; // Default value if no group found
    }

    if (role == 'Peserta') {
      _pages = [
        const DashboardScreen(),
        const DaftarAcaraScreen(),
        // const DaftarAcaraScreen(),
        AnggotaKelompokScreen(id: id), //nanti masukkan parameter gerejanya
        MateriScreen(userId: id.toString()),
        const ProfileScreen(),
      ];
    } else if (role == 'Pembimbing Kelompok') {
      _pages = [
        const DashboardScreen(),
        const DaftarAcaraScreen(),
        // baca IMPORTANT NOTES di filenya
        AnggotaKelompokMainScreen(
          id: id,
        ), //nantt masukkan parameter kelompoknya
        MateriScreen(userId: id.toString()),
        const ProfileScreen(),
      ];
    } else if (role == 'Pembina') {
      _pages = [
        const DashboardScreen(),
        const DaftarAcaraScreen(),
        // baca IMPORTANT NOTES di filenya
        AnggotaGroupMainScreen(id: id), //nanti masukkan parameter gerejanya
        MateriScreen(userId: id),
        const ProfileScreen(),
      ];
    } else if (role == 'Panitia') {
      _pages = [
        const DashboardScreen(),
        const DaftarAcaraScreen(),
        // AnggotaGerejaScreen(id: "2"),
        // AnggotaKelompokScreen(id: "1"),
        ListGroupScreen(),
        ListKelompokScreen(),
        MateriScreen(userId: id),
        // const BroadcastScreen(),
        // const AdminScreen(),
        const ProfileScreen(),
      ];
    }

    setState(() {});
  }

  BottomNavigationBarItem buildSvgNavItem(
    String asset,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        asset,
        height: 36,
        width: 36,
        colorFilter: ColorFilter.mode(
          _currentIndex == index ? AppColors.primary : Colors.grey,
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    if (role == 'Peserta' || role == 'Pembimbing Kelompok') {
      return [
        buildSvgNavItem(
          'assets/icons/navigation_bar/dashboard.svg',
          'Dashboard',
          0,
        ),
        buildSvgNavItem(
          'assets/icons/navigation_bar/list_acara.svg',
          'Acara',
          1,
        ),
        buildSvgNavItem(
          'assets/icons/navigation_bar/kelompok.svg',
          'Kelompok',
          2,
        ),
        buildSvgNavItem('assets/icons/navigation_bar/materi.svg', 'Materi', 3),
        buildSvgNavItem('assets/icons/navigation_bar/profile.svg', 'Profil', 4),
      ];
    } else if (role == 'Pembina') {
      return [
        buildSvgNavItem(
          'assets/icons/navigation_bar/dashboard.svg',
          'Dashboard',
          0,
        ),
        buildSvgNavItem(
          'assets/icons/navigation_bar/list_acara.svg',
          'Acara',
          1,
        ),
        buildSvgNavItem(
          'assets/icons/navigation_bar/kelompok_pendaftaran.svg',
          'Group',
          2,
        ),
        buildSvgNavItem('assets/icons/navigation_bar/materi.svg', 'Materi', 3),
        buildSvgNavItem('assets/icons/navigation_bar/profile.svg', 'Profil', 4),
      ];
    } else if (role == 'Panitia') {
      return [
        buildSvgNavItem(
          'assets/icons/navigation_bar/dashboard.svg',
          'Dashboard',
          0,
        ),
        buildSvgNavItem(
          'assets/icons/navigation_bar/list_acara.svg',
          'Acara',
          1,
        ),
        buildSvgNavItem(
          'assets/icons/navigation_bar/kelompok_pendaftaran.svg',
          'Group',
          2,
        ),
        buildSvgNavItem(
          'assets/icons/navigation_bar/kelompok.svg',
          'Kelompok',
          3,
        ),
        buildSvgNavItem('assets/icons/navigation_bar/materi.svg', 'Materi', 4),
        // const BottomNavigationBarItem(
        //   icon: Icon(Icons.campaign),
        //   label: 'Broadcast',
        // ),
        // const BottomNavigationBarItem(
        //   icon: Icon(Icons.admin_panel_settings),
        //   label: 'Admin',
        // ),
        buildSvgNavItem('assets/icons/navigation_bar/profile.svg', 'Profil', 5),
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
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            bottom: MediaQuery.of(context).size.height * 0.01,
            child: SafeArea(
              top: false,
              child: SizedBox(
                // width: MediaQuery.of(context).size.width * 0.8,
                height: kBottomNavigationBarHeight + 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: _onItemTapped,
                      items: _buildNavItems(),
                      type: BottomNavigationBarType.shifting,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      selectedItemColor: AppColors.primary,
                      unselectedItemColor: Colors.grey,
                      showUnselectedLabels: true,
                      selectedLabelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: TextStyle(fontSize: 8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
