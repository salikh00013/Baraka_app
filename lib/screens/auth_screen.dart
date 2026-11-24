import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const _LoadingScreen();
      final user = snapshot.data;
      if (user == null) return const GoogleLoginScreen();
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) return const _LoadingScreen();
          if (profileSnapshot.hasError) return _ErrorScreen(message: 'Profilni yuklab bo‘lmadi: ${profileSnapshot.error}');
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

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});
  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}
class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  String _selectedRole = 'customer';
  bool _busy = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() { _busy = true; _error = null; });
    try {
      final selected = await GoogleSignIn().signIn();
      if (selected == null) { if (mounted) setState(() => _busy = false); return; }
      final tokens = await selected.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: tokens.accessToken, idToken: tokens.idToken);
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = result.user;
      if (user != null) {
        final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final existing = await ref.get();
        final data = <String, dynamic>{'uid': user.uid,'email': user.email,'displayName': user.displayName,'photoURL': user.photoUrl,'updatedAt': FieldValue.serverTimestamp()};
        if (!existing.exists) data.addAll({'role':'customer','requestedRole':_selectedRole,'createdAt':FieldValue.serverTimestamp()});
        else if ((existing.data()?['role'] as String? ?? 'customer') != 'admin') data['requestedRole'] = _selectedRole;
        await ref.set(data, SetOptions(merge: true));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Firebase xatoligi: ${e.code}');
    } catch (e) {
      if (mounted) setState(() => _error = 'Kirishda xatolik: $e');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth:420),child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,children:[
        const Icon(Icons.shopping_basket_outlined,size:64,color:Color(0xFF16834A)),const SizedBox(height:12),
        const Text('BARAKA',textAlign:TextAlign.center,style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),const SizedBox(height:8),
        const Text('Davom etish uchun Google hisobingiz bilan kiring',textAlign:TextAlign.center),const SizedBox(height:28),
        const Text('Kirish turini tanlang',style:TextStyle(fontWeight:FontWeight.w700)),
        RadioListTile<String>(value:'customer',groupValue:_selectedRole,title:const Text('Xaridor'),onChanged:_busy?null:(v)=>setState(()=>_selectedRole=v!)),
        RadioListTile<String>(value:'courier',groupValue:_selectedRole,title:const Text('Kuryer'),onChanged:_busy?null:(v)=>setState(()=>_selectedRole=v!)),
        const SizedBox(height:16),
        if(_error!=null) Padding(padding:const EdgeInsets.only(bottom:12),child:Text(_error!,style:const TextStyle(color:Colors.red),textAlign:TextAlign.center)),
        FilledButton.icon(onPressed:_busy?null:_signIn,icon:_busy?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)):const Icon(Icons.login),
          label:Text(_busy?'Kuting...':'Google orqali kirish'),style:FilledButton.styleFrom(backgroundColor:const Color(0xFF16834A),padding:const EdgeInsets.symmetric(vertical:16))),
        const SizedBox(height:16),const Text('Kuryer bo‘lib kirish so‘rovi yuboriladi. Kuryer huquqi admin tasdiqlagandan keyin ochiladi.',textAlign:TextAlign.center,style:TextStyle(fontSize:12,color:Colors.black54)),
      ]))))),
  );
}

class CourierPendingScreen extends StatelessWidget {
  const CourierPendingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body:Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[
    const Icon(Icons.hourglass_top,size:56,color:Color(0xFF16834A)),const SizedBox(height:16),const Text('So‘rovingiz qabul qilindi',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
    const SizedBox(height:8),const Text('Kuryer sifatida ishlash uchun admin tasdig‘ini kuting.',textAlign:TextAlign.center),const SizedBox(height:20),
    OutlinedButton(onPressed:()=>FirebaseAuth.instance.signOut(),child:const Text('Chiqish')),
  ]))));
}
class CourierHomeScreen extends StatelessWidget {
  const CourierHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar:AppBar(title:const Text('BARAKA — Kuryer'),actions:[IconButton(tooltip:'Chiqish',onPressed:()=>FirebaseAuth.instance.signOut(),icon:const Icon(Icons.logout))]),
    body:const Center(child:Padding(padding:EdgeInsets.all(24),child:Text('Kuryer kabineti\nBuyurtmalarni qabul qilish bo‘limi keyingi bosqichda ulanadi.',textAlign:TextAlign.center,style:TextStyle(fontSize:18)))));
}
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context)=>const Scaffold(body:Center(child:CircularProgressIndicator()));
}
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});
  final String message;
  @override
  Widget build(BuildContext context)=>Scaffold(body:Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[
    Text(message,textAlign:TextAlign.center),const SizedBox(height:16),FilledButton(onPressed:()=>FirebaseAuth.instance.signOut(),child:const Text('Qayta kirish')),
  ]))));
}
class AdminHomePlaceholder extends StatelessWidget {
  const AdminHomePlaceholder({super.key});
  @override
  Widget build(BuildContext context)=>const Scaffold(body:Center(child:Text('Admin paneli Firebase bilan ulanish bosqichida.')));
}
