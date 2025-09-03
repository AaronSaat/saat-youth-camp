import 'dart:convert' show jsonEncode, utf8;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart'
    show
        AndroidUiSettings,
        CropAspectRatioPreset,
        CropStyle,
        IOSUiSettings,
        ImageCropper;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:syc/screens/scan_qr_screen.dart' show ScanQrScreen;
import 'package:syc/utils/global_variables.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';

import '../services/api_service.dart';
import '../utils/app_colors.dart';
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
      await checkStatusDatang();
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
      'secret',
      'status_datang',
      'avatar',
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
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Crop image setelah pilih
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            cropStyle: CropStyle.circle,
            toolbarColor: AppColors.brown1,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            cropStyle: CropStyle.circle,
            doneButtonTitle: 'Upload',
            cancelButtonTitle: 'Cancel',
            aspectRatioLockDimensionSwapEnabled: false,
            aspectRatioPickerButtonHidden: true,
            resetButtonHidden: true,
          ),
        ],
      );
      if (croppedFile != null) {
        final file = File(croppedFile.path);
        final bytes = await file.length();
        print('File size in bytes: $bytes');
        const maxSizeInBytes = 4 * 1024 * 1024; // 4MB

        if (bytes > maxSizeInBytes) {
          showCustomSnackBar(
            context,
            'Ukuran gambar maksimal 4MB',
            isSuccess: false,
          );
          return;
        }

        setState(() {
          _isLoading = true;
          _imageFile = file;
        });

        // Langsung upload ke API setelah crop dan validasi
        try {
          await ApiService.postAvatar(
            context,
            file.path,
            body: {'user_id': _dataUser['id'] ?? ''},
          );
          if (!mounted) return;
          showCustomSnackBar(
            context,
            'Upload gambar berhasil',
            isSuccess: true,
          );
          //refresh page
          await _initAll();
          // Force rebuild by navigating to this screen again
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => ProfileEditScreen()),
          // );
        } catch (e) {
          if (!mounted) return;
          showCustomSnackBar(context, 'Upload gambar gagal', isSuccess: false);
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        showCustomSnackBar(context, 'Crop gambar dibatalkan', isSuccess: false);
      }
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showCustomSnackBar(
        context,
        'Tidak ada gambar yang dipilih',
        isSuccess: false,
      );
    }
  }

  Future<void> loadAvatarById() async {
    print('Memuat avatar dari lokal...');
    final prefs = await SharedPreferences.getInstance();
    final userId = _dataUser['id'].toString();
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/avatar_${userId}.jpg';
    final file = File(filePath);
    if (file.existsSync()) {
      if (!mounted) return;
      setState(() {
        avatar = filePath;
        print('Avatar file path (local): $avatar');
        _isLoading = false;
      });
      await prefs.setString('avatar_path', filePath);
    } else {
      if (!mounted) return;
      setState(() {
        avatar = '';
        print('Avatar fallback ke mockup');
        _isLoading = false;
      });
      await prefs.remove('avatar_path');
    }
  }

  Future<void> checkStatusDatang() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await ApiService.getStatusDatang(
        context,
        _dataUser['secret'] ?? '',
        _dataUser['email'] ?? '',
      );
      if (!mounted) return;
      final statusDatangApi = res['data']?['status_datang']?.toString() ?? '';
      final prefs = await SharedPreferences.getInstance();
      final statusDatangLocal = prefs.getString('status_datang') ?? '0';
      if (statusDatangApi.isNotEmpty && statusDatangApi != statusDatangLocal) {
        await prefs.setString('status_datang', statusDatangApi);
        print('Status datang diperbarui: ${_dataUser['status_datang']}');
        setState(() {
          _dataUser['status_datang'] = statusDatangApi;
        });
      } else {
        setState(() {
          _dataUser['status_datang'] = statusDatangLocal;
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat status datang: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String encryptSecret(String secret) {
    final key = encrypt.Key.fromUtf8(
      'Ab3kLm9PqRstUv2XyZ01MnOpQr56StUv',
    ); // 16/24/32 karakter
    final iv = encrypt.IV.fromUtf8('Ab3kLm9PqRstUv2X'); // 16 karakter (benar)
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final encrypted = encrypter.encrypt(secret, iv: iv);
    return encrypted.base64;
  }

  @override
  Widget build(BuildContext context) {
    final role = _dataUser['role'] ?? '';
    final secret = _dataUser['secret'] ?? 'Null';
    print('Secret: $secret');
    final encryptedSecret = encryptSecret(secret).replaceAll(' ', '+');
    print('Fixed Secret: $encryptedSecret');
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
        leading: BackButton(
          color: AppColors.primary,
          onPressed: () => Navigator.pop(context, 'reload'),
        ),
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
                  child:
                      _isLoading
                          ? buildShimmerEditProfile()
                          : Column(
                            children: [
                              _isLoading
                                  ? Container(
                                    padding: EdgeInsets.all(4),
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                  : (avatar.isNotEmpty &&
                                      File(avatar).existsSync())
                                  ? Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 100,
                                      backgroundImage: FileImage(File(avatar)),
                                      backgroundColor: Colors.grey[200],
                                    ),
                                  )
                                  : Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 100,
                                      backgroundImage:
                                          (() {
                                            switch (role) {
                                              case 'Pembina':
                                                return AssetImage(
                                                  'assets/mockups/pembina.jpg',
                                                );
                                              case 'Peserta':
                                                return AssetImage(
                                                  'assets/mockups/peserta.jpg',
                                                );
                                              case 'Pembimbing Kelompok':
                                                return AssetImage(
                                                  'assets/mockups/pembimbing.jpg',
                                                );
                                              case 'Panitia':
                                                return AssetImage(
                                                  'assets/mockups/panitia.jpg',
                                                );
                                              default:
                                                return AssetImage(
                                                  'assets/mockups/unknown.jpg',
                                                );
                                            }
                                          })(),
                                      backgroundColor: Colors.grey[200],
                                    ),
                                  ),
                              SizedBox(height: 16),
                              Text(
                                _dataUser['nama'] ?? '',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _dataUser['kelompok_nama']?.isNotEmpty == true
                                    ? _dataUser['kelompok_nama']!
                                    : 'Tidak ada kelompok',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primary,
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
                                    'Upload Image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              // QR Code User
                              (role.toLowerCase().contains('peserta') ||
                                      role.toLowerCase().contains('pembina'))
                                  ? status_datang.contains('0')
                                      ? Column(
                                        children: [
                                          Center(
                                            child: Text(
                                              'QR Code Konfirmasi Registrasi Ulang Peserta',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
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
                                              data:
                                                  '${GlobalVariables.serverUrl}syc2025/konfirmasi-datang?secret=$encryptedSecret',
                                              size: 180.0,
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Tunjukkan QR ke pembimbing kelompok untuk check-in\nJika sudah berhasil, silakan login kembali ke aplikasi',
                                            style: TextStyle(
                                              color: AppColors.brown1,
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )
                                      : Text(
                                        '✅  Terima kasih sudah melakukan konfirmasi registrasi ulang',
                                        style: TextStyle(
                                          color: AppColors.brown1,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                  : SizedBox.shrink(),
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
