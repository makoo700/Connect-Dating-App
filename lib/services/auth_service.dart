import 'package:flutter/material.dart';
import 'package:flutter_dating_app/db/database_helper.dart';
import 'package:flutter_dating_app/models/user.dart';

class AuthService extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> initDatabase() async {
    await _dbHelper.database;
  }

  Future<bool> isLoggedIn() async {
    // Check if there's a current user in memory
    if (_currentUser != null) return true;

    // Check if there's a user in the database
    final users = await _dbHelper.getAllUsers();
    return users.isNotEmpty;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required int age,
    required String gender,
    required String bio,
    required List<String> interests,
    double latitude = 0.0,
    double longitude = 0.0,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        return false;
      }

      // Create new user
      final user = User(
        name: name,
        email: email,
        password: password,
        phone: phone,
        age: age,
        gender: gender,
        bio: bio,
        interests: interests,
        latitude: latitude,
        longitude: longitude,
      );

      // Insert user into database
      final userId = await _dbHelper.insertUser(user);
      
      // Set current user
      _currentUser = user.copyWith(id: userId);
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      // Get user by email
      final user = await _dbHelper.getUserByEmail(email);
      
      // Check if user exists and password matches
      if (user != null && user.password == password) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile(User updatedUser) async {
    try {
      // Update user in database
      await _dbHelper.updateUser(updatedUser);
      
      // Update current user
      _currentUser = updatedUser;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }
}
