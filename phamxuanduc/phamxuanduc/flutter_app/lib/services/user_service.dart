import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Get my profile ─────────────────────────────────────────────────────────
  Future<UserModel> getMe() async {
    final response = await http.get(
      Uri.parse(ApiConstants.me),
      headers: await _authHeaders(),
    );
    _checkStatus(response);
    return UserModel.fromJson(jsonDecode(response.body));
  }

  // ── Get all users (Admin only) ─────────────────────────────────────────────
  Future<List<UserModel>> getAllUsers() async {
    final response = await http.get(
      Uri.parse(ApiConstants.users),
      headers: await _authHeaders(),
    );
    _checkStatus(response);
    final list = jsonDecode(response.body) as List;
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  // ── Get user by id ─────────────────────────────────────────────────────────
  Future<UserModel> getUserById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.users}/$id'),
      headers: await _authHeaders(),
    );
    _checkStatus(response);
    return UserModel.fromJson(jsonDecode(response.body));
  }

  // ── Create user (Admin only) ───────────────────────────────────────────────
  Future<UserModel> createUser({
    required String username,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.users),
      headers: await _authHeaders(),
      body: jsonEncode({'username': username, 'password': password, 'role': role}),
    );
    _checkStatus(response);
    return UserModel.fromJson(jsonDecode(response.body));
  }

  // ── Update user ────────────────────────────────────────────────────────────
  Future<UserModel> updateUser(
    int id, {
    String? username,
    String? password,
    String? role,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (password != null) body['password'] = password;
    if (role != null)     body['role']     = role;

    final response = await http.put(
      Uri.parse('${ApiConstants.users}/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    _checkStatus(response);
    return UserModel.fromJson(jsonDecode(response.body));
  }

  // ── Delete user (Admin only) ───────────────────────────────────────────────
  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.users}/$id'),
      headers: await _authHeaders(),
    );
    _checkStatus(response);
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      String message = 'Request failed (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        message = body['message'] ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }
}
