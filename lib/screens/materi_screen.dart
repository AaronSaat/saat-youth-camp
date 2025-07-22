import 'package:any_link_preview/any_link_preview.dart'
    show AnyLinkPreview, UIDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter_svg/svg.dart';
import 'package:html/dom.dart' as dom show Element;
import 'package:html/parser.dart' as html_parser show parse;
import 'package:http/http.dart' as http show get;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syc/screens/bible_reading_list_screen.dart';
import 'package:syc/screens/list_evaluasi_screen.dart';
import 'package:syc/screens/bible_reading_more_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_panel_shape.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';
import '../widgets/custom_not_found.dart';
import '../widgets/custom_snackbar.dart';
import 'detail_acara_screen.dart';

class MateriScreen extends StatefulWidget {
  final String? userId;
  const MateriScreen({super.key, required this.userId});

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen> {
  bool _isLoading = true;
  int day = 1;
  Map<String, String> _dataUser = {};
  DateTime? _lastBackPressed;

  @override
  void initState() {
    _lastBackPressed = null;
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await loadUserData();
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      'email',
      'role',
      'token',
      'gereja_id',
      'gereja_nama',
      'kelompok_id',
      'kelompok_nama',
    ];
    final Map<String, String> userData = {};
    for (final key in keys) {
      userData[key] = prefs.getString(key) ?? '';
    }
    if (!mounted) return;
    setState(() {
      _dataUser = userData;
      print('User data HEY: $_dataUser');
    });
  }

  Future<Map<String, String>> fetchMetaTags(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final document = html_parser.parse(response.body);

      String getMeta(String property) {
        final meta = document.head
            ?.getElementsByTagName('meta')
            .firstWhere(
              (e) =>
                  e.attributes['property'] == property ||
                  e.attributes['name'] == property,
              orElse: () => dom.Element.tag('meta'),
            );
        if (meta != null &&
            (meta.attributes['content'] != null &&
                meta.attributes['content']!.isNotEmpty)) {
          return meta.attributes['content']!;
        }
        return '';
      }

      final title =
          document.head?.getElementsByTagName('title').first.text ?? '';
      final description =
          getMeta('og:description').isNotEmpty
              ? getMeta('og:description')
              : getMeta('description');
      final image = getMeta('og:image');

      // Print all values to debug console
      print('Meta Title: $title');
      print('Meta Description: $description');
      print('Meta Image: $image');

      return {'title': title, 'description': description, 'image': image};
    } else {
      throw Exception('Failed to load page');
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
        // body: Center(child: Text("TES - ${_dataUser['id']}")),
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
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 24.0,
                      bottom: 84,
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Image.asset(
                                'assets/texts/materi.png',
                                height: 84,
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.only(right: 8),
                            //   child: Container(
                            //     height: 48,
                            //     width: 48,
                            //     decoration: BoxDecoration(`
                            //       color: Colors.white,
                            //       borderRadius: BorderRadius.circular(16),
                            //     ),
                            //     child: Icon(
                            //       Icons.search,
                            //       color: AppColors.primary,
                            //       size: 32,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _isLoading
                            ? buildAcaraShimmer(context)
                            //     : _acaraList.isEmpty
                            //     ? Center(
                            //       child: CustomNotFound(
                            //         text: "Gagal memuat daftar materi :(",
                            //         textColor: AppColors.brown1,
                            //         imagePath: 'assets/images/data_not_found.png',
                            //         onBack: initAll,
                            //         backText: 'Reload Materi',
                            //       ),
                            //     )
                            : Builder(
                              builder: (context) {
                                return Column(
                                  children: [
                                    // AnyLinkPreview for Instagram
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          const url =
                                              'https://www.instagram.com/story_saat?igsh=MWw4ZHZyc2k5Znk5MA==';
                                          final uri = Uri.parse(url);
                                          bool launched = false;
                                          // Instagram app intent
                                          const instagramScheme =
                                              'instagram://user?username=story_saat';
                                          try {
                                            launched = await launchUrl(
                                              Uri.parse(instagramScheme),
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
                                            );
                                          } catch (_) {}
                                          // WhatsApp app intent (contoh, jika link WhatsApp)
                                          if (!launched &&
                                              url.contains('wa.me')) {
                                            final waUri = Uri.parse(
                                              'whatsapp://send?phone=${uri.pathSegments.last}',
                                            );
                                            try {
                                              launched = await launchUrl(
                                                waUri,
                                                mode:
                                                    LaunchMode
                                                        .externalApplication,
                                              );
                                            } catch (_) {}
                                          }
                                          // Fallback to browser
                                          if (!launched) {
                                            try {
                                              launched = await launchUrl(
                                                uri,
                                                mode:
                                                    LaunchMode
                                                        .externalApplication,
                                              );
                                            } catch (_) {}
                                          }
                                          if (!launched) {
                                            showCustomSnackBar(
                                              context,
                                              'Tidak dapat membuka aplikasi terkait. Pastikan aplikasi atau browser tersedia di perangkat Anda.',
                                            );
                                          }
                                        },
                                        child: AnyLinkPreview(
                                          link:
                                              'https://www.instagram.com/story_saat?igsh=MWw4ZHZyc2k5Znk5MA==',
                                          displayDirection:
                                              UIDirection.uiDirectionVertical,
                                          showMultimedia: true,
                                          bodyMaxLines: 2,
                                          bodyTextOverflow:
                                              TextOverflow.ellipsis,
                                          titleStyle: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          bodyStyle: TextStyle(
                                            color: AppColors.grey4,
                                            fontSize: 14,
                                          ),
                                          errorBody:
                                              'Tidak dapat menampilkan preview.',
                                          errorTitle: 'Link tidak valid',
                                          errorWidget: null,
                                          cache: Duration(hours: 1),
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),

                                    // AnyLinkPreview for Youtube
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: AnyLinkPreview(
                                        link:
                                            'https://www.youtube.com/@STTSAATMalang/',
                                        displayDirection:
                                            UIDirection.uiDirectionVertical,
                                        showMultimedia: true,
                                        bodyMaxLines: 2,
                                        bodyTextOverflow: TextOverflow.ellipsis,
                                        titleStyle: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        bodyStyle: TextStyle(
                                          color: AppColors.grey4,
                                          fontSize: 14,
                                        ),
                                        errorBody:
                                            'Tidak dapat menampilkan preview.',
                                        errorTitle: 'Link tidak valid',
                                        errorWidget: null,
                                        cache: Duration(hours: 1),
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                    // AnyLinkPreview for Berita
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: AnyLinkPreview(
                                        link:
                                            'https://seabs.ac.id/resources/berita/',
                                        displayDirection:
                                            UIDirection.uiDirectionVertical,
                                        showMultimedia: true,
                                        bodyMaxLines: 2,
                                        bodyTextOverflow: TextOverflow.ellipsis,
                                        titleStyle: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        bodyStyle: TextStyle(
                                          color: AppColors.grey4,
                                          fontSize: 14,
                                        ),
                                        errorBody:
                                            'Tidak dapat menampilkan preview.',
                                        errorTitle: 'Link tidak valid',
                                        errorWidget: null,
                                        cache: Duration(hours: 1),
                                        backgroundColor: Colors.white,
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: FutureBuilder<Map<String, String>>(
                                        future: fetchMetaTags(
                                          'https://www.youtube.com/@STTSAATMalang',
                                          // 'https://seabs.ac.id/resources/berita/',
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return const Text(
                                              'Gagal mengambil metadata',
                                            );
                                          }
                                          final meta = snapshot.data!;
                                          return Card(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (meta['image'] != null &&
                                                    meta['image']!.isNotEmpty)
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            12,
                                                          ),
                                                        ),
                                                    child: Image.network(
                                                      meta['image']!,
                                                      height: 120,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ListTile(
                                                  title: Text(
                                                    meta['title'] ?? '',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    meta['description'] ?? '',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(
                                    //     vertical: 8.0,
                                    //   ),
                                    //   child: Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       AnyLinkPreview(
                                    //         link:
                                    //             'https://seabs.ac.id/resources/berita/',
                                    //         displayDirection:
                                    //             UIDirection.uiDirectionVertical,
                                    //         showMultimedia: true,
                                    //         bodyMaxLines: 1, // Show the body
                                    //         bodyTextOverflow:
                                    //             TextOverflow.ellipsis,
                                    //         titleStyle: TextStyle(
                                    //           color: AppColors.primary,
                                    //           fontWeight: FontWeight.bold,
                                    //           fontSize: 16,
                                    //         ),
                                    //         bodyStyle: TextStyle(
                                    //           color: AppColors.grey4,
                                    //           fontSize: 14,
                                    //         ),
                                    //         errorBody:
                                    //             'Tidak dapat menampilkan preview.',
                                    //         errorTitle: 'Link tidak valid',
                                    //         errorWidget: null,
                                    //         cache: Duration(hours: 1),
                                    //         backgroundColor: Colors.white,
                                    //       ),
                                    //       const SizedBox(height: 4),
                                    //       const Text(
                                    //         'Kumpulan berita terbaru dari SEABS.',
                                    //         style: TextStyle(
                                    //           color: Color(0xFF6D6D6D),
                                    //           fontSize: 14,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),

                                    // MateriMenuCard(
                                    //   title: 'Berita',
                                    //   imagePath:
                                    //       'assets/mockups/materi_berita.jpg',
                                    //   onTap: () async {
                                    //     const url =
                                    //         'https://seabs.ac.id/resources/berita/';
                                    //     final uri = Uri.parse(url);
                                    //     bool launched = false;
                                    //     try {
                                    //       launched = await launchUrl(
                                    //         uri,
                                    //         mode:
                                    //             LaunchMode.externalApplication,
                                    //       );
                                    //     } catch (_) {}
                                    //     if (!launched) {
                                    //       try {
                                    //         launched = await launchUrl(
                                    //           uri,
                                    //           mode: LaunchMode.platformDefault,
                                    //         );
                                    //       } catch (_) {}
                                    //     }
                                    //     if (!launched) {
                                    //       showCustomSnackBar(
                                    //         context,
                                    //         'Tidak dapat membuka Berita. Pastikan ada browser di perangkat Anda.',
                                    //       );
                                    //     }
                                    //   },
                                    //   // Progress belum tersedia untuk Bacaan Harian
                                    //   withProgress: false,
                                    // ),
                                  ],
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

  // Shimmer loading untuk daftar acara
  Widget buildAcaraShimmer(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            child: Stack(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 20,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 120,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 180,
                          height: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: MediaQuery.of(context).size.width * 0.1,
                  bottom: MediaQuery.of(context).size.height * 0.007,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 80,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MateriMenuCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final bool withProgress;
  final double valueProgress;
  final int? valueDone;
  final int? valueTotal;

  const MateriMenuCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.withProgress = false,
    this.valueProgress = 0.0,
    this.valueDone,
    this.valueTotal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
            if (withProgress)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: valueProgress,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ),
                    ),
                    if (valueDone != null && valueTotal != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          '$valueDone/$valueTotal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (withProgress) const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
