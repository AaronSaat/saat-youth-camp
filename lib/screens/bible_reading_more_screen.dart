import 'dart:convert'; // Tambahkan jika belum ada
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:syc/screens/bible_share_verse_screen.dart';
import 'package:syc/screens/catatan_harian_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_card.dart';
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/custom_not_found.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_text_field.dart';

class BibleReadingMoreScreen extends StatefulWidget {
  final String userId;
  final DateTime date;
  const BibleReadingMoreScreen({
    super.key,
    required this.userId,
    required this.date,
  });

  @override
  State<BibleReadingMoreScreen> createState() => _BibleReadingMoreScreenState();
}

class _BibleReadingMoreScreenState extends State<BibleReadingMoreScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>>? _dataBrm;
  Map<String, dynamic>? _dataBible;
  List<dynamic> _books = [];
  int idNotes = 0;
  int countRead = 0;
  double fontSize_judul = 32;
  double fontSize_subjudul = 18;
  double fontSize_ayat = 10;
  double fontSize_isi_ayat = 14;
  Map<String, String> _dataUser = {};
  final TextEditingController _noteController = TextEditingController();
  String notes = '';
  bool isEdit = false;
  int? _selectedVerseNumber;
  String? _selectedBookName;
  String? _selectedChapterNum;

  int? _countUserDoneRead;
  int? _totalUser;

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    print('isEdit: $isEdit');
    try {
      await loadUserData();
      await loadBrm(forceRefresh: forceRefresh);
      await loadReportBrmReportByPesertaByDay();
      await loadCount(forceRefresh: forceRefresh);
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
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
    });
  }

  Future<void> loadBrm({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = widget.userId;
    final date = widget.date.toIso8601String().substring(0, 10);
    final brmKey = 'brm_reading_more_${userId}_$date';

    if (!forceRefresh) {
      final cachedBrm = prefs.getString(brmKey);
      if (cachedBrm != null) {
        final response = jsonDecode(cachedBrm);
        setState(() {
          _dataBible = response['data_bible'] as Map<String, dynamic>?;
          _books = parseBooks(_dataBible);
          if (response['data_brm'] is List) {
            _dataBrm = List<Map<String, dynamic>>.from(response['data_brm']);
          } else if (response['data_brm'] is Map<String, dynamic>) {
            _dataBrm = [response['data_brm'] as Map<String, dynamic>];
          } else {
            _dataBrm = null;
          }
          if (response['data_bible'] is Map<String, dynamic>) {
            _dataBible = response['data_bible'] as Map<String, dynamic>;
          } else {
            _dataBible = null;
          }
          print('[PREF_API] BRM hari ini (from shared pref): $_dataBrm');
        });
        return;
      }
    }

    try {
      // final response = await ApiService.getBrmToday(context);
      print('[API] Memuat BRM hari ini... $date');
      final response = await ApiService.getBrmByDay(context, date);
      await prefs.setString(brmKey, jsonEncode(response));
      setState(() {
        _dataBible = response['data_bible'] as Map<String, dynamic>?;
        _books = parseBooks(_dataBible);
        if (response['data_brm'] is List) {
          _dataBrm = List<Map<String, dynamic>>.from(response['data_brm']);
        } else if (response['data_brm'] is Map<String, dynamic>) {
          _dataBrm = [response['data_brm'] as Map<String, dynamic>];
        } else {
          _dataBrm = null;
        }
        if (response['data_bible'] is Map<String, dynamic>) {
          _dataBible = response['data_bible'] as Map<String, dynamic>;
        } else {
          _dataBible = null;
        }
        print('[PREF_API] BRM hari ini (from API): $_dataBrm');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> loadReportBrmReportByPesertaByDay() async {
    try {
      final report = await ApiService.getBrmReportByPesertaByDay(
        context,
        widget.userId,
        widget.date.toIso8601String().substring(0, 10),
      );
      if (!mounted) return;
      setState(() {
        if (report['data_notes'] != null) {
          idNotes = report['data_notes']['id'] ?? 0;
          notes = report['data_notes']['notes'] ?? '';
          countRead = report['count_read'] ?? 0;
          print(
            'VANILLA idNotes: $idNotes, notes: $notes, countRead: $countRead',
          );
        } else {
          idNotes = 0;
          notes = '';
          countRead = 0;
        }
      });
    } catch (e) {}
  }

  Future<void> loadCount({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _countUserDoneRead = null;
      _totalUser = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final dateKey = widget.date.toIso8601String().substring(0, 10);
    final countKey = 'brm_count_${dateKey}';
    final totalUserKey = 'brm_total_user';

    if (!forceRefresh) {
      final cachedCount = prefs.getString(countKey);
      final cachedTotalUser = prefs.getString(totalUserKey);
      print(
        '[loadCount] Mengambil dari cache: countKey=$countKey, totalUserKey=$totalUserKey',
      );
      if (cachedCount != null && cachedTotalUser != null) {
        final cachedData = jsonDecode(cachedCount);
        final cachedTotal = int.tryParse(cachedTotalUser);
        setState(() {
          _countUserDoneRead =
              (int.tryParse(cachedData['count_peserta']?.toString() ?? '0') ??
                  0) +
              (int.tryParse(cachedData['count_pembina']?.toString() ?? '0') ??
                  0);
          _totalUser = cachedTotal;
        });
        print(
          '[loadCount] Data dari cache: countUserDoneRead=$_countUserDoneRead, totalUser=$_totalUser',
        );
        return;
      }
    }
    try {
      print('[loadCount] Memuat data dari API...');
      final response = await ApiService.getCountUser(context);
      final dataBacaan = await ApiService.getCountBrmReportByDay(
        context,
        dateKey,
      );
      // Simpan ke shared preferences
      await prefs.setString(countKey, jsonEncode(dataBacaan));
      await prefs.setString(
        totalUserKey,
        (response['count']?.toString() ?? '0'),
      );
      if (!mounted) return;
      setState(() {
        _countUserDoneRead =
            (int.tryParse(dataBacaan['count_peserta']?.toString() ?? '0') ??
                0) +
            (int.tryParse(dataBacaan['count_pembina']?.toString() ?? '0') ?? 0);
        _totalUser = int.tryParse(response['count']?.toString() ?? '0');
        print(
          '[loadCount] Data dari API: countUserDoneRead=$_countUserDoneRead, totalUser=$_totalUser',
        );
      });
    } catch (e) {
      print('[loadCount] Error: $e');
    }
  }

  List<dynamic> parseBooks(Map<String, dynamic>? dataBible) {
    if (dataBible == null) return [];
    if (dataBible['book'] is List) {
      return dataBible['book'] as List<dynamic>;
    } else if (dataBible['book'] != null) {
      return [dataBible['book']];
    }
    return [];
  }

  Future<void> _handleSubmit() async {
    showDialog(
      context: context,
      builder:
          (context) => CustomAlertDialog(
            title: 'Konfirmasi',
            content: 'Apakah Anda yakin sudah selesai membaca?',
            cancelText: 'Belum',
            confirmText: 'Ya',
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: () async {
              Navigator.of(context).pop();
              setState(() => _isLoading = true);
              final userId =
                  int.tryParse(widget.userId.toString()) ?? widget.userId;
              final brmId = _dataBrm![0]['id'];
              Map<String, dynamic> brmDoneRead = {
                "brm_id": brmId,
                "user_id": userId,
              };
              Map<String, dynamic> brmNotes = {
                "user_id": userId,
                "brm_id": brmId,
                "notes": _noteController.text.toString().trim(),
              };

              try {
                final res1 = await ApiService.postBrmDoneRead(
                  context,
                  brmDoneRead,
                );
                final res2 = await ApiService.postBrmNotes(context, brmNotes);
                print('VANILLA res1: $res1');
                print('VANILLA res2: $res2');

                if (res1['success'] == true && res2['success'] == true) {
                  // if (!mounted) return;
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => BibleReadingSuccessScreen(),
                  //   ),
                  // );
                  // if (!mounted) return;
                  // showCustomSnackBar(
                  //   context,
                  //   'Progress bacaan dan catatan hari ini berhasil disimpan!',
                  //   isSuccess: true,
                  // );
                  await initAll(); // reload data
                } else {
                  // Salah satu gagal, tampilkan pesan error
                  if (!mounted) return;
                  showCustomSnackBar(
                    context,
                    'Gagal menyimpan data. Silakan coba lagi.',
                    isSuccess: false,
                  );
                }
              } catch (e) {
                if (!mounted) return;
                showCustomSnackBar(
                  context,
                  'Terjadi kesalahan',
                  isSuccess: false,
                );
              }
              setState(() => _isLoading = false);
            },
          ),
    );
  }

  Future<void> _handleUpdate() async {
    showDialog(
      context: context,
      builder:
          (context) => CustomAlertDialog(
            title: 'Konfirmasi',
            content: 'Apakah Anda yakin ingin edit catatan?',
            cancelText: 'Belum',
            confirmText: 'Ya',
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: () async {
              Navigator.of(context).pop();
              setState(() => _isLoading = true);
              final userId =
                  int.tryParse(widget.userId.toString()) ?? widget.userId;
              final brmId = _dataBrm![0]['id'];
              Map<String, dynamic> brmNotes = {
                "id": idNotes,
                "user_id": userId,
                "brm_id": brmId,
                "notes": _noteController.text.toString().trim(),
              };

              try {
                final res2 = await ApiService.putBrmNotes(context, brmNotes);
                print('VANILLA res2: $res2');

                if (res2['success'] == true) {
                  await initAll(); // reload data
                } else {
                  if (!mounted) return;
                  showCustomSnackBar(
                    context,
                    'Gagal memperbarui data. Silakan coba lagi.',
                    isSuccess: false,
                  );
                }
              } catch (e) {
                if (!mounted) return;
                showCustomSnackBar(
                  context,
                  'Terjadi kesalahan',
                  isSuccess: false,
                );
              }
              setState(() {
                _isLoading = false;
                isEdit = false;
              });
            },
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = _dataUser['role'] ?? '-';
    Widget buildBibleContent() {
      // final List<dynamic> books = [];
      // // final books = _dataBible?['book'] != null ? [_dataBible?['book']] : [];
      // // final books = <Map<String, dynamic>>[];
      // if (_dataBible?['book'] is List) {
      //   // book lebih dari satu
      //   print('Jumlah book: ${_dataBible?['book'].length}');
      //   final books = _dataBible?['book'] as List<dynamic>? ?? [];
      // } else if (_dataBible?['book'] != null) {
      //   // book hanya satu
      //   print('Book satu: ${_dataBible?['book'].length}');
      //   final books = _dataBible?['book'] != null ? [_dataBible?['book']] : [];
      // }

      // final books =
      //     _dataBible?['book'] as List<dynamic>? ??
      //     (_dataBible?['book'] != null ? [_dataBible?['book']] : []);

      return ListView(
        children: [
          // ...books.map<Widget>((book) {
          ..._books.map<Widget>((book) {
            final bookName = book['@attributes']?['name'] ?? '';
            final bookTitle = book['title'] ?? '';
            final chapter = book['chapter'];
            final chapterNum = chapter?['chap'] ?? '';
            final verses =
                chapter?['verses']?['verse'] as List<dynamic>? ??
                (chapter?['verses']?['verse'] != null
                    ? [chapter?['verses']?['verse']]
                    : []);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$bookName $chapterNum',
                  style: TextStyle(
                    fontSize: fontSize_judul,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),
                ...verses.map<Widget>((verse) {
                  final number = verse['number'] ?? '';
                  final verseTitle = verse['title'];
                  final text = verse['text'] ?? '';
                  final isSelected =
                      _selectedVerseNumber?.toString() == number.toString() &&
                      _selectedBookName == bookName &&
                      _selectedChapterNum == chapterNum;

                  List<Widget> children = [];

                  // Jika ayat pertama dan ada title, tampilkan title di luar container highlight
                  if (number == "1" && verseTitle != null) {
                    children.add(
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 32),
                        child: Text(
                          '$verseTitle.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontSize: fontSize_subjudul,
                          ),
                        ),
                      ),
                    );
                  }

                  children.add(
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedVerseNumber ==
                                  int.tryParse(number.toString()) &&
                              _selectedBookName == bookName &&
                              _selectedChapterNum == chapterNum) {
                            _selectedVerseNumber = null;
                            _selectedBookName = null;
                            _selectedChapterNum = null;
                          } else {
                            _selectedVerseNumber = int.tryParse(
                              number.toString(),
                            );
                            _selectedBookName = bookName;
                            _selectedChapterNum = chapterNum;
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.secondary.withAlpha(50)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: '$number. ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: fontSize_ayat,
                                ),
                              ),
                              TextSpan(
                                text: text,
                                style: TextStyle(fontSize: fontSize_isi_ayat),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  );
                }).toList(),
                const SizedBox(height: 8),
                Text(
                  'Sumber: Alkitab SABDA (alkitab.sabda.org)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
          if (countRead == 0 &&
              !isEdit &&
              (role.toLowerCase().contains('peserta') ||
                  role.toLowerCase().contains('pembina')))
            Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomTextField(
                      controller: _noteController,
                      label:
                          'Bagian berkat yang kamu dapatkan dari bacaan hari ini',
                      labelFontSize: 12,
                      hintText: '....',
                      maxLines: 4,
                      labelTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: AppColors.grey4,
                      ),
                      textColor: Colors.black,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.keyboard_hide,
                          color: Colors.black,
                        ),
                        onPressed: () => FocusScope.of(context).unfocus(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _handleSubmit,
                      label: const Text(
                        'Selesai Membaca',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (countRead > 0 && isEdit)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bagian berkat yang kamu dapatkan dari bacaan hari ini:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: AppColors.grey4,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notes.isNotEmpty ? notes : '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          setState(() {
                            isEdit = true;
                            _noteController.text = notes;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Set background color using a Container
          Container(
            decoration: const BoxDecoration(
              color:
                  AppColors.primary, // Set your desired background color here
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => initAll(forceRefresh: true),
                color: AppColors.brown1,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        iconTheme: const IconThemeData(color: Colors.white),
                        title: const Text(
                          'Bacaan Hari Ini',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        leading: IconButton(
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, 'reload'),
                        ),
                        automaticallyImplyLeading: true,
                        actions: [
                          _isLoading
                              ? SizedBox(
                                width: 120,
                                height: 36,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                    ),
                                  ),
                                ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  _dataBrm != null && _dataBrm!.isNotEmpty
                                      ? DateFormatter.ubahTanggal(
                                        _dataBrm![0]['tanggal'],
                                      )
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        ],
                      ),
                      _isLoading
                          ? Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.4,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                          : _dataBible == null
                          ? Center(
                            child: CustomNotFound(
                              text: "Gagal memuat data bacaan hari ini :(",
                              textColor: Colors.white,
                              imagePath: 'assets/images/data_not_found.png',
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 55,
                                        child: Card(
                                          color: AppColors.secondary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 2.0,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.remove,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (fontSize_judul > 18) {
                                                        fontSize_judul -= 2;
                                                        fontSize_subjudul -= 1;
                                                        fontSize_ayat -= 1;
                                                        fontSize_isi_ayat -= 1;
                                                      } else {
                                                        showCustomSnackBar(
                                                          context,
                                                          "Font size terlalu kecil",
                                                        );
                                                      }
                                                    });
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (fontSize_judul < 42) {
                                                        fontSize_judul += 2;
                                                        fontSize_subjudul += 1;
                                                        fontSize_ayat += 1;
                                                        fontSize_isi_ayat += 1;
                                                      } else {
                                                        showCustomSnackBar(
                                                          context,
                                                          "Font size mencapai batas maksimal",
                                                        );
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.people,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${_countUserDoneRead ?? '-'}${_totalUser != null ? '/$_totalUser' : ''}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 24,
                                  left: 24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height:
                                          countRead == 0
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.6
                                              : (countRead > 0 && !isEdit)
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.45
                                              : MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.24,
                                      child: buildBibleContent(),
                                    ),
                                    const SizedBox(height: 16),
                                    if (countRead > 0 && !isEdit)
                                      Column(
                                        children: [
                                          Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            color: Colors.white,
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Bagian berkat yang kamu dapatkan dari bacaan hari ini:',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color:
                                                              AppColors.grey4,
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        notes.isNotEmpty
                                                            ? notes
                                                            : '',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 8,
                                                  right: 8,
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            24,
                                                          ),
                                                      onTap: () {
                                                        setState(() {
                                                          isEdit = true;
                                                          _noteController.text =
                                                              notes;
                                                          initAll(); // reload data
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                        child: const Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                          size: 22,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (countRead > 0 && isEdit)
                                      Column(
                                        children: [
                                          Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            color: Colors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: CustomTextField(
                                                controller: _noteController,
                                                label:
                                                    'Bagian berkat yang kamu dapatkan dari bacaan hari ini',
                                                labelFontSize: 12,
                                                hintText: '....',
                                                maxLines: 4,
                                                labelTextStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle: FontStyle.italic,
                                                  color: AppColors.grey4,
                                                ),
                                                textColor: Colors.black,
                                                fillColor: Colors.white,
                                                suffixIcon: IconButton(
                                                  icon: const Icon(
                                                    Icons.keyboard_hide,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          FocusScope.of(
                                                            context,
                                                          ).unfocus(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: SizedBox(
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.4,
                                              height: 50,
                                              child: ElevatedButton.icon(
                                                onPressed: _handleUpdate,
                                                label: const Text(
                                                  'Edit Catatan',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.secondary,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          24,
                                                        ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CustomCard(
                                  text: 'Lihat catatan dari orang lain',
                                  icon: Icons.sticky_note_2_rounded,
                                  iconBackgroundColor: AppColors.brown1,
                                  showCheckIcon: false,
                                  onTap: () {
                                    // if (day <= _hariKe) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => CatatanHarianScreen(
                                              role: role,
                                              id: widget.userId,
                                              initialDate: DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                widget.date.day,
                                              ),
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          _selectedVerseNumber != null
              ? FloatingActionButton(
                backgroundColor: AppColors.secondary,
                onPressed: () {
                  // Cari ayat yang sedang dipilih beserta info perikop
                  String perikop = '';
                  String ayatText = '';
                  for (final book in _books) {
                    final bookName = book['@attributes']?['name'] ?? '';
                    final chapter = book['chapter'];
                    final chapterNum = chapter?['chap'] ?? '';
                    final verses =
                        chapter?['verses']?['verse'] as List<dynamic>? ??
                        (chapter?['verses']?['verse'] != null
                            ? [chapter?['verses']?['verse']]
                            : []);
                    for (final verse in verses) {
                      final number = verse['number'] ?? '';
                      if ((_selectedVerseNumber?.toString() ?? '') ==
                              number.toString() &&
                          _selectedBookName == bookName &&
                          _selectedChapterNum == chapterNum) {
                        perikop = '$bookName $chapterNum:$number';
                        ayatText = verse['text'] ?? '';
                        break;
                      }
                    }
                    if (perikop.isNotEmpty) break;
                  }
                  print('FAB PRESSED - PERIKOP: $perikop');
                  print('FAB PRESSED - AYAT: $ayatText');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BibleShareVerseScreen(
                            perikop: perikop,
                            ayatText: ayatText,
                          ),
                    ),
                  );
                },
                child: const Icon(Icons.book, color: Colors.white),
              )
              : null,
    );
  }
}
