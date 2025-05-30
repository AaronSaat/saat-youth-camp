// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '/utils/api_helper.dart';
import '/utils/debug_log.dart';

import '../widgets/custom_snackbar.dart';

class ApiService {
  // static const String baseUrl = 'http://172.172.52.9:82/reg-new/api2024/';
  static const String baseurl = 'http://172.172.52.11:8080/api-syc2025/';

  static Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    final url = Uri.parse('${baseurl}check-user');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }

  static Future<Map<String, dynamic>> checkSecret(
    String email,
    String secretCode,
  ) async {
    final url = Uri.parse('${baseurl}check-secret');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'random_id': secretCode}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Invalid Email or Secret Code');
    }
  }

  static Future<List<dynamic>> getAcara(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}acara');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> dataAcara = decoded['data_acara'] ?? [];

      print('✅ Data list acara berhasil dimuat:');
      for (var acara in dataAcara) {
        print('- ${acara['acara_nama']} | Hari: ${acara['hari']}');
      }

      return dataAcara;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load list acara');
    }
  }

  static Future<int> getAcaraCount(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}acara-count');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final int countAcara = int.tryParse(decoded['count'].toString()) ?? 0;

      print('✅ Data list acara berhasil dimuat:');
      print('Count Acara: $countAcara');

      return countAcara;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load count acara');
    }
  }

  static Future<int> getAcaraCountAll(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}acara-count-all');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final int countAcara = int.tryParse(decoded['count'].toString()) ?? 0;

      print('✅ Data list acara berhasil dimuat:');
      print('Count Acara All: $countAcara');

      return countAcara;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load count acara all');
    }
  }

  static Future<List<dynamic>> getAcaraByDay(BuildContext context, day) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}acara-by-day?hari=$day');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> dataAcara = decoded['data_acara'] ?? [];

      print('✅ Data acara berhasil dimuat:');
      for (var acara in dataAcara) {
        print('- ${acara['acara_nama']} | Hari: ${acara['hari']}');
      }

      return dataAcara;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load acara');
    }
  }

  static Future<List<dynamic>> getKomitmen(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}komitmen');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> dataKomitmen = decoded['data_komitmen'] ?? [];

      print('✅ Data list komitmen berhasil dimuat:');
      for (var acara in dataKomitmen) {
        print('- Hari: ${acara['hari']}');
      }

      return dataKomitmen;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load list komitmen');
    }
  }

  static Future<List<dynamic>> getGereja(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}gereja');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> dataGereja = decoded['data_gereja'] ?? [];

      print('✅ Data gereja berhasil dimuat:');
      for (var gereja in dataGereja) {
        print('${gereja['nama_gereja']}');
      }

      return dataGereja;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load gereja');
    }
  }

  static Future<List<dynamic>> getKelompok(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}kelompok');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> dataKelompok = decoded['data_kelompok'] ?? [];

      print('✅ Data kelompok berhasil dimuat:');
      for (var kelompok in dataKelompok) {
        print('${kelompok['data_kelompok']}');
      }

      return dataKelompok;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load kelompok');
    }
  }

  static Future<Map<String, dynamic>> getAnggotaGereja(
    BuildContext context,
    String gerejaId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}anggota-gereja?gereja_id=$gerejaId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final dataAnggotaGereja = decoded['data_anggota_gereja'];
      print(dataAnggotaGereja);
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load anggota gereja');
    }
  }

  static Future<Map<String, dynamic>> getAnggotaKelompok(
    BuildContext context,
    String kelompokId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}anggota-kelompok?kelompok_id=$kelompokId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final dataAnggotaKelompok = decoded['data_anggota_kelompok'];
      print(dataAnggotaKelompok);
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load anggota kelompok');
    }
  }
}
