import 'dart:convert' show jsonEncode;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:syc/screens/scan_qr_screen.dart' show ScanQrScreen;
import 'package:syc/utils/global_variables.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/permission_helper.dart';
import '../widgets/custom_snackbar.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  File? _imageFile;
  Map<String, String> _dataUser = {};
  bool _isLoading = true;
  String avatar = '';

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await loadUserData();
      await loadAvatarById();
    } catch (e) {
      // handle error jika perlu
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      'nama',
      'email',
      'role',
      'token',
      'gereja_id',
      'gereja_nama',
      'kelompok_id',
      'kelompok_nama',
      'kamar',
      'status_datang',
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

  Future<void> _pickImage() async {
    bool hasPermission = await PermissionHelper.requestPhotosPermission(
      context,
    );
    if (hasPermission) {
      //[DEVELOPER NOTE] This condition is inverted, atau ga usah pakai
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.length();
        print('File size in bytes: $bytes');
        const maxSizeInBytes = 2 * 1024 * 1024; // 2MB

        if (bytes > maxSizeInBytes) {
          showCustomSnackBar(
            context,
            'Ukuran gambar maksimal 2MB',
            isSuccess: false,
          );
          return;
        }

        setState(() {
          _imageFile = file;
        });
      } else {
        if (!mounted) return;
        showCustomSnackBar(
          context,
          'Tidak ada gambar yang dipilih',
          isSuccess: false,
        );
      }
    } else {
      if (!mounted) return;
      showCustomSnackBar(
        context,
        'Izin akses galeri ditolak',
        isSuccess: false,
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      if (!mounted) return;
      showCustomSnackBar(
        context,
        'Pilih gambar terlebih dahulu',
        isSuccess: false,
      );
      return;
    }

    try {
      final result = await ApiService.postAvatar(
        context,
        _imageFile!.path,
        body: {'user_id': _dataUser['id'] ?? ''},
      );
      if (!mounted) return;
      showCustomSnackBar(context, 'Upload gambar berhasil', isSuccess: true);
      //refresh page
      await _initAll();
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Upload gambar gagal', isSuccess: false);
    }
  }

  Future<void> loadAvatarById() async {
    final userId = _dataUser['id'].toString() ?? '';
    try {
      final _avatar = await ApiService.getAvatarById(context, userId);
      if (!mounted) return;
      setState(() {
        avatar = _avatar;
        print('Avatar URL: $avatar');
        _isLoading = false;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({
      'id': _dataUser['id'],
      'nama': _dataUser['nama'],
      'role': _dataUser['role'],
      'email': _dataUser['email'],
      'kelompok_nama': _dataUser['kelompok_nama'],
    });
    final role = _dataUser['role'] ?? '';
    final namakelompok = _dataUser['kelompok_nama'] ?? 'Tidak ada kelompok';
    final status_datang = _dataUser['status_datang'] ?? '0';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            Navigator.canPop(context)
                ? BackButton(color: AppColors.primary)
                : null,
      ),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_anggota.jpg',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _initAll(),
              color: AppColors.brown1,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _isLoading
                          ? buildShimmerEditProfile()
                          : Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4), // Outline thickness
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary, // Outline color
                                    width: 2, // Outline thickness
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 100,
                                  backgroundImage:
                                      _imageFile != null
                                          ? FileImage(_imageFile!)
                                          : (avatar.isNotEmpty &&
                                                  !avatar
                                                      .toLowerCase()
                                                      .contains('null')
                                              ? NetworkImage(
                                                '${GlobalVariables.serverUrl}$avatar',
                                              )
                                              : AssetImage(() {
                                                    switch (role) {
                                                      case 'Pembina':
                                                        return 'assets/mockups/pembina.jpg';
                                                      case 'Peserta':
                                                        return 'assets/mockups/peserta.jpg';
                                                      case 'Pembimbing Kelompok':
                                                        return 'assets/mockups/pembimbing.jpg';
                                                      case 'Panitia':
                                                        return 'assets/mockups/panitia.jpg';
                                                      default:
                                                        return 'assets/mockups/unknown.jpg';
                                                    }
                                                  }())
                                                  as ImageProvider),
                                  backgroundColor: Colors.grey[200],
                                ),
                              ),
                              SizedBox(height: 16),
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.brown1,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Select Image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 16),
                              GestureDetector(
                                onTap: _uploadImage,
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.brown1,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Upload Image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(height: 16),
                              // GestureDetector(
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder:
                              //             (_) => ScanQrScreen(
                              //               namakelompok: namakelompok,
                              //             ),
                              //       ),
                              //     );
                              //   },
                              //   child: Container(
                              //     width: double.infinity,
                              //     height: 50,
                              //     decoration: BoxDecoration(
                              //       color: AppColors.brown1,
                              //       borderRadius: BorderRadius.circular(32),
                              //     ),
                              //     alignment: Alignment.center,
                              //     child: Text(
                              //       'Scan QR Code',
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 14,
                              //         fontWeight: FontWeight.w500,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              SizedBox(height: 24),
                              // QR Code User
                              status_datang.contains('0')
                                  ? Column(
                                    children: [
                                      Text(
                                        'QR Code Peserta',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                        child: QrImageView(
                                          data: qrData,
                                          size: 180.0,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tunjukkan QR ini ke pembimbing kelompokmu\nuntuk check-in',
                                        style: TextStyle(
                                          color: AppColors.brown1,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  )
                                  : Text(
                                    '✅  Terima kasih sudah melakukan registrasi ulang',
                                    style: TextStyle(
                                      color: AppColors.brown1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
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
    );
  }
}

Widget buildShimmerEditProfile() {
  return Column(
    children: [
      // Shimmer for avatar
      Container(
        padding: EdgeInsets.all(4),
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
      ),
      SizedBox(height: 16),
      // Shimmer for select image button
      Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      SizedBox(height: 16),
      // Shimmer for upload image button
      Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    ],
  );
}
