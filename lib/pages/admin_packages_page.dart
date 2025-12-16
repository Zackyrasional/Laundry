import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_packages_provider.dart';

class AdminPackagesPage extends ConsumerWidget {
  const AdminPackagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminPackagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Paket Laundry'),
        actions: [
          IconButton(
            onPressed: () => ref.read(adminPackagesProvider.notifier).fetch(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('Belum ada paket.'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final p = list[i];
              final id = int.tryParse(p['id'].toString()) ?? 0;
              final name = (p['name'] ?? '').toString();
              final price = (p['price_per_kg'] ?? '').toString();
              final dur = (p['duration_hours'] ?? '').toString();
              final img = (p['image_url'] ?? '').toString();

              return Card(
                child: ListTile(
                  title: Text(name),
                  subtitle: Text('Rp $price/kg • ${dur} jam'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openForm(
                          context,
                          ref,
                          initial: _PkgFormData(
                            id: id,
                            name: name,
                            pricePerKg: int.tryParse(price) ?? 0,
                            durationHours: int.tryParse(dur) ?? 0,
                            imageUrl: img,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(context, ref, id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Paket'),
        content: const Text('Yakin ingin menghapus paket ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (ok != true) return;

    final notifier = ref.read(adminPackagesProvider.notifier);
    final success = await notifier.delete(id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Paket dihapus' : (notifier.errorMessage ?? 'Gagal hapus paket'))),
    );
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref, { _PkgFormData? initial }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PackageForm(initial: initial),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _PkgFormData {
  final int? id;
  final String name;
  final int pricePerKg;
  final int durationHours;
  final String imageUrl;

  _PkgFormData({
    this.id,
    required this.name,
    required this.pricePerKg,
    required this.durationHours,
    required this.imageUrl,
  });
}

class _PackageForm extends ConsumerStatefulWidget {
  final _PkgFormData? initial;
  const _PackageForm({this.initial});

  @override
  ConsumerState<_PackageForm> createState() => _PackageFormState();
}

class _PackageFormState extends ConsumerState<_PackageForm> {
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final durC = TextEditingController();
  final imgC = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null) {
      nameC.text = init.name;
      priceC.text = init.pricePerKg.toString();
      durC.text = init.durationHours.toString();
      imgC.text = init.imageUrl;
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    priceC.dispose();
    durC.dispose();
    imgC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameC.text.trim();
    final price = int.tryParse(priceC.text.trim()) ?? -1;
    final dur = int.tryParse(durC.text.trim()) ?? -1;
    final img = imgC.text.trim();

    if (name.isEmpty || price <= 0 || dur <= 0 || img.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua field dengan benar')),
      );
      return;
    }

    setState(() => loading = true);
    final notifier = ref.read(adminPackagesProvider.notifier);

    final success = (widget.initial == null)
        ? await notifier.create(name: name, pricePerKg: price, durationHours: dur, imageUrl: img)
        : await notifier.update(
            id: widget.initial!.id!,
            name: name,
            pricePerKg: price,
            durationHours: dur,
            imageUrl: img,
          );

    setState(() => loading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Berhasil disimpan' : (notifier.errorMessage ?? 'Gagal menyimpan'))),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.initial != null;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEdit ? 'Edit Paket' : 'Tambah Paket', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nama Paket', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: priceC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga per Kg', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: durC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Durasi (jam)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: imgC, decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder())),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _save,
                child: loading ? const CircularProgressIndicator() : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
