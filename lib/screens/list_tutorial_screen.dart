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

class ListTutorialScreen extends StatefulWidget {
  const ListTutorialScreen({super.key});

  @override
  State<ListTutorialScreen> createState() => _ListTutorialScreenState();
}

class _ListTutorialScreenState extends State<ListTutorialScreen> {
  bool _isLoading = true;
  int day = 1;
  Map<String, String> _dataUser = {};
  List<Map<String, dynamic>> _tutorialList = [];

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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
      await loadUserData();
      await loadTutorial();
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

  Future<void> loadTutorial({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      const tutorialKey = 'tutorial_list_with_meta';

      if (!forceRefresh) {
        final cachedTutorial = prefs.getString(tutorialKey);
        if (cachedTutorial != null) {
          final List<dynamic> decoded = jsonDecode(cachedTutorial);
          final tutorialWithMeta = decoded.cast<Map<String, dynamic>>();
          setState(() {
            _tutorialList = tutorialWithMeta;
            _isLoading = false;
          });
          print('[PREF_API] dari shared pref Tutorial List');
          return;
        }
      }

      final tutorialList = await ApiService().getTutorial(context);
      // Fetch meta tags untuk semua tutorial sekaligus
      final tutorialWithMeta = await Future.wait(
        tutorialList.map((tutorial) async {
          try {
            final meta = await fetchMetaTags(
              tutorial['url'] ?? '',
              forceRefresh: forceRefresh,
            );
            return {...tutorial, 'meta': meta};
          } catch (e) {
            return {...tutorial, 'meta': {}};
          }
        }),
      );
      // Simpan ke shared pref
      await prefs.setString(tutorialKey, jsonEncode(tutorialWithMeta));
      if (!mounted) return;
      setState(() {
        _tutorialList = tutorialWithMeta;
        _isLoading = false;
        print('[PREF_API] dari API Tutorial List');
      });
    } catch (e) {
      print('❌ Gagal memuat tutorial: $e');
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
    final metaKey = 'tutorial_meta_tags_${Uri.encodeComponent(url)}';

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
    return PopScope(
      canPop: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
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
                onRefresh: () => loadTutorial(forceRefresh: true),
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
                                'assets/texts/tutorial.png',
                                height: 72,
                              ),
                            ),
                          ],
                        ),
                        _isLoading
                            ? buildAcaraShimmer(context)
                            : _tutorialList.isEmpty
                            ? Center(
                              child: CustomNotFound(
                                text: "Gagal memuat daftar tutorial :(",
                                textColor: AppColors.brown1,
                                imagePath: 'assets/images/data_not_found.png',
                                onBack: initAll,
                                backText: 'Reload Tutorial',
                              ),
                            )
                            : Builder(
                              builder: (context) {
                                return Column(
                                  children:
                                      _tutorialList.map((tutorial) {
                                        final meta =
                                            (tutorial['meta'] as Map?)?.map(
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
                                              final url = tutorial['url'] ?? '';
                                              final jenis =
                                                  (tutorial['jenis'] ?? '')
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
                                                      tutorial['nama'] ?? '',
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
                                                          '${tutorial['created_at'] ?? '-'}',
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
