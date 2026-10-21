import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService().signUp(
        fullName: _name.text,
        phoneNumber: _phone.text,
        email: _email.text,
        password: _password.text,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created. If email confirmation is enabled, verify your email before logging in.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LenyoraPageHeader(title: 'Create Account', subtitle: 'Parent Portal · 2027 Academic Intake'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Icon(Icons.person_add_alt_1, size: 70, color: Colors.blue),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Parent/Guardian Full Name',
              controller: _name,
              validator: requiredField,
            ),
            AppTextField(
              label: 'Parent/Guardian Contact Number',
              controller: _phone,
              keyboardType: TextInputType.phone,
              validator: requiredField,
            ),
            AppTextField(
              label: 'Parent/Guardian Email Address',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            AppTextField(
              label: 'Create a Password',
              controller: _password,
              obscureText: true,
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
            ),
            AppTextField(
              label: 'Confirm Password',
              controller: _confirm,
              obscureText: true,
              validator: requiredField,
            ),
            AppButton(
              text: 'Create Account',
              onPressed: _register,
              loading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}

String? requiredField(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required';
  return null;
}
