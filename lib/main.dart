import 'package:flutter/material.dart';
import 'widgets/lenyora_page_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_gate.dart';
import 'supabase_config.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.url.contains('PASTE_') ||
      SupabaseConfig.anonKey.contains('PASTE_')) {
    runApp(const MissingSupabaseConfigApp());
    return;
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const LenyoraApp());
}

class LenyoraApp extends StatelessWidget {
  const LenyoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lenyora Primary School',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class MissingSupabaseConfigApp extends StatelessWidget {
  const MissingSupabaseConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: LenyoraPageHeader(title: 'Lenyora Primary School', subtitle: 'Parent Portal · 2027 Academic Intake'),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Supabase is not configured yet.\n\n'
              'Open lib/supabase_config.dart and paste your '
              'Supabase Project URL and public anon/publishable key.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
