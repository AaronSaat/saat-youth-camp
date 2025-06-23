import 'package:flutter/material.dart';
import 'package:syc/utils/app_colors.dart';

import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_text_field.dart';
import 'bible_reading_list_screen.dart';
import 'bible_reading_success_screen.dart';

class BibleReadingMoreScreen extends StatefulWidget {
  final String userId;
  const BibleReadingMoreScreen({super.key, required this.userId});

  @override
  State<BibleReadingMoreScreen> createState() => _BibleReadingMoreScreenState();
}

class _BibleReadingMoreScreenState extends State<BibleReadingMoreScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>>? _dataBrm;
  Map<String, dynamic>? _dataBible;
  List<dynamic> _books = [];
  int countRead = 0;
  double fontSize_judul = 32;
  double fontSize_subjudul = 18;
  double fontSize_ayat = 10;
  double fontSize_isi_ayat = 14;
  final TextEditingController _noteController = TextEditingController();
  String _note = '';

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    setState(() => _isLoading = true);
    try {
      await loadBrm();
      await loadReportBrmByPesertaByDay();
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> loadBrm() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getBrmToday(context);
      if (!mounted) return;
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
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> loadReportBrmByPesertaByDay() async {
    try {
      final count = await ApiService.getBrmReportByPesertaByDay(
        context,
        widget.userId,
        DateTime.now().toIso8601String().substring(0, 10),
      );
      if (!mounted) return;
      setState(() {
        countRead = count;
        print('Count Read: $countRead');
      });
    } catch (e) {}
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
                await ApiService.postBrmDoneRead(context, brmDoneRead);
                await ApiService.postBrmNotes(context, brmNotes);
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => BibleReadingSuccessScreen(),
                    ),
                  );
                }
              } catch (e) {
                setState(() {
                  if (!mounted) return;
                  showCustomSnackBar(
                    context,
                    'Terjadi kesalahan',
                    isSuccess: false,
                  );
                });
              }
              setState(() => _isLoading = false);
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
    Widget buildBibleContent() {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_dataBible == null) {
        return const Center(child: Text('Tidak ada data Alkitab.'));
      }

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
          const SizedBox(height: 16),
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
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.5,
                        ),
                        children: [
                          if (number == "1" && verseTitle != null) ...[
                            TextSpan(
                              text: '$verseTitle. \n\n',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontSize: fontSize_subjudul,
                              ),
                            ),

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
                          ] else ...[
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
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
          if (countRead == 0)
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
                      label: 'Catatan',
                      hintText: 'Tambahkan catatan (opsional)',
                      maxLines: 4,
                      labelColor: Colors.black,
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
            )
          else
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Anda sudah membaca dan mengisi catatan hari ini.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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
                      automaticallyImplyLeading: true,
                      actions: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => BibleReadingListScreen(
                                      userId: widget.userId,
                                    ),
                              ),
                            ).then((result) {
                              if (result == 'reload') {
                                initAll(); // reload dashboard
                              }
                            });
                          },
                          child: Container(
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
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //             Positioned.fill(
                        //   child: Image.asset(
                        //     'assets/images/background_read_more.jpg',
                        //     width: MediaQuery.of(context).size.width,
                        //     height: MediaQuery.of(context).size.height,
                        //     fit: BoxFit.fill,
                        //   ),
                        // ),
                        // Font size control icons in a rounded card above the content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Card(
                              color: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
                                        size: 30,
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
                                        size: 30,
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
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 24,
                            left: 24,
                            bottom: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: buildBibleContent(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
