import 'dart:io';
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
  int _selectedSettingIndex = 0;
  int _selectedLogoIndex = 0;
  int _selectedAspectRatioIndex = 0; // 0: 3/4, 1: 9/16, 2: 1/1

  // Ayat settings
  double? _fontSize = 12;
  TextAlign? _textAlign = TextAlign.center;
  FontWeight? _fontWeight = FontWeight.normal;
  FontStyle? _fontStyle = FontStyle.normal;
  int _versePosition = 1; // 0: atas, 1: tengah, 2: bawah

  // Perikop settings
  int _perikopPosition =
      3; // 0: Atas layar, 1: Bawah layar, 2: Atas ayat, 3: Bawah ayat (default: bawah ayat)
  double? _perikopFontSize = 22;
  TextAlign? _perikopTextAlign = TextAlign.center;
  FontWeight? _perikopFontWeight = FontWeight.w900;
  FontStyle? _perikopFontStyle = FontStyle.normal;

  // List foto utama (hanya 3 jenis)
  final List<String> _photoBaseNames = [
    'photo1.png',
    'photo2.png',
    'photo3.png',
    'photo4.png',
  ];

  // Map rasio ke prefix asset
  final Map<int, String> _ratioPrefix = {
    0: '', // 3/4: photo1.png, photo2.png, photo3.png, photo4.png
    1: 'photostory', // 9/16: photostory1.png, ...
    2: 'photosquare', // 1/1: photosquare1.png, ...
  };

  // Fungsi untuk dapatkan asset sesuai rasio dan index
  String getPhotoAsset(int ratioIndex, int photoIndex) {
    if (ratioIndex == 0) {
      return 'assets/shareverse/${_photoBaseNames[photoIndex]}';
    } else {
      final prefix = _ratioPrefix[ratioIndex]!;
      final num = photoIndex + 1;
      return 'assets/shareverse/$prefix$num.png';
    }
  }

  final List<String> _logoAssets = [
    'assets/logos/appicon4.png', // atas
    'assets/logos/appicon4.png', // bawah
    'assets/logos/appicon5.png', // atas
    'assets/logos/appicon5.png', // bawah
  ];
  final List<bool> _logoIsAtas = [true, false, true, false];
  final List<String> _logoLabels = ['Atas', 'Bawah', 'Atas', 'Bawah'];
  final List<String> _aspectLabels = ['3:4', '9:16', '1:1'];

  // Tambahkan item Bagikan Gambar ke list setting
  final List<_SettingItem> _settingItems = [
    _SettingItem(Icons.image, 'Gambar'),
    _SettingItem(Icons.edit_note, 'Ayat'),
    _SettingItem(Icons.edit, 'Perikop'),
    _SettingItem(Icons.aspect_ratio, 'Rasio'),
    _SettingItem(Icons.info, 'Logo'),
    _SettingItem(Icons.share, 'Bagikan'),
  ];

  // Tambahkan state fontFamily untuk ayat dan perikop
  String _ayatFontFamily = 'Roboto';
  String _perikopFontFamily = 'Roboto';

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
          // subject: 'Ayat Alkitab',
          // text: 'Ini generated dari aplikasi SYC 2025',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membagikan gambar: $e')));
    }
  }

  // Tambahkan fungsi builder untuk 3 template desain:
  Widget buildShareDesign() {
    List<Widget> children = [];

    // Perikop di atas layar
    if (_perikopPosition == 0) {
      children.add(_buildPerikopWidget());
      children.add(const SizedBox(height: 12));
    }

    // Atas
    if (_versePosition == 0) {
      if (_perikopPosition == 2) children.add(_buildPerikopWidget());
      children.add(_buildAyatWidget());
      if (_perikopPosition == 3) children.add(_buildPerikopWidget());
      children.add(const Spacer());
    }
    // Tengah
    else if (_versePosition == 1) {
      children.add(const Spacer());
      if (_perikopPosition == 2) children.add(_buildPerikopWidget());
      children.add(_buildAyatWidget());
      if (_perikopPosition == 3) children.add(_buildPerikopWidget());
      children.add(const Spacer());
    }
    // Bawah
    else {
      children.add(const Spacer());
      if (_perikopPosition == 2) children.add(_buildPerikopWidget());
      children.add(_buildAyatWidget());
      if (_perikopPosition == 3) children.add(_buildPerikopWidget());
    }

    // Perikop di bawah layar
    if (_perikopPosition == 1) {
      children.add(const SizedBox(height: 12));
      children.add(_buildPerikopWidget());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.asset(
                getPhotoAsset(_selectedAspectRatioIndex, _selectedPhotoIndex),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
        // Logo atas
        if (_logoIsAtas[_selectedLogoIndex]) ...[
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _logoAssets[_selectedLogoIndex],
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
          ),
        ],
        // Logo bawah
        if (!_logoIsAtas[_selectedLogoIndex]) ...[
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _logoAssets[_selectedLogoIndex],
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
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.primary,
        ),
        title: const Text(
          'Bagikan Ayat',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
              : Align(
                alignment: Alignment.topCenter,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxImageHeight = constraints.maxHeight * 0.6;
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _selectedAspectRatioIndex == 0 ||
                                  _selectedAspectRatioIndex == 1
                              ? SizedBox(
                                height: maxImageHeight,
                                child: AspectRatio(
                                  aspectRatio:
                                      _selectedAspectRatioIndex == 0
                                          ? 3 / 4
                                          : 9 / 16,
                                  child: RepaintBoundary(
                                    key: _shareKey,
                                    child: buildShareDesign(),
                                  ),
                                ),
                              )
                              : SizedBox(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: RepaintBoundary(
                                    key: _shareKey,
                                    child: buildShareDesign(),
                                  ),
                                ),
                              ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            bottom: MediaQuery.of(context).size.height * 0.01,
            child: SafeArea(
              child: SizedBox(
                height:
                    (_selectedSettingIndex != _settingItems.length - 1)
                        ? 210
                        : 70, // extend height jika bukan Bagikan
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Konten setting di atas tab bar, tinggi tetap misal 110
                      if (_selectedSettingIndex != _settingItems.length - 1)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                            child: Builder(
                              builder: (context) {
                                switch (_selectedSettingIndex) {
                                  case 0: // Gambar
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        _photoBaseNames.length,
                                        (index) => Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedPhotoIndex = index;
                                              });
                                            },
                                            child: Container(
                                              height: 64,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      _selectedPhotoIndex ==
                                                              index
                                                          ? AppColors.secondary
                                                          : Colors.transparent,
                                                  width: 3,
                                                ),
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                    getPhotoAsset(
                                                      _selectedAspectRatioIndex,
                                                      index,
                                                    ),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  case 1: // Edit Teks Ayat
                                    return SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Font Family
                                          Row(
                                            children: [
                                              const Text('Jenis:'),
                                              const SizedBox(width: 8),
                                              ...['Roboto', 'Geist'].map((
                                                font,
                                              ) {
                                                final selected =
                                                    _ayatFontFamily == font;
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _ayatFontFamily = font;
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      font,
                                                      style: TextStyle(
                                                        color:
                                                            selected
                                                                ? Colors.white
                                                                : AppColors
                                                                    .primary,
                                                        fontWeight:
                                                            selected
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Font Size
                                          Row(
                                            children: [
                                              const Text('Ukuran:'),
                                              Expanded(
                                                child: Slider(
                                                  min: 12,
                                                  max: getAyatMaxFontSize(
                                                    widget.ayatText,
                                                  ),
                                                  value: (_fontSize ?? 12)
                                                      .clamp(
                                                        12,
                                                        getAyatMaxFontSize(
                                                          widget.ayatText,
                                                        ),
                                                      ),
                                                  onChanged: (val) {
                                                    setState(() {
                                                      _fontSize = val;
                                                    });
                                                  },
                                                ),
                                              ),
                                              Text(
                                                '${_fontSize?.toInt() ?? 12}',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Align
                                          Row(
                                            children: [
                                              const Text('Align:'),
                                              const SizedBox(width: 4),
                                              ...[
                                                {
                                                  'icon':
                                                      Icons.format_align_left,
                                                  'label': 'Kiri',
                                                  'value': TextAlign.left,
                                                },
                                                {
                                                  'icon':
                                                      Icons.format_align_center,
                                                  'label': 'Tengah',
                                                  'value': TextAlign.center,
                                                },
                                                {
                                                  'icon':
                                                      Icons.format_align_right,
                                                  'label': 'Kanan',
                                                  'value': TextAlign.right,
                                                },
                                                {
                                                  'icon':
                                                      Icons
                                                          .format_align_justify,
                                                  'label': 'Justify',
                                                  'value': TextAlign.justify,
                                                },
                                              ].map((item) {
                                                final selected =
                                                    _textAlign == item['value'];
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _textAlign =
                                                          item['value']
                                                              as TextAlign;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          item['icon']
                                                              as IconData,
                                                          color:
                                                              selected
                                                                  ? Colors.white
                                                                  : AppColors
                                                                      .primary,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          item['label']
                                                              as String,
                                                          style: TextStyle(
                                                            color:
                                                                selected
                                                                    ? Colors
                                                                        .white
                                                                    : AppColors
                                                                        .primary,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                selected
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Font Weight
                                          Row(
                                            children: [
                                              const Text('Berat:'),
                                              const SizedBox(width: 4),
                                              ...[
                                                {
                                                  'label': 'Normal',
                                                  'value': FontWeight.normal,
                                                },
                                                {
                                                  'label': 'Bold',
                                                  'value': FontWeight.bold,
                                                },
                                                {
                                                  'label': 'W500',
                                                  'value': FontWeight.w500,
                                                },
                                                {
                                                  'label': 'W900',
                                                  'value': FontWeight.w900,
                                                },
                                              ].map((item) {
                                                final selected =
                                                    _fontWeight ==
                                                    item['value'];
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _fontWeight =
                                                          item['value']
                                                              as FontWeight;
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      item['label'] as String,
                                                      style: TextStyle(
                                                        color:
                                                            selected
                                                                ? Colors.white
                                                                : AppColors
                                                                    .primary,
                                                        fontWeight:
                                                            selected
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Font Style
                                          Row(
                                            children: [
                                              const Text('Gaya:'),
                                              const SizedBox(width: 8),
                                              ...[
                                                {
                                                  'label': 'Normal',
                                                  'value': FontStyle.normal,
                                                  'icon': Icons.text_fields,
                                                },
                                                {
                                                  'label': 'Italic',
                                                  'value': FontStyle.italic,
                                                  'icon': Icons.format_italic,
                                                },
                                              ].map((item) {
                                                final selected =
                                                    _fontStyle == item['value'];
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _fontStyle =
                                                          item['value']
                                                              as FontStyle;
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          item['icon']
                                                              as IconData,
                                                          color:
                                                              selected
                                                                  ? Colors.white
                                                                  : AppColors
                                                                      .primary,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          item['label']
                                                              as String,
                                                          style: TextStyle(
                                                            color:
                                                                selected
                                                                    ? Colors
                                                                        .white
                                                                    : AppColors
                                                                        .primary,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                selected
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Posisi Ayat
                                          Row(
                                            children: [
                                              const Text('Posisi:'),
                                              const SizedBox(width: 8),
                                              ...[
                                                {'label': 'Atas', 'value': 0},
                                                {'label': 'Tengah', 'value': 1},
                                                {'label': 'Bawah', 'value': 2},
                                              ].map((item) {
                                                final selected =
                                                    _versePosition ==
                                                    item['value'];
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _versePosition =
                                                          item['value'] as int;
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      item['label'] as String,
                                                      style: TextStyle(
                                                        color:
                                                            selected
                                                                ? Colors.white
                                                                : AppColors
                                                                    .primary,
                                                        fontWeight:
                                                            selected
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  case 2: // Edit Teks Perikop
                                    return SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Font Family
                                          Row(
                                            children: [
                                              const Text('Jenis:'),
                                              const SizedBox(width: 8),
                                              ...['Roboto', 'Geist'].map((
                                                font,
                                              ) {
                                                final selected =
                                                    _perikopFontFamily == font;
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _perikopFontFamily = font;
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      font,
                                                      style: TextStyle(
                                                        color:
                                                            selected
                                                                ? Colors.white
                                                                : AppColors
                                                                    .primary,
                                                        fontWeight:
                                                            selected
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Font Size
                                          Row(
                                            children: [
                                              const Text('Ukuran:'),
                                              Expanded(
                                                child: Slider(
                                                  min: 14,
                                                  max: 28,
                                                  value: _perikopFontSize ?? 16,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      _perikopFontSize = val;
                                                    });
                                                  },
                                                ),
                                              ),
                                              Text(
                                                '${_perikopFontSize?.toInt() ?? 22}',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Align
                                          Row(
                                            children: [
                                              const Text('Align:'),
                                              const SizedBox(width: 4),
                                              ...[
                                                {
                                                  'icon':
                                                      Icons.format_align_left,
                                                  'label': 'Kiri',
                                                  'value': TextAlign.left,
                                                },
                                                {
                                                  'icon':
                                                      Icons.format_align_center,
                                                  'label': 'Tengah',
                                                  'value': TextAlign.center,
                                                },
                                                {
                                                  'icon':
                                                      Icons.format_align_right,
                                                  'label': 'Kanan',
                                                  'value': TextAlign.right,
                                                },
                                              ].map((item) {
                                                final selected =
                                                    _perikopTextAlign ==
                                                    item['value'];
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _perikopTextAlign =
                                                          item['value']
                                                              as TextAlign;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          item['icon']
                                                              as IconData,
                                                          color:
                                                              selected
                                                                  ? Colors.white
                                                                  : AppColors
                                                                      .primary,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          item['label']
                                                              as String,
                                                          style: TextStyle(
                                                            color:
                                                                selected
                                                                    ? Colors
                                                                        .white
                                                                    : AppColors
                                                                        .primary,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                selected
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Font Weight
                                          Row(
                                            children: [
                                              const Text('Berat:'),
                                              const SizedBox(width: 4),
                                              ...[
                                                {
                                                  'label': 'Normal',
                                                  'value': FontWeight.normal,
                                                },
                                                {
                                                  'label': 'Bold',
                                                  'value': FontWeight.bold,
                                                },
                                                {
                                                  'label': 'W500',
                                                  'value': FontWeight.w500,
                                                },
                                                {
                                                  'label': 'W900',
                                                  'value': FontWeight.w900,
                                                },
                                              ].map((item) {
                                                final selected =
                                                    _perikopFontWeight ==
                                                    item['value'];
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _perikopFontWeight =
                                                          item['value']
                                                              as FontWeight;
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      item['label'] as String,
                                                      style: TextStyle(
                                                        color:
                                                            selected
                                                                ? Colors.white
                                                                : AppColors
                                                                    .primary,
                                                        fontWeight:
                                                            selected
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Font Style
                                          Row(
                                            children: [
                                              const Text('Gaya:'),
                                              const SizedBox(width: 8),
                                              ...[
                                                {
                                                  'label': 'Normal',
                                                  'value': FontStyle.normal,
                                                  'icon': Icons.text_fields,
                                                },
                                                {
                                                  'label': 'Italic',
                                                  'value': FontStyle.italic,
                                                  'icon': Icons.format_italic,
                                                },
                                              ].map((item) {
                                                final selected =
                                                    _perikopFontStyle ==
                                                    item['value'];
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _perikopFontStyle =
                                                          item['value']
                                                              as FontStyle;
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          item['icon']
                                                              as IconData,
                                                          color:
                                                              selected
                                                                  ? Colors.white
                                                                  : AppColors
                                                                      .primary,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          item['label']
                                                              as String,
                                                          style: TextStyle(
                                                            color:
                                                                selected
                                                                    ? Colors
                                                                        .white
                                                                    : AppColors
                                                                        .primary,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                selected
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Posisi Perikop
                                          Row(
                                            children: [
                                              const Text('Posisi:'),
                                              const SizedBox(width: 8),
                                              ...[
                                                {'label': 'Atas', 'value': 0},
                                                {'label': 'Bawah', 'value': 1},
                                                {
                                                  'label': 'Atas Ayat',
                                                  'value': 2,
                                                },
                                                {
                                                  'label': 'Bawah Ayat',
                                                  'value': 3,
                                                },
                                              ].map((item) {
                                                final selected =
                                                    _perikopPosition ==
                                                    item['value'];
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _perikopPosition =
                                                          item['value'] as int;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4,
                                                          horizontal: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      item['label'] as String,
                                                      style: TextStyle(
                                                        color:
                                                            selected
                                                                ? Colors.white
                                                                : AppColors
                                                                    .primary,
                                                        fontWeight:
                                                            selected
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  case 4: // Logo
                                    return SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 12),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: 4,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  mainAxisSpacing: 12,
                                                  crossAxisSpacing: 12,
                                                  childAspectRatio: 2.8,
                                                ),
                                            itemBuilder: (context, index) {
                                              final selected =
                                                  _selectedLogoIndex == index;
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedLogoIndex = index;
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        selected
                                                            ? AppColors.primary
                                                            : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color: AppColors.primary,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 8,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                        _logoAssets[index],
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        _logoLabels[index],
                                                        style: TextStyle(
                                                          color:
                                                              selected
                                                                  ? Colors.white
                                                                  : AppColors
                                                                      .primary,
                                                          fontWeight:
                                                              selected
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  case 3: // Rasio
                                    return SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 12),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: 3,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  mainAxisSpacing: 12,
                                                  crossAxisSpacing: 12,
                                                  childAspectRatio: 1.0,
                                                ),
                                            itemBuilder: (context, index) {
                                              final selected =
                                                  _selectedAspectRatioIndex ==
                                                  index;
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedAspectRatioIndex =
                                                        index;
                                                  });
                                                },
                                                child: Container(
                                                  // width: 120,
                                                  // height:
                                                  //     _selectedAspectRatioIndex ==
                                                  //             0
                                                  //         ? 120 * 4 / 3
                                                  //         : _selectedAspectRatioIndex ==
                                                  //             1
                                                  //         ? 120 * 16 / 9
                                                  //         : 120,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        selected
                                                            ? AppColors.primary
                                                            : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color: AppColors.primary,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 8,
                                                      ),
                                                  child: Center(
                                                    child: Text(
                                                      _aspectLabels[index],
                                                      style: TextStyle(
                                                        color:
                                                            selected
                                                                ? Colors.white
                                                                : AppColors
                                                                    .primary,
                                                        fontWeight:
                                                            selected
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  default:
                                    return const Center(
                                      child: Text(
                                        'Belum ada settingan khusus.',
                                      ),
                                    );
                                }
                              },
                            ),
                          ),
                        ),
                      // Tab bar selalu di bawah
                      SizedBox(
                        height: 64,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(_settingItems.length, (
                            index,
                          ) {
                            final item = _settingItems[index];
                            final isSelected = _selectedSettingIndex == index;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_selectedSettingIndex == index) {
                                    // Jika sudah terpilih, unselect (tutup konten setting)
                                    _selectedSettingIndex =
                                        _settingItems.length -
                                        1; // index Bagikan
                                  } else {
                                    _selectedSettingIndex = index;
                                  }
                                });
                                if (item.icon == Icons.share) {
                                  _shareImage(context);
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Icon(
                                        item.icon,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : AppColors.grey4,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        fontSize: 10,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
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

  // Helper widget
  Widget _buildAyatWidget() => Text(
    widget.ayatText,
    style: TextStyle(
      fontFamily: _ayatFontFamily,
      fontSize: _fontSize ?? 18,
      color: Colors.white,
      fontWeight: _fontWeight ?? FontWeight.normal,
      fontStyle: _fontStyle ?? FontStyle.normal,
      shadows: const [
        Shadow(blurRadius: 3, color: AppColors.black1, offset: Offset(1, 1)),
      ],
    ),
    textAlign: _textAlign ?? TextAlign.center,
  );

  // Ubah _buildPerikopWidget agar pakai setting perikop
  Widget _buildPerikopWidget() => Text(
    widget.perikop.toUpperCase(),
    style: TextStyle(
      fontFamily: _perikopFontFamily,
      fontWeight: _perikopFontWeight ?? FontWeight.w900,
      fontSize: _perikopFontSize ?? 22,
      color: Colors.white,
      fontStyle: _perikopFontStyle ?? FontStyle.normal,
      shadows: const [
        Shadow(blurRadius: 3, color: AppColors.black1, offset: Offset(1, 1)),
      ],
    ),
    textAlign: _perikopTextAlign ?? TextAlign.center,
  );

  // Tambahkan fungsi untuk menentukan max font size ayat
  double getAyatMaxFontSize(String ayat) {
    final len = ayat.length;
    if (len < 100) return 24;
    if (len < 200) return 20;
    if (len < 300) return 16;
    return 14;
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  const _SettingItem(this.icon, this.label);
}
