import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }
        final user = authSnapshot.data;
        if (user == null) return const PhoneLoginScreen();

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }
            if (profileSnapshot.hasError) {
              return _ErrorScreen(message: 'Profilni yuklab bo‘lmadi: ${profileSnapshot.error}');
            }
            final profile = profileSnapshot.data?.data() ?? <String, dynamic>{};
            final role = profile['role'] as String? ?? 'customer';
            final requestedRole = profile['requestedRole'] as String?;
            if (role == 'admin') return const AdminHomePlaceholder();
            if (role == 'courier') return const CourierHomeScreen();
            if (requestedRole == 'courier') return const CourierPendingScreen();
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
  String? _verificationId;
  int? _resendToken;
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

  Future<void> _saveProfile(User user) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final existing = await ref.get();
    final data = <String, dynamic>{
      'uid': user.uid,
      'phoneNumber': user.phoneNumber ?? _phone,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!existing.exists) {
      data.addAll({
        'role': 'customer',
        'requestedRole': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else if ((existing.data()?['role'] as String? ?? 'customer') != 'admin') {
      data['requestedRole'] = _selectedRole;
    }
    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> _sendCode() async {
    if (_phone.length != 13 || !_phone.startsWith('+998') || int.tryParse(_phone.substring(4)) == null) {
      setState(() => _error = 'Telefon raqamini +998 bilan va undan keyin 9 ta raqam kiriting.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phone,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          try {
            final result = await FirebaseAuth.instance.signInWithCredential(credential);
            if (result.user != null) await _saveProfile(result.user!);
          } on FirebaseAuthException catch (e) {
            if (mounted) setState(() => _error = _friendlyError(e));
          } catch (e) {
            if (mounted) setState(() => _error = 'Profilni saqlashda xatolik: $e');
          }
        },
        verificationFailed: (e) {
          if (!mounted) return;
          setState(() {
            _busy = false;
            _error = _friendlyError(e);
          });
        },
        codeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _codeSent = true;
            _busy = false;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } catch (e) {
      if (mounted) setState(() => _error = 'Ulanishda xatolik: $e');
    } finally {
      if (mounted && !_codeSent) setState(() => _busy = false);
    }
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Telefon raqami noto‘g‘ri. +998 bilan qayta kiriting.';
      case 'too-many-requests':
        return 'Juda ko‘p urinish bo‘ldi. Birozdan keyin qayta urinib ko‘ring.';
      case 'quota-exceeded':
        return 'Firebase SMS limiti tugagan. Firebase limitlarini tekshiring.';
      case 'app-not-authorized':
        return 'Android ilova Firebase’da tasdiqlanmagan. SHA fingerprintlarni tekshirish kerak.';
      case 'network-request-failed':
        return 'Internet aloqasini tekshiring.';
      case 'invalid-verification-code':
        return 'SMS kodi noto‘g‘ri.';
      default:
        return e.message ?? 'Firebase xatoligi: ${e.code}';
    }
  }

  Future<void> _verifyCode() async {
    final id = _verificationId;
    final code = _codeController.text.trim();
    if (id == null || code.length < 6) {
      setState(() => _error = 'SMS orqali kelgan 6 xonali kodni kiriting.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: code,
      );
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      if (result.user != null) await _saveProfile(result.user!);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } catch (e) {
      if (mounted) setState(() => _error = 'Kirishda xatolik: $e');
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
                  const Icon(Icons.shopping_basket_outlined, size: 64, color: Color(0xFF16834A)),
                  const SizedBox(height: 12),
                  const Text('BARAKA', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Davom etish uchun telefon raqamingiz bilan kiring',
                    textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  const Text('Kirish turini tanlang', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    value: 'customer', groupValue: _selectedRole,
                    title: const Text('Xaridor'),
                    onChanged: _codeSent ? null : (v) => setState(() => _selectedRole = v!),
                  ),
                  RadioListTile<String>(
                    value: 'courier', groupValue: _selectedRole,
                    title: const Text('Kuryer'),
                    onChanged: _codeSent ? null : (v) => setState(() => _selectedRole = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController, enabled: !_codeSent,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: const InputDecoration(
                      labelText: 'Telefon raqami', hintText: '+998 90 123 45 67',
                      prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                  ),
                  if (_codeSent) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'SMS tasdiqlash kodi',
                        prefixIcon: Icon(Icons.sms_outlined), border: OutlineInputBorder()),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : (_codeSent ? _verifyCode : _sendCode),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16834A),
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _busy
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_codeSent ? 'Kodni tasdiqlash' : 'SMS kod olish'),
                  ),
                  if (_codeSent)
                    TextButton(
                      onPressed: _busy ? null : () => setState(() {
                        _codeSent = false;
                        _verificationId = null;
                        _codeController.clear();
                      }),
                      child: const Text('Raqamni o‘zgartirish'),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kuryer bo‘lib kirish so‘rovi yuboriladi. Kuryer huquqi admin tasdiqlagandan keyin ochiladi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
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
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.hourglass_top, size: 56, color: Color(0xFF16834A)),
        const SizedBox(height: 16),
        const Text('So‘rovingiz qabul qilindi',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Kuryer sifatida ishlash uchun admin tasdig‘ini kuting.',
          textAlign: TextAlign.center),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          child: const Text('Chiqish')),
      ]),
    )),
  );
}

class CourierHomeScreen extends StatelessWidget {
  const CourierHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('BARAKA — Kuryer'),
      actions: [IconButton(
        tooltip: 'Chiqish',
        onPressed: () => FirebaseAuth.instance.signOut(),
        icon: const Icon(Icons.logout))]),
    body: const Center(child: Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Kuryer kabineti\\nBuyurtmalarni qabul qilish bo‘limi keyingi bosqichda ulanadi.',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
    )),
  );
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          child: const Text('Qayta kirish')),
      ]),
    )),
  );
}

class AdminHomePlaceholder extends StatelessWidget {
  const AdminHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Admin paneli Firebase bilan ulanish bosqichida.')),
  );
}
