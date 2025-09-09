import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:shimmer/shimmer.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_snackbar.dart' show showCustomSnackBar;
import 'anggota_group_screen.dart';

class ListGroupScreen extends StatefulWidget {
  const ListGroupScreen({Key? key}) : super(key: key);

  @override
  _ListGroupScreenState createState() => _ListGroupScreenState();
}

class _ListGroupScreenState extends State<ListGroupScreen> {
  List<dynamic> _groupList = [];
  bool _isLoading = true;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    _lastBackPressed = null;
    super.initState();
    initAll();
  }

  Future<void> initAll({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupKey = 'list_group';

      if (!forceRefresh) {
        final cachedGroup = prefs.getString(groupKey);
        if (cachedGroup != null) {
          final groupList = jsonDecode(cachedGroup);
          if (!mounted) return;
          setState(() {
            _groupList = groupList ?? [];
            _isLoading = false;
          });
          print('[PREF_API] Group List (from shared pref): $_groupList');
          return;
        }
      }

      final groupList = await ApiService.getGroup(context);
      await prefs.setString(groupKey, jsonEncode(groupList));
      if (!mounted) return;
      setState(() {
        _groupList = groupList;
        _isLoading = false;
      });
      print('[PREF_API] Group List (from API): $_groupList');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _lastBackPressed = null;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          final now = DateTime.now();
          if (_lastBackPressed == null ||
              now.difference(_lastBackPressed!) > Duration(seconds: 2)) {
            _lastBackPressed = now;
            showCustomSnackBar(
              context,
              "Tekan sekali lagi untuk keluar aplikasi",
              duration: const Duration(seconds: 5),
              showDismissButton: false,
              showAppIcon: true,
            );
          } else {
            // Keluar aplikasi
            Future.delayed(const Duration(milliseconds: 100), () {
              // ignore: use_build_context_synchronously
              SystemNavigator.pop();
            });
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Stack(
          children: [
            Positioned(
              child: Image.asset(
                'assets/images/background_fade.jpg',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.fill,
              ),
            ),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () => initAll(forceRefresh: true),
                color: AppColors.brown1,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      bottom: 84.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              'assets/texts/daftar_gereja.png',
                              height: 128,
                            ),
                          ],
                        ),
                        // Tidak ada day selector di desain ini
                        const SizedBox(height: 8),
                        _isLoading
                            ? buildListShimmer(context)
                            : _groupList.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/data_not_found.png',
                                    height: 100,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Gagal memuat daftar group pendafataran :(",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.brown1,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _groupList.length,
                              itemBuilder: (context, index) {
                                final group = _groupList[index];
                                return CustomCard(
                                  text: group['gereja_nama'] ?? '',
                                  icon: Icons.church,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AnggotaGroupScreen(
                                              id: group['group_id'].toString(),
                                            ),
                                      ),
                                    );
                                  },
                                  iconBackgroundColor: AppColors.brown1,
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildListShimmer(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      height: 7 * 86.0, // 7 item x tinggi item + padding
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
