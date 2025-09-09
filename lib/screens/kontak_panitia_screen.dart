import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_snackbar.dart';
import 'package:timeago/timeago.dart'
    as timeago
    show IdMessages, setLocaleMessages;
import 'package:url_launcher/url_launcher.dart'
    show canLaunchUrl, LaunchMode, launchUrl;
import '../services/api_service.dart';

class KontakPanitiaScreen extends StatefulWidget {
  const KontakPanitiaScreen({Key? key}) : super(key: key);

  @override
  _KontakPanitiaScreenState createState() => _KontakPanitiaScreenState();
}

class _KontakPanitiaScreenState extends State<KontakPanitiaScreen> {
  // loadingnya jadi satu saja (tidak perlu dipisah dengan data panitia)
  bool _isLoading = false;

  // progress untuk panitia
  List<dynamic> _dataPanitiaHarian = [];

  @override
  void initState() {
    timeago.setLocaleMessages('id', timeago.IdMessages());
    super.initState();
    initAll();
  }

  Future<void> initAll({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      const panitiaKey = 'kontak_panitia_list';

      if (!forceRefresh) {
        final cachedPanitia = prefs.getString(panitiaKey);
        if (cachedPanitia != null) {
          final List<dynamic> decoded = jsonDecode(cachedPanitia);
          setState(() {
            _dataPanitiaHarian = decoded;
            print("[PREF_API] Data Panitia (from shared pref)");
            _isLoading = false;
          });
          return;
        }
      }

      final dataPanitia = await ApiService.getPanitia(context);

      await prefs.setString(panitiaKey, jsonEncode(dataPanitia));
      if (!mounted) return;
      setState(() {
        _dataPanitiaHarian = dataPanitia;
        print("[PREF_API] Data Panitia (from API)");
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dataPanitiaHarian = [];
        print("Error fetching data panitia : $e");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Kontak Panitia',
          style: TextStyle(
            color: AppColors.brown1,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brown1),
      ),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_anggota.jpg',
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
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 24.0,
                    top: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isLoading
                          ? buildListShimmer(context)
                          : (_dataPanitiaHarian.isEmpty)
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/data_not_found.png',
                                  height: 100,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Gagal memuat data kontak panitia :(",
                                  style: TextStyle(
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
                            itemCount: _dataPanitiaHarian.length,
                            itemBuilder: (context, index) {
                              final panitia = _dataPanitiaHarian[index];
                              String? rawNomor = panitia['hp'];
                              if (rawNomor != null) {
                                rawNomor = rawNomor.replaceAll(
                                  RegExp(r'[^0-9+]'),
                                  '',
                                );
                                if (rawNomor.startsWith('0')) {
                                  rawNomor = '+62${rawNomor.substring(1)}';
                                } else if (!rawNomor.startsWith('+62')) {
                                  rawNomor = '+62$rawNomor';
                                }
                              }
                              final nomor = rawNomor;
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  if (nomor != null && nomor.isNotEmpty) {
                                    final waIntentUrl =
                                        'whatsapp://send?phone=${nomor.replaceAll('+', '')}';
                                    final waMeUrl =
                                        'https://wa.me/${nomor.replaceAll('+', '')}';
                                    final telUrl = 'tel:$nomor';
                                    if (await canLaunchUrl(
                                      Uri.parse(waIntentUrl),
                                    )) {
                                      await launchUrl(
                                        Uri.parse(waIntentUrl),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else if (await canLaunchUrl(
                                      Uri.parse(waMeUrl),
                                    )) {
                                      await launchUrl(
                                        Uri.parse(waMeUrl),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else if (await canLaunchUrl(
                                      Uri.parse(telUrl),
                                    )) {
                                      await launchUrl(
                                        Uri.parse(telUrl),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      showCustomSnackBar(
                                        context,
                                        'Tidak dapat membuka WhatsApp atau Telepon',
                                      );
                                    }
                                  }
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  color: AppColors.brown1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                panitia['nama'] ?? '-',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Divisi: ${panitia['divisi'] ?? '-'}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  const FaIcon(
                                                    FontAwesomeIcons.whatsapp,
                                                    color: Colors.white70,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    nomor ?? '-',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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

Widget buildProgresBacaanPanitiaShimmerCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      height: 1 * 86.0,
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
