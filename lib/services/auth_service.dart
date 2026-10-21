import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient client = Supabase.instance.client;

  User? get currentUser => client.auth.currentUser;

  Future<void> signUp({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'phone_number': phoneNumber.trim(),
      },
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Registration did not create a user.');
    }

    if (response.session != null) {
      await ensureProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
    }
  }

  Future<void> ensureProfile({
    String? fullName,
    String? phoneNumber,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('No signed-in user.');
    }

    final existing = await client
        .from('profiles')
        .select('id, full_name, phone_number, role')
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      // The project's schema uses profiles.id = auth.users.id. A database
      // trigger should create this row at sign-up; do not use auth_user_id.
      throw const AuthException(
        'Your parent profile is missing. Ask the administrator to run the Lenyora Supabase schema and create your profile.',
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    await ensureProfile();
  }

  Future<void> signOut() => client.auth.signOut();

  Future<Map<String, dynamic>> getMyProfile() async {
    await ensureProfile();
    final user = currentUser!;
    final row = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return Map<String, dynamic>.from(row);
  }
}
