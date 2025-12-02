import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../models/app_user.dart';

class UserAuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    try {
      final res = await Dio().post(
        '${ApiConfig.baseUrl}/user/user_register.php',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'address': address,
        },
      );

      if (res.data['status'] == 'success') {
        final u = res.data['user'];
        state = AppUser(
          id: u['id'].toString(),
          name: u['name'],
          email: u['email'],
          phone: u['phone'],
          address: u['address'] ?? '',
        );
        return null;
      } else {
        return res.data['message'] as String;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await Dio().post(
        '${ApiConfig.baseUrl}/user/user_login.php',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (res.data['status'] == 'success') {
        final u = res.data['user'];
        state = AppUser(
          id: u['id'].toString(),
          name: u['name'],
          email: u['email'],
          phone: u['phone'],
          address: u['address'] ?? '',
        );
        return null;
      } else {
        return res.data['message'] as String;
      }
    } catch (e) {
      return e.toString();
    }
  }

  void logout() {
    state = null;
  }
}

final userAuthProvider =
    NotifierProvider<UserAuthNotifier, AppUser?>(UserAuthNotifier.new);
