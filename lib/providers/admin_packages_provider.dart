import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';

class AdminPackagesNotifier extends Notifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Dio _dio = Dio();
  String? errorMessage;

  @override
  AsyncValue<List<Map<String, dynamic>>> build() {
    fetch();
    return const AsyncLoading();
  }

  String _url(String path) {
    final base = ApiConfig.baseUrl;
    if (path.startsWith('/')) return '$base$path';
    return '$base/$path';
  }

  Future<void> fetch() async {
    errorMessage = null;
    state = const AsyncLoading();

    try {
      final res = await _dio.get(_url('/admin/admin_get_packages.php'));
      final body = res.data;

      if (body is Map && body['status'] == 'success' && body['data'] is List) {
        final list = (body['data'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        state = AsyncData(list);
        return;
      }

      errorMessage = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Gagal mengambil data paket (format response tidak sesuai).';
      state = AsyncError(errorMessage!, StackTrace.current);
    } catch (e) {
      errorMessage = 'Error fetch paket: $e';
      state = AsyncError(errorMessage!, StackTrace.current);
    }
  }

  Future<bool> create({
    required String name,
    required int pricePerKg,
    required int durationHours,
    required String imageUrl,
  }) async {
    errorMessage = null;

    try {
      final res = await _dio.post(
        _url('/admin/admin_create_package.php'),
        data: {
          'name': name,
          'price_per_kg': pricePerKg,
          'duration_hours': durationHours,
          'image_url': imageUrl,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final body = res.data;
      if (body is Map && body['status'] == 'success') {
        await fetch();
        return true;
      }

      errorMessage = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Gagal menambah paket.';
      return false;
    } catch (e) {
      errorMessage = 'Error tambah paket: $e';
      return false;
    }
  }

  Future<bool> update({
    required int id,
    required String name,
    required int pricePerKg,
    required int durationHours,
    required String imageUrl,
  }) async {
    errorMessage = null;

    try {
      final res = await _dio.post(
        _url('/admin/admin_update_package.php'),
        data: {
          'id': id,
          'name': name,
          'price_per_kg': pricePerKg,
          'duration_hours': durationHours,
          'image_url': imageUrl,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final body = res.data;
      if (body is Map && body['status'] == 'success') {
        await fetch();
        return true;
      }

      errorMessage = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Gagal update paket.';
      return false;
    } catch (e) {
      errorMessage = 'Error update paket: $e';
      return false;
    }
  }

  Future<bool> delete(int id) async {
    errorMessage = null;

    try {
      final res = await _dio.post(
        _url('/admin/admin_delete_package.php'),
        data: {'id': id},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final body = res.data;
      if (body is Map && body['status'] == 'success') {
        await fetch();
        return true;
      }

      errorMessage = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Gagal hapus paket.';
      return false;
    } catch (e) {
      errorMessage = 'Error hapus paket: $e';
      return false;
    }
  }
}

final adminPackagesProvider = NotifierProvider<AdminPackagesNotifier, AsyncValue<List<Map<String, dynamic>>>>(
  () => AdminPackagesNotifier(),
);
