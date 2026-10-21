import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataService {
  final SupabaseClient db = Supabase.instance.client;
  String get uid => db.auth.currentUser!.id;

  Future<List<Map<String, dynamic>>> announcements() async => List<Map<String,dynamic>>.from(await db.from('announcements').select().eq('published', true).order('created_at', ascending: false));
  Future<List<Map<String, dynamic>>> subjects(String grade) async => List<Map<String,dynamic>>.from(await db.from('subjects').select().eq('grade', grade).eq('active', true).order('name'));
  Future<List<Map<String, dynamic>>> myApplications() async => List<Map<String,dynamic>>.from(await db.from('applications').select('*, learners(full_name, grade, age)').eq('parent_id', uid).order('submitted_at', ascending: false));

  Future<void> submitApplication({required String learnerName, required int age, required String grade, required String parentName, required String phone, required List<PlatformFile> files}) async {
    if (learnerName.trim().isEmpty || parentName.trim().isEmpty || phone.trim().isEmpty) throw Exception('Complete all required fields.');
    final learner = await db.from('learners').insert({'parent_id': uid, 'full_name': learnerName.trim(), 'age': age, 'grade': grade}).select('id').single();
    final app = await db.from('applications').insert({'parent_id': uid, 'learner_id': learner['id'], 'parent_notes': 'Parent: $parentName; Phone: $phone'}).select('id').single();
    for (final file in files) {
      final bytes = file.bytes;
      if (bytes == null) throw Exception('Could not read ${file.name}. Please select the file again.');
      if (bytes.length > 10 * 1024 * 1024) throw Exception('${file.name} exceeds the 10 MB limit.');
      final safeName = file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final path = '$uid/${app['id']}/${DateTime.now().microsecondsSinceEpoch}_$safeName';
      final contentType = file.extension?.toLowerCase() == 'pdf' ? 'application/pdf' : (file.extension?.toLowerCase() == 'png' ? 'image/png' : 'image/jpeg');
      await db.storage.from('application-documents').uploadBinary(path, bytes, fileOptions: FileOptions(contentType: contentType, upsert: false));
      final lower = file.name.toLowerCase();
      final type = lower.contains('birth') ? 'birth_certificate' : (lower.contains('id') ? 'parent_id' : 'other');
      await db.from('documents').insert({'application_id': app['id'], 'owner_id': uid, 'document_type': type, 'file_name': file.name, 'storage_path': path, 'content_type': contentType, 'size_bytes': bytes.length});
    }
  }
}
