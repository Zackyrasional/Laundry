import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_auth_provider.dart';
import '../providers/admin_auth_provider.dart';
import 'home_page.dart';
import 'admin_dashboard_page.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // LOGIN (user + admin)
  final loginIdC = TextEditingController();   // Email (User) / Username (Admin)
  final loginPassC = TextEditingController();

  // REGISTER (user)
  final regNameC = TextEditingController();
  final regEmailC = TextEditingController();
  final regPhoneC = TextEditingController();
  final regPassC = TextEditingController();
  final regAddressC = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    // 2 tab: Login + Register
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    loginIdC.dispose();
    loginPassC.dispose();
    regNameC.dispose();
    regEmailC.dispose();
    regPhoneC.dispose();
    regPassC.dispose();
    regAddressC.dispose();
    super.dispose();
  }

  // LOGIN: kalau mengandung @ -> user, kalau tidak -> admin
  Future<void> _doLogin() async {
    final id = loginIdC.text.trim();
    final pass = loginPassC.text.trim();

    if (id.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi email/username dan password')),
      );
      return;
    }

    setState(() => loading = true);

    if (id.contains('@')) {
      // login sebagai user (email)
      final msg = await ref.read(userAuthProvider.notifier).login(
            email: id,
            password: pass,
          );

      setState(() => loading = false);

      if (msg != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // login sebagai admin (username)
      final success =
          await ref.read(adminAuthProvider.notifier).login(id, pass);

      setState(() => loading = false);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login gagal. Cek email/username dan password.'),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
      );
    }
  }

  // REGISTER user
  Future<void> _doRegister() async {
    final name = regNameC.text.trim();
    final email = regEmailC.text.trim();
    final phone = regPhoneC.text.trim();
    final pass = regPassC.text.trim();
    final address = regAddressC.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        pass.isEmpty ||
        address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field register wajib diisi')),
      );
      return;
    }

    setState(() => loading = true);

    final msg = await ref.read(userAuthProvider.notifier).register(
          name: name,
          email: email,
          password: pass,
          phone: phone,
          address: address,
        );

    setState(() => loading = false);

    if (msg != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrasi berhasil, Anda sudah login')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservasi Laundry'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Login'),
            Tab(text: 'Register'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginTab(),
          _buildRegisterTab(),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: loginIdC,
            decoration: const InputDecoration(
              labelText: 'Email (User) / Username (Admin)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: loginPassC,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : _doLogin,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: regNameC,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: regEmailC,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: regPhoneC,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor HP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: regAddressC,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: regPassC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _doRegister,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
