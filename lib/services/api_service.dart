// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/screens/login_screen.dart';

import '/utils/api_helper.dart';
import '/utils/debug_log.dart';

import '../widgets/custom_snackbar.dart';

class ApiService {
  // static const String baseurl = 'http://172.172.52.9:82/reg-new/api-syc2025/';
  // static const String baseurlLocal = 'http://172.172.52.9/website_backup/api/';
  static const String baseurl = 'http://172.172.52.11:90/api-syc2025/';
  // static const String baseurl = 'https://reg.seabs.ac.id/api-syc2025/';
  // static const String baseurl = 'https://netunim.seabs.ac.id/api-syc202 5/';

  static Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    print('Attempting to login with username: $username');
    print('Attempting to login with password: $password');
    final url = Uri.parse('${baseurl}check-user');
    print('Login URL: $url');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    // http.Response response;
    // try {
    //   response = await http.post(
    //     url,
    //     headers: {'Content-Type': 'application/json'},
    //     body: json.encode({'username': username, 'password': password}),
    //   );
    // } catch (e) {
    //   print('Network error: $e');
    //   throw Exception('Network error: $e');
    // }
    print('Login response status: ${response.statusCode}');

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
    print('Checking secret for email: $email with code: $secretCode');
    final url = Uri.parse('${baseurl}check-secret');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'random_id': secretCode}),
    );

    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Invalid Email or Secret Code');
    }
  }

  static Future<bool> validateToken(
    BuildContext context, {
    required String token,
  }) async {
    if (token == null || token.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }

    final url = Uri.parse('${baseurl}brm-today');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> dataBacaan = json.decode(response.body);
      return dataBacaan['success'];
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
      // return false;
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to validate token');
      // return false;
    }
  }

  static Future<Map<String, dynamic>> getCountUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}count-user');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataUser = json.decode(response.body);

      return dataUser;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load count user');
    }
  }

  static Future<Map<String, dynamic>> getBrmToday(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}brm-today');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('test url: $url');
    // print('test response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataBacaan = json.decode(response.body);

      // print('✅ Data bacaan harian berhasil dimuat: ${dataBacaan}');
      // for (var evaluasi in dataBacaan['data_evaluasi']) {
      //   print('- Evaluasi: ${evaluasi['id']} | Status: ${evaluasi['hari']} | ${evaluasi['type']}');
      // }

      return dataBacaan;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load bacaan harian');
    }
  }

  static Future<Map<String, dynamic>> getBrmToday2(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}brm-today2');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('test url: $url');
    // print('test response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataBacaan = json.decode(response.body);

      // print('✅ Data bacaan harian berhasil dimuat: ${dataBacaan}');
      // for (var evaluasi in dataBacaan['data_evaluasi']) {
      //   print('- Evaluasi: ${evaluasi['id']} | Status: ${evaluasi['hari']} | ${evaluasi['type']}');
      // }

      return dataBacaan;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load bacaan harian');
    }
  }

  // untuk bacaan harian dashboard supaya tidak loading lama
  static Future<Map<String, dynamic>> getBrmTenDays(
    BuildContext context,
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}brm-ten-days?user_id=$userId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataBacaan = json.decode(response.body);

      return dataBacaan;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load data brm ten days');
    }
  }

  // untuk catatan list supaya tidak loading lama
  static Future<Map<String, dynamic>> getBrmByDay(
    BuildContext context,
    String day,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}brm-by-day?day=$day');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataBacaan = json.decode(response.body);

      return dataBacaan;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load data brm by day');
    }
  }

  // untuk catatan list supaya tidak loading lama
  static Future<List<dynamic>> getBrmByBulan(
    BuildContext context,
    String bulan,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}brm-by-bulan?bulan=$bulan');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> dataBacaan = decoded['data_brm'] ?? [];

      return dataBacaan;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load data brm by bulan');
    }
  }

  // di bible_reading_list
  static Future<String> getBacaanByDay(BuildContext context, String day) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}brm-report-by-day?day=$day');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('AARON: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataBacaan = json.decode(response.body);
      print('AARON: $dataBacaan');
      final String _dataBacaan = dataBacaan['data_brm']['passage'];

      // print('✅ Data bacaan $day berhasil dimuat: $_dataBacaan');
      return _dataBacaan;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return "";
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load perikop read bacaan harian');
    }
  }

  static Future<Map<String, dynamic>> getCountBrmReportByDay(
    BuildContext context,
    String day,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}count-brm-report-by-day?day=$day');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('urlaaron: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> databrm = json.decode(response.body);

      return databrm;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load count brm report by day');
    }
  }

  // untuk dashboaard bacaan
  static Future<Map<String, dynamic>> getBrmReportByPesertaByDay(
    BuildContext context,
    String userId,
    String day,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse(
      '${baseurl}brm-report-by-peserta-by-day?user_id=$userId&day=$day',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('BRM url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> databrm = json.decode(response.body);

      return databrm;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load brm report by day');
    }
  }

  // untuk catatan harian biar ga loading lama
  static Future<Map<String, dynamic>> getBrmReportByPesertaByBulan(
    BuildContext context,
    String userId,
    String bulan,
    String tahun,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse(
      '${baseurl}brm-report-by-peserta-by-bulan?user_id=$userId&bulan=$bulan&tahun=$tahun',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> databrm = json.decode(response.body);

      return databrm;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load brm report by bulan');
    }
  }

  static Future<int> getBrmReportCountByPesertaByDay(
    BuildContext context,
    String userId,
    String day,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse(
      '${baseurl}brm-report-by-peserta-by-day?user_id=$userId&day=$day',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> dataBacaan = json.decode(response.body);
      final int countRead = dataBacaan['count_read'];

      return countRead;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return 0;
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load count read bacaan harian');
    }
  }

  static Future<Map<String, dynamic>> postBrmDoneRead(
    BuildContext context,
    Map<String, dynamic> brmDoneRead,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}brm-done-read');
    final body = json.encode({'brm_done_read': brmDoneRead});

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('test body: $body');
    print('test url: $url');
    print('test response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201) {
      final Map<String, dynamic> result = json.decode(response.body);
      print('✅ Brm done read berhasil dikirim: $result');
      return result;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to post brm done read');
    }
  }

  static Future<Map<String, dynamic>> postBrmNotes(
    BuildContext context,
    Map<String, dynamic> brmNotes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}brm-notes');
    final body = json.encode({'data_notes': brmNotes});

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('test body: $body');
    print('test url: $url');
    print('test response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201) {
      final Map<String, dynamic> result = json.decode(response.body);
      print('✅ Brm done read berhasil dikirim: $result');
      return result;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to post brm done read');
    }
  }

  static Future<Map<String, dynamic>> putBrmNotes(
    BuildContext context,
    Map<String, dynamic> brmNotes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}brm-notes');
    final body = json.encode({'data_notes': brmNotes});

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('PUT body: $body');
    print('PUT url: $url');
    print('PUT response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.body);
      print('✅ PUT Brm done read berhasil dikirim: $result');
      return result;
    } else if (response.statusCode == 400) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to put / update brm done read');
    }
  }

  // untuk notes_harian
  static Future<Map<String, dynamic>> getBrmNotesByDay(
    BuildContext context,
    String day,
    String userId,
    int page,
    int pageSize,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse(
      '${baseurl}brm-notes-by-day?day=$day&user_id=$userId&page=$page&page_size=$pageSize',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataBacaan = json.decode(response.body);
      final List<dynamic> datanotes = dataBacaan['data_notes'];
      print('AARON: $datanotes');

      // print('✅ Data bacaan $day berhasil dimuat: $_dataBacaan');
      return dataBacaan;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load data brm notes by day');
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
      // throw Exception('Unauthorized');
      return [];
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
      // throw Exception('Unauthorized');
      return 0;
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
      // throw Exception('Unauthorized');
      return 0;
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
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load acara');
    }
  }

  static Future<List<dynamic>> getAcaraById(
    BuildContext context,
    String id,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}acara-by-id?id=$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url $url');
    print('response ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final dataAcara = decoded['data_acara'] ?? {};

      print('✅ Data acara by id berhasil dimuat: $dataAcara');

      // Kembalikan dalam bentuk list agar konsisten dengan return type
      return [dataAcara];
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load acara by id');
    }
  }

  static Future<List<dynamic>> getTanggalAcara(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}tanggal-acara');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final dataAcara = decoded['data_acara'] ?? {};

      print('✅ Tanggal acara berhasil dimuat: $dataAcara');

      // Kembalikan dalam bentuk list agar konsisten dengan return type
      return [dataAcara];
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load tanggal acara');
    }
  }

  static Future<Map<String, dynamic>> getEvaluasiByAcara(
    BuildContext context,
    acaraId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}evaluasi-by-acara?acara_id=$acaraId');
    print('URL: $url');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> dataEvaluasi = json.decode(response.body);

      print('✅ Data pertanyaan evaluasi acaraId-$acaraId  berhasil dimuat:');
      for (var evaluasi in dataEvaluasi['data_evaluasi']) {
        print(
          '- Evaluasi: ${evaluasi['id']} | Status: ${evaluasi['hari']} | ${evaluasi['type']}',
        );
      }

      return dataEvaluasi;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load pertanyaan evaluasi acaraId-$acaraId');
    }
  }

  static Future<Map<String, dynamic>> getEvaluasiByPesertaByAcara(
    BuildContext context,
    userId,
    acaraId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse(
      '${baseurl}evaluasi-by-peserta-by-acara?user_id=$userId&acara_id=$acaraId',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('URL: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataEvaluasi = json.decode(response.body);

      print(
        '✅ Data jawaban evaluasi acaraId-$acaraId oleh user id $userId berhasil dimuat:',
      );
      // for (var evaluasi in dataEvaluasi['data_evaluasi']) {
      //   print(
      //     '- Evaluasi: ${evaluasi['id']} | Status: ${evaluasi['hari']} | ${evaluasi['type']}',
      //   );
      // }

      return dataEvaluasi;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else if (response.statusCode == 404) {
      return {'status': 404, 'success': false};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception(
        'Failed to load jawaban evaluasi acaraId-$acaraId oleh user id $userId',
      );
    }
  }

  static Future<Map<String, dynamic>> getCountEvaluasiAnsweredByPeserta(
    BuildContext context,
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse(
      '${baseurl}count-evaluasi-answered-by-peserta?user_id=$userId',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataevaluasi = json.decode(response.body);

      return dataevaluasi;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load count evaluasi answered by peserta');
    }
  }

  static Future<Map<String, dynamic>> getCountEvaluasiAnsweredByAcara(
    BuildContext context,
    String acaraId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse(
      '${baseurl}count-evaluasi-answered-by-acara?acara_id=$acaraId',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataevaluasi = json.decode(response.body);

      return dataevaluasi;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load count evaluasi answered by acara');
    }
  }

  static Future<Map<String, dynamic>> postEvaluasiAnswer(
    BuildContext context,
    List<Map<String, dynamic>> evaluasiAnswers,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}evaluasi-answer');
    final body = json.encode({'evaluasi_answer': evaluasiAnswers});

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('test evaluasi answer: $body');
    print('test url: $url');
    print('test response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201) {
      final Map<String, dynamic> result = json.decode(response.body);
      print('✅ Evaluasi answer berhasil dikirim: $result');
      return result;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to post evaluasi answer');
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
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load list komitmen');
    }
  }

  static Future<Map<String, dynamic>> getKomitmenByDay(
    BuildContext context,
    day,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}komitmen-by-day?hari=$day');
    print('URL: $url');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> dataKomitmen = json.decode(response.body);

      print('✅ Data pertanyaan komitmen hari-$day  berhasil dimuat:');
      for (var komitmen in dataKomitmen['data_komitmen']) {
        print(
          '- komitmen: ${komitmen['id']} | Status: ${komitmen['hari']} | ${komitmen['type']}',
        );
      }

      return dataKomitmen;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load pertanyaan komitmen hari-$day');
    }
  }

  static Future<Map<String, dynamic>> getKomitmenByPesertaByDay(
    BuildContext context,
    userId,
    day,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse(
      '${baseurl}komitmen-by-peserta-by-day?user_id=$userId&hari=$day',
    );
    print('URL: $url');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> dataKomitmen = json.decode(response.body);

      print(
        '✅ Data jawaban komitmen hari-$day oleh user id $userId berhasil dimuat:',
      );
      for (var komitmen in dataKomitmen['data_komitmen']) {
        print(
          '- Komitmen: ${komitmen['id']} | Status: ${komitmen['hari']} | ${komitmen['type']}',
        );
      }

      return dataKomitmen;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else if (response.statusCode == 404) {
      return {'status': 404, 'success': false};
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception(
        'Failed to load jawaban komitmen hari-$day oleh user id $userId',
      );
    }
  }

  static Future<Map<String, dynamic>> getCountKomitmenAnsweredByPeserta(
    BuildContext context,
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse(
      '${baseurl}count-komitmen-answered-by-peserta?user_id=$userId',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> datakomitmen = json.decode(response.body);

      return datakomitmen;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load count komitmen answered by peserta');
    }
  }

  static Future<Map<String, dynamic>> getCountKomitmenAnsweredByDay(
    BuildContext context,
    String day,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}count-komitmen-answered-by-day?day=$day');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> datakomitmen = json.decode(response.body);

      return datakomitmen;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load count komitmen answered by day');
    }
  }

  static Future<Map<String, dynamic>> postKomitmenAnswer(
    BuildContext context,
    List<Map<String, dynamic>> komitmenAnswers,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}komitmen-answer');
    final body = json.encode({'komitmen_answer': komitmenAnswers});

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> result = json.decode(response.body);
      print('✅ Komitmen answer berhasil dikirim: $result');
      return result;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to post komitmen answer');
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
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load gereja');
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
    // sebagai parameter gerejaId berupa string, tapi di link API-nya berupa integer / string (tanpa "")
    final parsed = int.tryParse(gerejaId) ?? gerejaId;
    print('Parsed gerejaId: $parsed');

    final url = Uri.parse('${baseurl}anggota-gereja?group_id=$parsed');
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
      // throw Exception('Unauthorized');
      return {};
    } else {
      throw Exception('Failed to load anggota gereja');
    }
  }

  static Future<List<dynamic>> getGroup(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}group');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> dataGroup = decoded['data_group'] ?? [];

      print('✅ Data gereja berhasil dimuat:');
      for (var gereja in dataGroup) {
        print('${gereja['gereja_nama']}');
        print('${gereja['group_id']}');
      }

      return dataGroup;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load gereja');
    }
  }

  static Future<List<dynamic>> getPanitia(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}panitia');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    print('response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> dataPanitia = decoded['data_panitia'] ?? [];

      print('✅ Data panitia berhasil dimuat: $dataPanitia');

      return dataPanitia;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load panitia');
    }
  }

  static Future<Map<String, dynamic>> getAnggotaGroup(
    BuildContext context,
    String groupId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }
    // sebagai parameter groupId berupa string, tapi di link API-nya berupa integer / string (tanpa "")
    final parsed = int.tryParse(groupId) ?? groupId;
    print('Parsed groupId: $parsed');

    final url = Uri.parse('${baseurl}anggota-group?group_id=$parsed');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('URL: $url');
    print('Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final dataAnggotaGereja = decoded['data_anggota_group'];
      print(dataAnggotaGereja);
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      throw Exception('Failed to load anggota group');
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
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load kelompok');
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
    // sebagai parameter kelompokId berupa string, tapi di link API-nya berupa integer
    final parsed = int.tryParse(kelompokId) ?? kelompokId;
    print('Parsed kelompokId: $parsed');

    final url = Uri.parse('${baseurl}anggota-kelompok?kelompok_id=$parsed');
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
      // throw Exception('Unauthorized');
      return {};
    } else {
      throw Exception('Failed to load anggota kelompok');
    }
  }

  static Future<List<Map<String, dynamic>>> getPengumuman(
    BuildContext context,
    id,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}pengumuman?user_id=$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url $url');
    print('response ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List pengumuman = decoded['data_pengumuman'] ?? [];
      return List<Map<String, dynamic>>.from(pengumuman);
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load pengumuman');
    }
  }

  static Future<List<Map<String, dynamic>>> getPengumumanNotRead(
    BuildContext context,
    id,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}pengumuman-not-read?user_id=$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url $url');
    print('response ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List pengumuman = decoded['data_pengumuman'] ?? [];
      return List<Map<String, dynamic>>.from(pengumuman);
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load pengumuman not read');
    }
  }

  static Future<Map<String, dynamic>> postPengumumanMarkRead(
    BuildContext context,
    Map<String, dynamic> pengumumanData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}pengumuman-mark-read');
    final body = json.encode({'data_pengumuman': pengumumanData});

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> result = json.decode(response.body);
      print('✅ Pengumuman mark read berhasil dikirim: $result');
      return result;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to post komitmen answer');
    }
  }

  static Future<String> getAvatarById(BuildContext context, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}avatar-by-id?user_id=$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataGambar = json.decode(response.body);
      final String _dataGambar = dataGambar['avatar_url'];

      // print('✅ Data bacaan $day berhasil dimuat: $_dataGambar');
      return _dataGambar;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return "";
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load data gambar oleh id $id');
    }
  }

  static Future<Map<String, dynamic>> postAvatar(
    BuildContext context,
    String filePath, {
    Map<String, dynamic>? body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}avatar');
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';

    // Attach the image file
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    // Add user_id if provided in body
    if (body != null) {
      if (body['user_id'] != null) {
        request.fields['user_id'] = body['user_id'].toString();
      }
    }
    print('Request URL: ${request.url}');
    print('Request Headers: ${request.headers}');
    print('Request Fields: ${request.fields}');
    print('Request Files: ${request.files.map((f) => f.filename).join(', ')}');
    print('Request Body: ${request.fields}');
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        showCustomSnackBar(
          context,
          'Sesi login Anda telah habis. Silakan login kembali.',
        );
        await handleUnauthorized(context);
        // throw Exception('Unauthorized');
        return {};
      } else {
        print('❌ Error postimage: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print('HTTP error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMateri(
    BuildContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}materi');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url $url');
    print('response ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List materi = decoded['data_materi'] ?? [];
      return List<Map<String, dynamic>>.from(materi);
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return [];
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load materi');
    }
  }

  static Future<Map<String, dynamic>> postKonfirmasiDatang(
    BuildContext context,
    Map<String, dynamic> konfirmasiData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseurl}konfirmasi-datang');
    final body = json.encode({'data_konfirmasi': konfirmasiData});

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('test url: $url');
    print('test response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201) {
      final Map<String, dynamic> result = json.decode(response.body);
      print('✅ Konfirmasi datang berhasil dikirim: $result');
      return result;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(
        context,
        'Sesi login Anda telah habis. Silakan login kembali.',
      );
      await handleUnauthorized(context);
      // throw Exception('Unauthorized');
      return {};
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to post konfirmasi datang');
    }
  }

  static Future<Map<String, dynamic>> getCheckVersion(
    BuildContext context,
  ) async {
    final url = Uri.parse('${baseurl}check-version');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    print('url $url');
    print('response ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataVersion = json.decode(response.body);

      return dataVersion;
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load version');
    }
  }

  static Future<Map<String, dynamic>> getStatusDatang(
    BuildContext context,
    String secret,
    String email,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }
    final url = Uri.parse(
      '${baseurl}status-datang?secret=$secret&email=$email',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url $url');
    print('response ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataVersion = json.decode(response.body);

      return dataVersion;
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load data status datang');
    }
  }

  static Future<Map<String, dynamic>> getDataKonfirmasi(
    BuildContext context,
    String secret,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }
    final url = Uri.parse('${baseurl}data-konfirmasi?secret=$secret');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('url $url');
    print('response ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> dataVersion = json.decode(response.body);

      return dataVersion;
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load data konfirmasi');
    }
  }
}
