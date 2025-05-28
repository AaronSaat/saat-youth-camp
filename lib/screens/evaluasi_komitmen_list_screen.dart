import 'package:flutter/material.dart';

import '../services/api_service.dart';

class EvaluasiKomitmenListScreen extends StatefulWidget {
  final String type;
  final String userId;

  const EvaluasiKomitmenListScreen({
    Key? key,
    required this.type,
    required this.userId,
  }) : super(key: key);

  @override
  _EvaluasiKomitmenListScreenState createState() =>
      _EvaluasiKomitmenListScreenState();
}

class _EvaluasiKomitmenListScreenState
    extends State<EvaluasiKomitmenListScreen> {
  List<dynamic> _acaraList = [];
  List<dynamic> _komitmenList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'Evaluasi') {
      loadAcara();
    } else if (widget.type == 'Komitmen') {
      loadKomitmen();
    } else {
      _isLoading = false;
    }
  }

  void loadAcara() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final acaraList = await ApiService.getAcara(context);
      setState(() {
        _acaraList = acaraList ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat list acara: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void loadKomitmen() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final komitmenList = await ApiService.getKomitmen(context);
      setState(() {
        _komitmenList = komitmenList ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat list komitmen: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  // void loadEvaluasi(userId, acaraId) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     final evaluasiList = await ApiService.getEvaluasiByPesertaByDay(context, userId, acaraId);
  //     setState(() {
  //       _evaluasiList = evaluasiList ?? [];
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     print('❌ Gagal memuat evaluasi oleh user $userId pada hari $acaraId: $e');
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
  // void loadKomitmen(userId, acaraId) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     final komitmenList = await ApiService.getKomitmenByPesertaByDay(context, userId, acaraId);
  //     setState(() {
  //       _komitmenList = komitmenList ?? [];
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     print('❌ Gagal memuat komitmen oleh user $userId pada hari $acaraId: $e');
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text(widget.type, style: const TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_member_list.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ListView.builder(
                        itemCount:
                            widget.type == 'Evaluasi'
                                ? _acaraList.length
                                : _komitmenList.length,
                        itemBuilder: (context, index) {
                          final items =
                              widget.type == 'Evaluasi'
                                  ? _acaraList
                                  : _komitmenList;

                          String item;
                          if (widget.type == 'Evaluasi') {
                            final acara = items[index];
                            item =
                                '${acara['acara_nama'] ?? '-'} (Hari ${acara['hari'] ?? '-'})';
                          } else {
                            final komitmen = items[index];
                            item = 'Komitmen Hari ${komitmen['hari'] ?? '-'}';
                          }
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_right_sharp,
                                color: Colors.white,
                                size: 48,
                              ),
                              onTap: () {},
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
