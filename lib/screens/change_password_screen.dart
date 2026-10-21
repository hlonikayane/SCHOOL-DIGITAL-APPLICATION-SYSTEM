import 'package:flutter/material.dart';
import '../widgets/parent_bottom_navigation.dart';
import '../widgets/lenyora_page_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;
  @override void dispose() { _password.dispose(); _confirm.dispose(); super.dispose(); }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(UserAttributes(password: _password.text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your password has been updated.')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update password: $e')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: LenyoraPageHeader(title: 'Change Password', subtitle: 'Keep your account secure'),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 12),
      const Icon(Icons.security, size: 64, color: AppTheme.maroon),
      const SizedBox(height: 10),
      const Text('Keep your account secure', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('Choose a strong password that you do not use on other websites.', textAlign: TextAlign.center),
      const SizedBox(height: 24),
      Form(key: _formKey, child: Column(children: [
        TextFormField(controller: _password, obscureText: _hidePassword, decoration: InputDecoration(labelText: 'New Password *', suffixIcon: IconButton(icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _hidePassword = !_hidePassword)),), validator: (v) {
          if (v == null || v.length < 8) return 'Use at least 8 characters';
          if (!RegExp(r'[A-Z]').hasMatch(v) || !RegExp(r'[a-z]').hasMatch(v) || !RegExp(r'[0-9]').hasMatch(v)) return 'Include uppercase, lowercase and a number';
          if (!RegExp(r'[^A-Za-z0-9]').hasMatch(v)) return 'Include at least one special character';
          return null;
        }),
        const SizedBox(height: 14),
        TextFormField(controller: _confirm, obscureText: _hideConfirm, decoration: InputDecoration(labelText: 'Confirm New Password *', suffixIcon: IconButton(icon: Icon(_hideConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _hideConfirm = !_hideConfirm))), validator: (v) => v != _password.text ? 'Passwords do not match' : null),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.paleRose, borderRadius: BorderRadius.circular(10)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Password requirements', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 6), Text('• At least 8 characters\n• Include uppercase and lowercase letters\n• Include a number\n• Avoid using your name or email')]),),
        const SizedBox(height: 22),
        ElevatedButton(onPressed: _saving ? null : _update, child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Password')),
      ])),
    ]),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 4),
    );
}
