import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/application_draft.dart';
import '../widgets/app_button.dart';
import 'confirmation_screen.dart';
import '../widgets/parent_bottom_navigation.dart';

class DocumentsScreen extends StatefulWidget {
  final ApplicationDraft draft;
  const DocumentsScreen({super.key, required this.draft});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _client = Supabase.instance.client;
  bool _submitting = false;

  final requiredDocs = const [
    'birth_certificate',
    'parent_id',
    'proof_of_residence',
  ];

  final labels = const {
    'birth_certificate': 'Certified Copy of Birth Certificate',
    'parent_id': 'Certified Copy of ID/Passport',
    'proof_of_residence': 'Proof of Residence',
    'latest_report': 'Latest Report (if any)',
    'proof_of_transfer': 'Proof of Transfer (if any)',
  };

  Future<void> _pick(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (!mounted || result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final extension = (file.extension ?? '').toLowerCase();

      if (!const ['pdf', 'jpg', 'jpeg', 'png'].contains(extension)) {
        throw Exception('Choose a PDF, JPG or PNG file.');
      }

      // file_picker can provide bytes or a path depending on platform/version.
      // Keep the selected file if either is available; read bytes at submission.
      if ((file.bytes == null || file.bytes!.isEmpty) &&
          (file.path == null || file.path!.isEmpty)) {
        throw Exception(
          'The file was selected, but Flutter could not access its contents. '
          'Please try choosing it again.',
        );
      }

      widget.draft.documentPaths[type] = file.name;
      setState(() {
        _selectedFiles[type] = file;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected: ${file.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not select document: $e'),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  final Map<String, PlatformFile> _selectedFiles = {};

  Future<void> _submit() async {
    for (final type in requiredDocs) {
      if (!_selectedFiles.containsKey(type)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please choose ${labels[type]}.')),
        );
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('You are not logged in.');

      // Make sure the parent profile exists.
      final profile = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .single();
      final parentId = profile['id'];

      final d = widget.draft;

      final learner = await _client
          .from('learners')
          .insert({
            'parent_id': parentId,
            'full_name': d.learnerFullName,
            'age': int.tryParse(d.age) ?? 0,
            'grade': d.grade,
            'date_of_birth': _dateOrNull(d.dateOfBirth)?.toIso8601String().split('T').first,
          })
          .select('id')
          .single();

      final learnerId = learner['id'];

      final application = await _client
          .from('applications')
          .insert({
            'parent_id': parentId,
            'learner_id': learnerId,
            'parent_notes': [
              'Parent: ${d.parentFullName}',
              'Phone: ${d.parentPhone}',
              'Email: ${d.parentEmail}',
              'ID/Passport: ${d.parentIdNumber}',
              'Relationship: ${d.relationship}',
              'Address: ${d.parentAddress}',
              if (d.gender.trim().isNotEmpty) 'Learner gender: ${d.gender}',
              if (d.currentSchool.trim().isNotEmpty) 'Current school: ${d.currentSchool}',
              if (d.homeLanguage.trim().isNotEmpty) 'Home language: ${d.homeLanguage}',
              if (d.learnerAddress.trim().isNotEmpty) 'Learner address: ${d.learnerAddress}',
              if (d.medicalCondition.trim().isNotEmpty) 'Medical condition: ${d.medicalCondition}',
              if (d.doctorNameContact.trim().isNotEmpty) 'Doctor contact: ${d.doctorNameContact}',
              if (d.medicalAidNameNumber.trim().isNotEmpty) 'Medical aid: ${d.medicalAidNameNumber}',
              if (d.emergencyContactName.trim().isNotEmpty) 'Emergency contact: ${d.emergencyContactName}',
              if (d.emergencyContactPhone.trim().isNotEmpty) 'Emergency phone: ${d.emergencyContactPhone}',
              if (d.disability.trim().isNotEmpty) 'Disability/accommodation: ${d.disability}',
            ].where((value) => value.trim().isNotEmpty).join('\n'),
          })
          .select('id')
          .single();

      final applicationId = application['id'];

      for (final entry in _selectedFiles.entries) {
        final type = entry.key;
        final file = entry.value;
        final extension = (file.extension ?? 'bin').toLowerCase();
        final storagePath =
            '${user.id}/$applicationId/$type.$extension';

        Uint8List? bytes = file.bytes;
        // `withData: true` is set by the picker so this works on Chrome as well
        // as native platforms without importing dart:io into the web build.
        if (bytes == null || bytes.isEmpty) {
          throw Exception(
            'Could not read ${file.name}. Please choose the file again.',
          );
        }
        await _client.storage
            .from('application-documents')
            .uploadBinary(
              storagePath,
              bytes,
              fileOptions: FileOptions(
                contentType: _contentType(extension),
                upsert: true,
              ),
            );

        await _client.from('documents').insert({
          'application_id': applicationId,
          'owner_id': parentId,
          'document_type': const ['birth_certificate', 'parent_id', 'proof_of_residence'].contains(type) ? type : 'other',
          'file_name': file.name,
          'storage_path': storagePath,
          'content_type': _contentType(extension),
          'size_bytes': bytes.length,
        });
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationScreen(
            learnerName: d.learnerFullName,
            grade: d.grade,
            applicationId: applicationId.toString(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  DateTime? _dateOrNull(String value) {
    if (value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  String _contentType(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    final allDocs = [
      'birth_certificate',
      'parent_id',
      'proof_of_residence',
      'latest_report',
      'proof_of_transfer',
    ];

    return Scaffold(
      appBar: LenyoraPageHeader(title: 'Application - 4 of 4', subtitle: 'Learner Admission Form · 2027 Cycle'),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text(
            '4. Documents',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Birth certificate, parent ID/passport and proof of residence are required.',
          ),
          const SizedBox(height: 12),
          ...allDocs.map(
            (type) => Card(
              child: ListTile(
                leading: const Icon(Icons.attach_file),
                title: Text(labels[type]!),
                subtitle: _selectedFiles[type] == null
                    ? const Text('No file selected')
                    : Text(
                        'Selected: ${_selectedFiles[type]!.name}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                trailing: TextButton(
                  onPressed: _submitting ? null : () => _pick(type),
                  child: const Text('Choose File'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'SUBMIT APPLICATION',
            onPressed: _submit,
            loading: _submitting,
          ),
        ],
      ),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 3),
    );
  }
}
