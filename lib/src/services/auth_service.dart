import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
  );
}

class AuthService {
  static const _userKey = 'current_user';
  static const _isLoggedInKey = 'is_logged_in';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<UserModel> login({
    required String email,
    required String password,
    required String name,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Create user
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.isNotEmpty ? name : email.split('@').first,
      email: email,
    );

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);

    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  Future<void> updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }
}