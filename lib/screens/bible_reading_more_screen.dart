import 'package:flutter/material.dart';
import 'package:syc/utils/app_colors.dart';

import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/custom_snackbar.dart';
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

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    setState(() => _isLoading = true);
    try {
      await loadBrm();
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

              try {
                await ApiService.postBrmDoneRead(context, brmDoneRead);
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => BibleReadingSuccessScreen(),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  showCustomSnackBar(
                    context,
                    'Terjadi kesalahan',
                    isSuccess: false,
                  );
                }
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
                  style: const TextStyle(
                    fontSize: 36,
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),

                            TextSpan(
                              text: '$number. ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            TextSpan(
                              text: text,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ] else ...[
                            TextSpan(
                              text: '$number. ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            TextSpan(
                              text: text,
                              style: const TextStyle(fontSize: 14),
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
        ],
      );
    }

    return Scaffold(
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
                      Container(
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
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.66,
                              child: buildBibleContent(),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 40,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _handleSubmit,
                                  label: const Text(
                                    'Selesai Membaca',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brown1,
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
