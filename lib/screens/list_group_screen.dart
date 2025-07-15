import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syc/screens/anggota_kelompok_screen.dart';
import 'package:syc/utils/app_colors.dart';

import '../services/api_service.dart';
import '../widgets/custom_card.dart';
import 'anggota_group_screen.dart';

class ListGroupScreen extends StatefulWidget {
  const ListGroupScreen({Key? key}) : super(key: key);

  @override
  _ListGroupScreenState createState() => _ListGroupScreenState();
}

class _ListGroupScreenState extends State<ListGroupScreen> {
  List<dynamic> _groupList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final groupList = await ApiService.getGroup(context);
      if (!mounted) return;
      setState(() {
        _groupList = groupList;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onRefresh: () => initAll(),
              color: AppColors.brown1,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    bottom: 24.0,
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
                                            id:
                                                group['group_id'].toString() ??
                                                '',
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
