import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class TestScreen2 extends StatefulWidget {
  const TestScreen2({Key? key}) : super(key: key);

  @override
  State<TestScreen2> createState() => _TestScreen2State();
}

class _TestScreen2State extends State<TestScreen2> {
  final List<String> items = List.generate(3, (index) => 'Item ${index + 1}');

  @override
  @override
  Widget build(BuildContext context) {
    double cardHeight = MediaQuery.of(context).size.height * 0.22;
    return Scaffold(
      appBar: AppBar(title: const Text('Card List Abu-Abu')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            color: Colors.grey[200],
            margin: const EdgeInsets.all(16),
            child: SizedBox(
              height: cardHeight,
              child: Row(
                children: [
                  // Kolom kiri: Card putih
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        Container(
                          height: cardHeight * 0.8,
                          width: cardHeight * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16),
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -5,
                          bottom: -5,
                          child: Card(
                            color: Colors.yellow[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                              ),
                            ),
                            elevation: 0,
                            child: SizedBox(
                              width: 48,
                              height: 36,
                              // Ganti icon di bawah sesuai kebutuhan:
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                              ), // Icon default (bintang)
                              // child: Icon(
                              //   Icons.person,
                              //   color: Colors.white,
                              // ), // Icon anggota (orang)
                              // child: Icon(Icons.group, color: Colors.white), // Icon grup
                              // child: Icon(Icons.verified_user, color: Colors.white), // Icon user terverifikasi
                              // child: Icon(Icons.account_circle, color: Colors.white), // Icon akun
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Kolom kanan: Text nama
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: cardHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top center: 2 texts
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items[index],
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                'Subtitle',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          // Bottom center: 2 buttons in a row
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 210, // Ganti sesuai kebutuhan
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brown1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'Button 1',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              SizedBox(
                                width: 210, // Ganti sesuai kebutuhan
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brown1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'Button 2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
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
            ),
          );
        },
      ),
    );
  }
}
