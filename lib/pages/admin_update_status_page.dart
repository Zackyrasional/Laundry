import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';

class AdminUpdateStatusPage extends StatefulWidget {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final String pickupDateString;
  final String note;
  final String packageName;
  final int pricePerKg;

  final String currentStatus;
  final String? currentWeight;
  final String? currentTotal;

  const AdminUpdateStatusPage({
    super.key,
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.pickupDateString,
    required this.note,
    required this.packageName,
    required this.pricePerKg,
    required this.currentStatus,
    this.currentWeight,
    this.currentTotal,
  });

  @override
  State<AdminUpdateStatusPage> createState() =>
      _AdminUpdateStatusPageState();
}

class _AdminUpdateStatusPageState extends State<AdminUpdateStatusPage> {
  String? status;
  final weightController = TextEditingController();
  int? totalPrice;
  DateTime? pickupDate;

  bool saving = false;

  @override
  void initState() {
    super.initState();
    status = widget.currentStatus;

    if (widget.currentWeight != null &&
        widget.currentWeight!.trim().isNotEmpty) {
      weightController.text = widget.currentWeight!;
    }
    if (widget.currentTotal != null &&
        widget.currentTotal!.trim().isNotEmpty) {
      totalPrice = int.tryParse(widget.currentTotal!);
    }

    weightController.addListener(_recalculateTotal);

    try {
      pickupDate = DateTime.parse(widget.pickupDateString);
    } catch (_) {
      pickupDate = null;
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  void _recalculateTotal() {
    final w = double.tryParse(
      weightController.text.replaceAll(',', '.'),
    );
    if (w == null) {
      setState(() {
        totalPrice = null;
      });
      return;
    }

    setState(() {
      totalPrice = (w * widget.pricePerKg).round();
    });
  }

  String _formatPickupDate() {
    if (pickupDate == null) {
      return widget.pickupDateString;
    }
    final dt = pickupDate!;
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _update() async {
    setState(() {
      saving = true;
    });

    final wText = weightController.text.trim();
    final w = double.tryParse(wText.replaceAll(',', '.'));

    try {
      await Dio().post(
        '${ApiConfig.baseUrl}/admin/admin_update_status.php',
        data: {
          "id": widget.id,
          "status": status,
          "weight_kg": w,
          "total_price": totalPrice,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data reservasi berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail & Update Reservasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // DETAIL RESERVASI DARI PENGGUNA
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Pelanggan',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _detailRow('Nama panggilan', widget.customerName),
                    _detailRow('Nomor HP', widget.phone),
                    _detailRow('Alamat', widget.address),
                    const SizedBox(height: 8),
                    Text(
                      'Detail Paket & Jadwal',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _detailRow('Paket', widget.packageName),
                    _detailRow(
                        'Harga per kg', 'Rp ${widget.pricePerKg}/kg'),
                    _detailRow('Tanggal jemput', _formatPickupDate()),
                    if (widget.note.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Catatan Pelanggan:',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(widget.note),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // FORM STATUS + BERAT + TOTAL
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: 'Status Reservasi',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'dijemput',
                          child: Text('Dijemput'),
                        ),
                        DropdownMenuItem(
                          value: 'dicuci',
                          child: Text('Dicuci'),
                        ),
                        DropdownMenuItem(
                          value: 'selesai',
                          child: Text('Selesai'),
                        ),
                        DropdownMenuItem(
                          value: 'diantar',
                          child: Text('Diantar'),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          status = v;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: weightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Berat cucian (kg)',
                        border: OutlineInputBorder(),
                        helperText:
                            'Masukkan berat cucian setelah ditimbang di tempat laundry',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        totalPrice == null
                            ? 'Total Harga: -'
                            : 'Total Harga: Rp $totalPrice',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saving ? null : _update,
                        child: saving
                            ? const CircularProgressIndicator()
                            : const Text('Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
