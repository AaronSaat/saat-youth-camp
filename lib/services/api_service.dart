// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '/utils/api_helper.dart';
import '/utils/debug_log.dart';

import '../widgets/custom_snackbar.dart';

class ApiService {
  static const String baseUrl = 'http://172.172.52.9:82/reg-new/api2024/';

  static Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final url = Uri.parse('${baseUrl}checkuser');
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

  static Future<Map<String, dynamic>> checkSecret(String email, String secretCode) async {
    final url = Uri.parse('${baseUrl}checksecret');
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

  // ga dipake, register dari web
  static Future<Map<String, dynamic>> registerUser(String email, String username, String password) async {
    final url = Uri.parse('${baseUrl}registeruser');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Registrasi gagal');
    }
  }

  static Future<Map<String, dynamic>> getGroupAndChurchMembers(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseUrl}getgroupandchurchmembers');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(context, 'Sesi login Anda telah habis. Silakan login kembali.');
      // await Future.delayed(const Duration(seconds: 5));
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<List<dynamic>> getAllUsers(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseUrl}getallusers');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(context, 'Sesi login Anda telah habis. Silakan login kembali.');
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<Map<String, dynamic>> getMyChurchMembers(BuildContext context, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseUrl}getmychurchmembers');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(context, 'Sesi login Anda telah habis. Silakan login kembali.');
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load church members');
    }
  }

  static Future<Map<String, dynamic>> getMyGroupMembers(BuildContext context, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final url = Uri.parse('${baseUrl}getmygroupmembers');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      showCustomSnackBar(context, 'Sesi login Anda telah habis. Silakan login kembali.');
      await handleUnauthorized(context);
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load group members');
    }
  }
}
