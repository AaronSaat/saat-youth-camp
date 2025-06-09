// lib/services/api_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '/utils/api_helper.dart';
import '/utils/debug_log.dart';

import '../widgets/custom_snackbar.dart';

class ApiService {
  // static const String baseurl = 'http://172.172.52.9:82/reg-new/api-syc2025/';
  // static const String baseurl = 'http://172.172.52.11:8080/api-syc2025/';
  static const String baseurl = 'http://172.172.52.11:8080/api-syc2025/';

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

  static Future<Map<String, dynamic>> loginUserDio(
    String username,
    String password,
  ) async {
    final dio = Dio();
    final url = '${baseurl}check-user';
    print('Login URL (Dio): $url');
    try {
      final response = await dio.post(
        url,
        data: {'username': username, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print('Login response status (Dio): ${response.statusCode}');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      print('Dio error: $e');
      throw Exception('Network error: $e');
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
    print('test response: ${response.statusCode} - ${response.body}');
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
      throw Exception('Unauthorized');
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load bacaan harian');
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

    print('test evaluasi answer: $body');
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
      throw Exception('Unauthorized');
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to post brm done read');
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
      throw Exception('Unauthorized');
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

    if (response.statusCode == 200) {
      final Map<String, dynamic> dataEvaluasi = json.decode(response.body);

      print(
        '✅ Data jawaban evaluasi acaraId-$acaraId oleh user id $userId berhasil dimuat:',
      );
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
      throw Exception('Unauthorized');
    } else {
      print('❌ Error test: ${response.statusCode} - ${response.body}');
      throw Exception(
        'Failed to load jawaban evaluasi acaraId-$acaraId oleh user id $userId',
      );
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
      throw Exception('Unauthorized');
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
      throw Exception('Unauthorized');
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
      throw Exception('Unauthorized');
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
      throw Exception('Unauthorized');
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      throw Exception(
        'Failed to load jawaban komitmen hari-$day oleh user id $userId',
      );
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
      throw Exception('Unauthorized');
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
    // sebagai parameter gerejaId berupa string, tapi di link API-nya berupa integer / string (tanpa "")
    final parsed = int.tryParse(gerejaId) ?? gerejaId;
    print('Parsed gerejaId: $parsed');

    final url = Uri.parse('${baseurl}anggota-gereja?gereja_id=$parsed');
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
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load anggota kelompok');
    }
  }
}
