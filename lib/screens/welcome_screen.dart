import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF8F3438), Color(0xFF672124)])),
      child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(24, 30, 24, 28), child: Column(
        children: [
          const Spacer(flex: 2),
          Container(width: 142, height: 142, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(34)), child: const Icon(Icons.school_rounded, size: 88, color: AppTheme.maroon)),
          const SizedBox(height: 24),
          const Text('Lenyora Primary School', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          const Text('Digital Application System', style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          const Text('THUTO E TIMA LENYORA', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
          const Spacer(flex: 3),
          SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.maroon, minimumSize: const Size.fromHeight(52)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Get Started'))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white), minimumSize: const Size.fromHeight(52)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('Login'))),
        ],
      ))),
    ),
  );
}
