import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Supabase.instance.isInitialized) {
      return const PhoneLoginScreen();
    }

    final client = Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = client.auth.currentUser;
        if (user == null) return const PhoneLoginScreen();

        return FutureBuilder<Map<String, dynamic>?>(
          future: client
              .from('profiles')
              .select('role')
              .eq('id', user.id)
              .maybeSingle(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState != ConnectionState.done) {
              return const _LoadingScreen();
            }

            final role = profileSnapshot.data?['role'] as String?;
            final requestedRole =
                user.userMetadata?['requested_role'] as String?;

            if (role == 'courier') return const CourierHomeScreen();
            if (requestedRole == 'courier' && role != 'admin') {
              return const CourierPendingScreen();
            }
            return const HomeScreen();
          },
        );
      },
    );
  }
}

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController(text: '+998');
  final _codeController = TextEditingController();
  String _selectedRole = 'customer';
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String get _phone => _phoneController.text.replaceAll(' ', '');

  Future<void> _sendCode() async {
    if (_phone.length < 10 || !_phone.startsWith('+')) {
      setState(() => _error = 'Telefon raqamini +998 bilan to‘liq kiriting.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: _phone,
        data: {'requested_role': _selectedRole},
      );
      if (!mounted) return;
      setState(() => _codeSent = true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Xatolik yuz berdi: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.trim().length < 4) {
      setState(() => _error = 'SMS kodni kiriting.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        phone: _phone,
        token: _codeController.text.trim(),
        type: OtpType.sms,
      );
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'requested_role': _selectedRole}),
      );
      if (!mounted) return;
      // AuthGate reacts to the newly created Supabase session.
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Xatolik yuz berdi: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.shopping_basket_outlined,
                      size: 64, color: Color(0xFF16834A)),
                  const SizedBox(height: 12),
                  const Text(
                    'BARAKA',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Davom etish uchun telefon raqamingiz bilan kiring',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  const Text('Kirish turini tanlang',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    value: 'customer',
                    groupValue: _selectedRole,
                    title: const Text('Xaridor'),
                    secondary: const Icon(Icons.shopping_bag_outlined),
                    onChanged: _codeSent
                        ? null
                        : (v) => setState(() => _selectedRole = v!),
                  ),
                  RadioListTile<String>(
                    value: 'courier',
                    groupValue: _selectedRole,
                    title: const Text('Kuryer'),
                    secondary: const Icon(Icons.delivery_dining),
                    onChanged: _codeSent
                        ? null
                        : (v) => setState(() => _selectedRole = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    enabled: !_codeSent,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon raqami',
                      hintText: '+998 90 123 45 67',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_codeSent) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'SMS tasdiqlash kodi',
                        prefixIcon: Icon(Icons.sms_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : (_codeSent ? _verifyCode : _sendCode),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16834A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_codeSent ? 'Kodni tasdiqlash' : 'SMS kod olish'),
                  ),
                  if (_codeSent)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                                _codeSent = false;
                                _codeController.clear();
                              }),
                      child: const Text('Raqamni o‘zgartirish'),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kuryer bo‘lib kirish so‘rovi yuboriladi. Kuryer huquqi admin tasdiqlagandan keyin ochiladi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
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

class CourierPendingScreen extends StatelessWidget {
  const CourierPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_top,
                  size: 56, color: Color(0xFF16834A)),
              const SizedBox(height: 16),
              const Text('So‘rovingiz qabul qilindi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Kuryer sifatida ishlash uchun admin tasdig‘ini kuting.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () async =>
                    Supabase.instance.client.auth.signOut(),
                child: const Text('Chiqish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourierHomeScreen extends StatelessWidget {
  const CourierHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BARAKA — Kuryer'),
        actions: [
          IconButton(
            tooltip: 'Chiqish',
            onPressed: () => Supabase.instance.client.auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Kuryer kabineti\nBuyurtmalarni qabul qilish bo‘limi keyingi bosqichda ulanadi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}
