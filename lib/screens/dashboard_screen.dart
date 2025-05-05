import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'komitmen_screen.dart';
import 'evaluasi_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _email = '';
  ScrollController _komitmenController = ScrollController();
  ScrollController _evaluasiController = ScrollController();
  int _currentKomitmenPage = 0;
  int _currentEvaluasiPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUsername();

    _komitmenController.addListener(() {
      double itemWidth = 180;
      setState(() {
        _currentKomitmenPage = (_komitmenController.offset / itemWidth).round();
      });
    });
    _evaluasiController.addListener(() {
      double itemWidth = 110;
      setState(() {
        _currentEvaluasiPage = (_evaluasiController.offset / itemWidth).round();
      });
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? 'No Email';
    setState(() {
      _email = email;
    });
  }

  void _navigateToKomitmen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const KomitmenScreen()));
  }

  void _navigateToEvaluasi(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const EvaluasiScreen()));
  }

  @override
  void dispose() {
    _komitmenController.dispose();
    _evaluasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hello, $_email')),
      body: SingleChildScrollView(
        // Tambahkan ini
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Komitmen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          controller: _komitmenController,
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              child: _komitmenCard(context, 'Komitmen ${index + 1}'),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Manual Indicator
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentKomitmenPage == index ? 12 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentKomitmenPage == index ? Colors.blue : Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Evaluasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),

                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          controller: _evaluasiController,
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              child: _evaluasiCard(context, 'Evaluasi ${index + 1}'),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Manual Indicator
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentEvaluasiPage == index ? 12 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentEvaluasiPage == index ? Colors.blue : Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _komitmenCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () => _navigateToKomitmen(context),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _evaluasiCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () => _navigateToEvaluasi(context),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
