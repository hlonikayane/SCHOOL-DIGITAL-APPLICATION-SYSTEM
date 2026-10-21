import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class EmailSentScreen extends StatelessWidget {
  final String email;
  const EmailSentScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LenyoraPageHeader(title: 'Email Sent!', subtitle: 'Password reset instructions'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: AppTheme.paleRose,
                child: Icon(Icons.mark_email_read_outlined, size: 46, color: AppTheme.maroon),
              ),
              const SizedBox(height: 20),
              const Text('Check your email', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('If an account exists for $email, a password reset link has been sent. Check your inbox and spam folder.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                ),
                child: const Text('Back to Login'),
              ),
              const SizedBox(height: 10),
              const Text('If you do not receive an email, contact the school for support.', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
