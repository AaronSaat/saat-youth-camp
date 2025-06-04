import 'package:flutter/material.dart';
import 'package:syc/utils/app_colors.dart';

import '../services/api_service.dart';

class ReadMoreScreen extends StatefulWidget {
  final String userId;
  const ReadMoreScreen({super.key, required this.userId});

  @override
  State<ReadMoreScreen> createState() => _ReadMoreScreenState();
}

class _ReadMoreScreenState extends State<ReadMoreScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>>? _dataBrm;
  Map<String, dynamic>? _dataBible;

  @override
  void initState() {
    super.initState();
    loadBrm();
  }

  Future<void> loadBrm() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getBrmToday(context);

      setState(() {
        // Pastikan data-brm adalah List<Map<String, dynamic>>
        if (response['data-brm'] is List) {
          _dataBrm = List<Map<String, dynamic>>.from(response['data-brm']);
        } else if (response['data-brm'] is Map<String, dynamic>) {
          _dataBrm = [response['data-brm'] as Map<String, dynamic>];
        } else {
          _dataBrm = null;
        }

        // data-bible harus Map<String, dynamic>
        if (response['data-bible'] is Map<String, dynamic>) {
          _dataBible = response['data-bible'] as Map<String, dynamic>;
        } else {
          _dataBible = null;
        }

        _isLoading = false;
        print('Data BRM: $_dataBrm');
        print('Data Bible: $_dataBible');
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    final userId = int.tryParse(widget.userId.toString()) ?? widget.userId;
    // Ambil id dari data BRM pertama
    final brmId = _dataBrm![0]['id'];
    Map<String, dynamic> brmDoneRead = {"brm_id": brmId, "user_id": userId};

    try {
      await ApiService.postBrmDoneRead(context, brmDoneRead);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Evaluasi berhasil dikirim!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Evaluasi gagal dikirim!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    setState(() => _isLoading = false);
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

      final title = _dataBible?['title'] ?? '';
      final books = _dataBible?['book'] as List<dynamic>? ?? (_dataBible?['book'] != null ? [_dataBible?['book']] : []);

      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ...books.map<Widget>((book) {
            final bookName = book['@attributes']?['name'] ?? '';
            final bookTitle = book['title'] ?? '';
            final chapter = book['chapter'];
            final chapterNum = chapter?['chap'] ?? '';
            final verses =
                chapter?['verses']?['verse'] as List<dynamic>? ??
                (chapter?['verses']?['verse'] != null ? [chapter?['verses']?['verse']] : []);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$bookName $bookTitle',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                ...verses.map<Widget>((verse) {
                  final number = verse['number'] ?? '';
                  final verseTitle = verse['title'];
                  final text = verse['text'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                        children: [
                          TextSpan(
                            text: '$number. ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          if (verseTitle != null)
                            TextSpan(
                              text: '$verseTitle. ',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          TextSpan(text: text),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/bible_reading.jpg', fit: BoxFit.cover),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Bacaan Alkitab',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400, // adjust as needed
                    child: buildBibleContent(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleSubmit,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Selesai Membaca',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brown1,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 5,
                        ),
                      ),
                    ),
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
