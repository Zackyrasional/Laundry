import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../providers/admin_auth_provider.dart';
import 'auth_page.dart';
import 'admin_update_status_page.dart';

// tambahkan ini (file CRUD paket admin yang nanti Anda buat)
import 'admin_packages_page.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  List reservations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await Dio().get(
        '${ApiConfig.baseUrl}/admin/admin_get_reservations.php',
      );

      // asumsi API Anda mengembalikan List langsung
      reservations = response.data as List;
    } catch (e) {
      debugPrint('Error load reservations: $e');
      reservations = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat reservasi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dt = DateTime.parse(dateTimeString);
      return '${dt.day}/${dt.month}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateTimeString;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'dijemput':
        return 'Dijemput';
      case 'dicuci':
        return 'Dicuci';
      case 'selesai':
        return 'Selesai';
      case 'diantar':
        return 'Diantar';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'dijemput':
        return Colors.blue;
      case 'dicuci':
        return Colors.indigo;
      case 'selesai':
        return Colors.green;
      case 'diantar':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _goToPackages() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminPackagesPage()),
    );
  }

  Future<void> _logout() async {
    await ref.read(adminAuthProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Reservasi'),
        actions: [
          IconButton(
            onPressed: _loadReservations,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Reservasi',
          ),

          // BARU: tombol kelola paket (CRUD)
          IconButton(
            onPressed: _goToPackages,
            icon: const Icon(Icons.local_laundry_service),
            tooltip: 'Kelola Paket Laundry',
          ),

          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout Admin',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reservations.isEmpty
              ? const Center(
                  child: Text('Belum ada reservasi yang tercatat.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reservations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final r = reservations[index];

                    final customerName = (r['customer_name'] ?? '').toString();
                    final packageName = (r['package_name'] ?? '').toString();
                    final status = (r['status'] ?? 'pending').toString();
                    final pickup = (r['pickup_date'] ?? '').toString();

                    final weight = r['weight_kg'];
                    final total = r['total_price'];

                    String subtitle = _formatDateTime(pickup);
                    if (weight != null && total != null) {
                      subtitle += ' • ${weight.toString()} kg • Rp ${total.toString()}';
                    }

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _statusColor(status).withOpacity(0.15),
                          child: Text(
                            customerName.isNotEmpty
                                ? customerName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(customerName.isEmpty ? 'Tanpa Nama' : customerName),
                        subtitle: Text('$packageName • $subtitle'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: _statusColor(status),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _statusText(status),
                              style: TextStyle(
                                fontSize: 11,
                                color: _statusColor(status),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminUpdateStatusPage(
                                id: r['id'].toString(),
                                customerName: customerName,
                                phone: (r['phone'] ?? '').toString(),
                                address: (r['address'] ?? '').toString(),
                                pickupDateString: pickup,
                                note: (r['note'] ?? '').toString(),
                                packageName: packageName,
                                pricePerKg: int.tryParse(r['price_per_kg'].toString()) ?? 0,
                                currentStatus: status,
                                currentWeight: r['weight_kg']?.toString(),
                                currentTotal: r['total_price']?.toString(),
                              ),
                            ),
                          ).then((_) => _loadReservations());
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
