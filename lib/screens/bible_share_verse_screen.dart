import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:syc/utils/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';

class BibleShareVerseScreen extends StatefulWidget {
  final String perikop;
  final String ayatText;

  const BibleShareVerseScreen({
    super.key,
    required this.perikop,
    required this.ayatText,
  });

  @override
  State<BibleShareVerseScreen> createState() => _BibleShareVerseScreenState();
}

class _BibleShareVerseScreenState extends State<BibleShareVerseScreen> {
  final GlobalKey _shareKey = GlobalKey();
  bool _isLoading = true;
  Map<String, String> _dataUser = {};
  int _selectedPhotoIndex = 0;
  final List<String> _photoAssets = [
    'assets/shareverse/photo1.png',
    'assets/shareverse/photo2.png',
    'assets/shareverse/photo3.png',
  ];

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
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> loadUserData() async {
    if (!mounted) return;
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      'nama',
      'divisi',
      'email',
      'group_id',
      'role',
      'count_roles',
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
      print('Data user loaded: $_dataUser');
    });
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary =
          _shareKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/share_verse.png').create();
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Ayat Alkitab',
          text: 'Ini generated dari aplikasi SYC 2025',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membagikan gambar: $e')));
    }
  }

  // Tambahkan fungsi builder untuk 3 template desain:
  Widget buildShareDesign(int index) {
    switch (index) {
      case 0:
        // Template 1: Perikop & ayat di tengah, logo SYC di bawah
        return Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.asset(
                    _photoAssets[0],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withAlpha(20),
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.perikop.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 3,
                            color: AppColors.black1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.ayatText,
                      style: TextStyle(
                        fontSize: widget.ayatText.length > 75 ? 16 : 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        shadows: const [
                          Shadow(
                            blurRadius: 3,
                            color: AppColors.black1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logos/appicon3.png',
                        width: 24,
                        height: 24,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'SYC 2025',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                blurRadius: 3,
                                color: AppColors.black1,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        // Template 2: Perikop di atas, ayat di tengah besar, logo SYC di atas
        return Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                _photoAssets[1],
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Logo dan nama acara di atas gambar
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos/appicon4.png',
                    width: 24,
                    height: 24,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'SYC 2025',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            blurRadius: 3,
                            color: AppColors.primary,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Konten ayat dan perikop di bawah gambar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.ayatText,
                      style: TextStyle(
                        fontSize: widget.ayatText.length > 75 ? 16 : 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        shadows: const [
                          Shadow(
                            blurRadius: 3,
                            color: AppColors.black1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.perikop.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 3,
                            color: AppColors.black1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 2:
        // Template 3: Logo SYC di atas, ayat di bawah, perikop di bawah ayat
        return Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                _photoAssets[2],
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos/appicon2.png',
                    width: 24,
                    height: 24,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'SYC 2025',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            blurRadius: 3,
                            color: AppColors.black1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.ayatText,
                  style: TextStyle(
                    fontSize: widget.ayatText.length > 75 ? 16 : 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: AppColors.black1,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Text(
                widget.perikop.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 3,
                      color: AppColors.black1,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Misal data user sudah ada di _dataUser
    final role = _dataUser['role'] ?? '';
    final namaUser = _dataUser['nama'] ?? '';
    final namaKelompok = _dataUser['kelompok_nama'] ?? '';
    final namaGereja = _dataUser['gereja_nama'] ?? '';
    final avatarUrl = _dataUser['avatar_url'] ?? ''; // Pastikan field ini ada

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
        title: const Text(
          'Bagikan Ayat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_login.jpg',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio:
                          3 /
                          4, // atau 4/5, 3/4, dsb sesuai kebutuhan desain Anda
                      child: RepaintBoundary(
                        key: _shareKey,
                        child: buildShareDesign(_selectedPhotoIndex),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Bagikan Gambar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _shareImage(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_photoAssets.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPhotoIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    _selectedPhotoIndex == index
                                        ? AppColors.secondary
                                        : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: AssetImage(_photoAssets[index]),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
