import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/parent_bottom_navigation.dart';
import 'application_status_screen.dart';
import 'change_password_screen.dart';
import 'help_support_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String _role = 'parent';
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final p = await AuthService().getMyProfile(); _name.text = '${p['full_name'] ?? ''}'; _phone.text = '${p['phone_number'] ?? ''}'; _role = '${p['role'] ?? 'parent'}'; }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load profile: $e'))); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  Future<void> _save() async {
    setState(() => _saving = true);
    try { final user = Supabase.instance.client.auth.currentUser!; await Supabase.instance.client.from('profiles').update({'full_name': _name.text.trim(), 'phone_number': _phone.text.trim()}).eq('id', user.id); if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully.'))); setState(() {}); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save profile: $e'))); }
    finally { if (mounted) setState(() => _saving = false); }
  }
  @override void dispose() { _name.dispose(); _phone.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    return Scaffold(appBar: LenyoraPageHeader(title: 'My Profile', subtitle: 'Manage your account'), body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(18), children: [
      Container(padding: const EdgeInsets.fromLTRB(18, 24, 18, 22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFDDE5EF)), boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3))]), child: Column(children: [Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF7FAFC), border: Border.all(color: const Color(0xFF111827), width: 2)), child: const Icon(Icons.person_outline, size: 58, color: Color(0xFF111827))), const SizedBox(height: 16), Text(_name.text.trim().isEmpty ? 'Parent / Guardian' : _name.text.trim().toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 7), Text(email, textAlign: TextAlign.center, style: const TextStyle(decoration: TextDecoration.underline, color: Color(0xFF34445B))), const SizedBox(height: 5), Text(_phone.text, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text('Account type: $_role', style: const TextStyle(color: Color(0xFF8CA0B9), fontSize: 12))])),
      const SizedBox(height: 22),
      _ProfileAction(icon: Icons.groups_2_outlined, title: 'My Applications', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicationStatusScreen()))),
      _ProfileAction(icon: Icons.lock_outline, title: 'Change Password', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
      _ProfileAction(icon: Icons.help_outline, title: 'Help & Support', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
      const SizedBox(height: 10),
      ExpansionTile(leading: const CircleAvatar(backgroundColor: Color(0xFFF0F4F8), child: Icon(Icons.edit_outlined, color: Color(0xFF111827))), title: const Text('Edit Profile Details', style: TextStyle(fontWeight: FontWeight.bold)), childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16), children: [AppTextField(label: 'Full Name', controller: _name), AppTextField(label: 'Phone Number', controller: _phone, keyboardType: TextInputType.phone), ElevatedButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving...' : 'Save Profile'))]),
      const SizedBox(height: 10),
      Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border)), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.logout, color: Color(0xFFFF1744))), title: const Text('Log Out', style: TextStyle(color: Color(0xFFFF1744), fontWeight: FontWeight.bold, fontSize: 17)), onTap: () async { try { await AuthService().signOut(); if (!context.mounted) return; Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e'))); } })),
      const SizedBox(height: 18),
    ]), bottomNavigationBar: const ParentBottomNavigation(currentIndex: 4));
  }
}
class _ProfileAction extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap;
  const _ProfileAction({required this.icon, required this.title, required this.onTap});
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border), boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 2))]), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7), leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFF0F4F8), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF111827))), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), trailing: const Icon(Icons.chevron_right, color: Color(0xFF8CA0B9)), onTap: onTap));
}
