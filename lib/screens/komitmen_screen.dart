import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
import 'review_komitmen_screen.dart';

class KomitmenScreen extends StatefulWidget {
  const KomitmenScreen({super.key});

  @override
  State<KomitmenScreen> createState() => _KomitmenScreenState();
}

class _KomitmenScreenState extends State<KomitmenScreen> {
  String? answer1;
  String? answer2;
  String? answer3;
  final TextEditingController _textController = TextEditingController();
  double _sliderValue = 3;
  bool isLoading = false;
  final List<String> tingkatKomitmenLabels = [
    'Sangat Tidak Setuju',
    'Tidak Setuju',
    'Cukup Tidak Setuju',
    'Cukup Setuju',
    'Setuju',
    'Sangat Setuju',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      answer1 = prefs.getString('komitmen_answer1');
      answer2 = prefs.getString('komitmen_answer2');
      answer3 = prefs.getString('komitmen_answer3');
      _textController.text = prefs.getString('komitmen_komentar') ?? '';
      _sliderValue = prefs.getDouble('komitmen_slider') ?? 3;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('komitmen_answer1', answer1 ?? '');
    await prefs.setString('komitmen_answer2', answer2 ?? '');
    await prefs.setString('komitmen_answer3', answer3 ?? '');
    await prefs.setString('komitmen_komentar', _textController.text);
    await prefs.setDouble('komitmen_slider', _sliderValue);
  }

  Future<void> _handleSubmit() async {
    setState(() => isLoading = true);
    await _saveProgress();
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewKomitmenScreen()));
  }

  Widget _buildYesNoQuestion({
    required String title,
    required String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Ya'),
                value: 'Ya',
                groupValue: selectedValue,
                onChanged: onChanged,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Tidak'),
                value: 'Tidak',
                groupValue: selectedValue,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChecklistQuestion({
    required String title,
    required String? selectedValue,
    required Function(String) onChanged,
  }) {
    bool isChecked = selectedValue == 'Ya';

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: isChecked,
      onChanged: (bool? value) {
        onChanged(value == true ? 'Ya' : 'Tidak');
      },
      controlAffinity: ListTileControlAffinity.trailing, // checkbox di kanan
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        // title: const Text(
        //   'SYC 2024 APP',
        //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        // ),
        // backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Checklist
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Checklist Komitmen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildChecklistQuestion(
                      title: 'Percaya kepada Tuhan Yesus Kristus sebagai Juruselamat saya pribadi.',
                      selectedValue: answer1,
                      onChanged: (val) => setState(() => answer1 = val),
                    ),
                    _buildChecklistQuestion(
                      title: 'Bertobat dari dosa-dosa yang membelenggu.',
                      selectedValue: answer2,
                      onChanged: (val) => setState(() => answer2 = val),
                    ),
                    _buildChecklistQuestion(
                      title: 'Belajar untuk sungguh-sungguh mencintai Firman Tuhan.',
                      selectedValue: answer3,
                      onChanged: (val) => setState(() => answer3 = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Card Slider
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seberapa besar komitmen saya untuk hidup bagi Kristus?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _sliderValue,
                      min: 1,
                      max: 6,
                      divisions: 5,
                      label: _sliderValue.toInt().toString(),
                      onChanged: (value) => setState(() => _sliderValue = value),
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.primary.withAlpha(40),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Sangat Tidak Setuju', style: TextStyle(fontSize: 14)),
                        Text('Sangat Setuju', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Center(
                      child: Text(
                        '${tingkatKomitmenLabels[_sliderValue.toInt() - 1]}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Card Komentar
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tuliskan komitmen lainnya',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan komitmen lainnya terkait dengan pesan dari KKR malam ini...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Button Row
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _saveProgress();
                      if (context.mounted) Navigator.pop(context); // kembali ke halaman sebelumnya
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      elevation: 5,
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16), // Space between buttons
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                    icon:
                        isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                            : const Icon(Icons.arrow_forward),
                    label:
                        isLoading
                            ? const Text('')
                            : const Text('Review Jawaban', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
