import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html/dom.dart' as dom show Element;
import 'package:html/parser.dart' as html_parser show parse;
import 'package:http/http.dart' as http show get;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../widgets/custom_not_found.dart';
import '../widgets/custom_snackbar.dart';

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
  List<Map<String, dynamic>> _materiList = [];

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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
      await loadMateri();
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> loadUserData() async {
    final token = await secureStorage.read(key: 'token');
    final email = await secureStorage.read(key: 'email');
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      // 'token',
      // 'email',
      'role',
      'gereja_id',
      'gereja_nama',
      'kelompok_id',
      'kelompok_nama',
    ];
    final Map<String, String> userData = {};
    for (final key in keys) {
      userData[key] = prefs.getString(key) ?? '';
    }
    userData['token'] = token ?? '';
    userData['email'] = email ?? '';
    if (!mounted) return;
    setState(() {
      _dataUser = userData;
      print('User data HEY: $_dataUser');
    });
  }

  Future<void> loadMateri({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      const materiKey = 'materi_list_with_meta';

      if (!forceRefresh) {
        final cachedMateri = prefs.getString(materiKey);
        if (cachedMateri != null) {
          final List<dynamic> decoded = jsonDecode(cachedMateri);
          final materiWithMeta = decoded.cast<Map<String, dynamic>>();
          setState(() {
            _materiList = materiWithMeta;
            _isLoading = false;
          });
          print('[PREF_API] dari shared pref Materi List');
          return;
        }
      }

      final materiList = await ApiService().getMateri(context);
      // Fetch meta tags untuk semua materi sekaligus
      final materiWithMeta = await Future.wait(
        materiList.map((materi) async {
          try {
            final meta = await fetchMetaTags(
              materi['url'] ?? '',
              forceRefresh: forceRefresh,
            );
            return {...materi, 'meta': meta};
          } catch (e) {
            return {...materi, 'meta': {}};
          }
        }),
      );
      // Simpan ke shared pref
      await prefs.setString(materiKey, jsonEncode(materiWithMeta));
      if (!mounted) return;
      setState(() {
        _materiList = materiWithMeta;
        _isLoading = false;
        print('[PREF_API] dari API Materi List');
      });
    } catch (e) {
      print('❌ Gagal memuat materi: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, String>> fetchMetaTags(
    String url, {
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final metaKey = 'materi_meta_tags_${Uri.encodeComponent(url)}';

    if (!forceRefresh) {
      final cachedMeta = prefs.getString(metaKey);
      if (cachedMeta != null) {
        final Map<String, dynamic> decoded = jsonDecode(cachedMeta);
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    }

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

      final metaMap = {
        'title': title,
        'description': description,
        'image': image,
      };
      await prefs.setString(metaKey, jsonEncode(metaMap));
      return metaMap;
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
            Future.delayed(const Duration(milliseconds: 100), () {
              SystemNavigator.pop();
            });
          }
        }
      },
      child: Scaffold(
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
                onRefresh: () => loadMateri(forceRefresh: true),
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
                          ],
                        ),
                        _isLoading
                            ? buildAcaraShimmer(context)
                            : _materiList.isEmpty
                            ? Center(
                              child: CustomNotFound(
                                text: "Saat ini materi belum tersedia :(",
                                textColor: AppColors.brown1,
                                imagePath: 'assets/images/data_not_found.png',
                                onBack: initAll,
                                backText: 'Reload Materi',
                              ),
                            )
                            : Builder(
                              builder: (context) {
                                return Column(
                                  children:
                                      _materiList.map((materi) {
                                        final meta =
                                            (materi['meta'] as Map?)?.map(
                                              (k, v) => MapEntry(
                                                k.toString(),
                                                v.toString(),
                                              ),
                                            ) ??
                                            <String, String>{};
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: GestureDetector(
                                            onTap: () async {
                                              final url = materi['url'] ?? '';
                                              final jenis =
                                                  (materi['jenis'] ?? '')
                                                      .toLowerCase();
                                              if (jenis == 'lainnya') {
                                                if (await canLaunchUrl(
                                                  Uri.parse(url),
                                                )) {
                                                  await launchUrl(
                                                    Uri.parse(url),
                                                    mode:
                                                        LaunchMode
                                                            .externalApplication,
                                                  );
                                                }
                                              } else {
                                                if (await canLaunchUrl(
                                                  Uri.parse(url),
                                                )) {
                                                  final launched = await launchUrl(
                                                    Uri.parse(url),
                                                    mode:
                                                        LaunchMode
                                                            .externalApplication,
                                                  );
                                                  if (!launched) {
                                                    await launchUrl(
                                                      Uri.parse(url),
                                                      mode:
                                                          LaunchMode
                                                              .platformDefault,
                                                    );
                                                  }
                                                } else {
                                                  await launchUrl(
                                                    Uri.parse(url),
                                                    mode:
                                                        LaunchMode
                                                            .platformDefault,
                                                  );
                                                }
                                              }
                                            },
                                            child: Card(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (meta['image'] != null &&
                                                      meta['image']!.isNotEmpty)
                                                    ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
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
                                                      materi['nama'] ?? '',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (meta['description'] !=
                                                                null &&
                                                            meta['description']!
                                                                .isNotEmpty &&
                                                            // Tambahkan pengecekan agar tidak menampilkan jika mengandung '@import' atau 'url('
                                                            !meta['description']!
                                                                .contains(
                                                                  '@import',
                                                                ) &&
                                                            !meta['description']!
                                                                .contains(
                                                                  'url(',
                                                                ))
                                                          Text(
                                                            meta['description']!,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          '${materi['created_at'] ?? '-'}',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
          ],
        ),
      ),
    );
  }
}
