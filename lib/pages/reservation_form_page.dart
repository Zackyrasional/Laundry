import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/laundry_package.dart';
import '../models/reservation.dart';
import '../providers/user_auth_provider.dart';
import '../providers/reservation_provider.dart';
import 'reservation_detail_page.dart';

class ReservationFormPage extends ConsumerStatefulWidget {
  final LaundryPackage package;

  const ReservationFormPage({super.key, required this.package});

  @override
  ConsumerState<ReservationFormPage> createState() =>
      _ReservationFormPageState();
}

class _ReservationFormPageState
    extends ConsumerState<ReservationFormPage> {
  final _formKey = GlobalKey<FormState>();

  final nicknameC = TextEditingController(); // nama panggilan
  final phoneC = TextEditingController();
  final addressC = TextEditingController();
  final noteC = TextEditingController();

  DateTime? pickupDate;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userAuthProvider);
    if (user != null) {
      phoneC.text = user.phone;
      addressC.text = user.address;
    }
  }

  @override
  void dispose() {
    nicknameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    noteC.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;

    setState(() {
      pickupDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (pickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal jemput')),
      );
      return;
    }

    final user = ref.read(userAuthProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    setState(() => submitting = true);

    final reservation = Reservation(
      id: '', // akan diambil ulang dari server setelah create
      customerName: nicknameC.text.trim(), // nama panggilan
      phone: phoneC.text.trim(),
      address: addressC.text.trim(),
      pickupDate: pickupDate!,
      note: noteC.text.trim(),
      package: widget.package,
      createdAt: DateTime.now(),
      weightKg: null,
      totalPrice: null,
      status: 'pending',
    );

    await ref.read(reservationProvider.notifier).createReservation(reservation);

    setState(() => submitting = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReservationDetailPage(reservation: reservation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pkg = widget.package;

    return Scaffold(
      appBar: AppBar(
        title: Text('Form Reservasi - ${pkg.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Rp ${pkg.price}/kg • ~ ${pkg.durationInHours} jam'),
                  const Divider(height: 24),

                  // Nama panggilan
                  TextFormField(
                    controller: nicknameC,
                    decoration: const InputDecoration(
                      labelText: 'Nama panggilan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nama panggilan wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Nomor HP (auto dari user)
                  TextFormField(
                    controller: phoneC,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor HP',
                      border: OutlineInputBorder(),
                      helperText:
                          'Nomor HP diisi dari profil, bisa diganti jika perlu',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nomor HP wajib diisi';
                      }
                      if (v.trim().length < 8) {
                        return 'Nomor HP tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Alamat lengkap (auto dari user)
                  TextFormField(
                    controller: addressC,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Alamat lengkap',
                      border: OutlineInputBorder(),
                      helperText:
                          'Alamat diisi dari profil, bisa diganti jika perlu',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Alamat wajib diisi';
                      }
                      if (v.trim().length < 10) {
                        return 'Alamat terlalu pendek';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Catatan (opsional)
                  TextFormField(
                    controller: noteC,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tanggal jemput
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pickupDate == null
                              ? 'Belum pilih tanggal jemput'
                              : 'Tanggal jemput: '
                                '${pickupDate!.day}/${pickupDate!.month}/${pickupDate!.year} '
                                '${pickupDate!.hour.toString().padLeft(2, '0')}:'
                                '${pickupDate!.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickDateTime,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Pilih'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitting ? null : _submit,
                      child: submitting
                          ? const CircularProgressIndicator()
                          : const Text('Kirim Reservasi'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
