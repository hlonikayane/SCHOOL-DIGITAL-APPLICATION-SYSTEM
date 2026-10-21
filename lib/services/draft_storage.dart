import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/application_draft.dart';

/// Device-local, account-scoped draft storage. Drafts survive closing the app
/// and signing out/in on the same device. Submitted applications are separate.
class DraftStorage {
  static String _key(String userId) => 'lenyora_application_draft_$userId';

  static Future<void> save(String userId, ApplicationDraft draft) async {
    draft.updatedAt = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userId), jsonEncode(draft.toJson()));
  }

  static Future<ApplicationDraft?> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return ApplicationDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId));
  }
}
