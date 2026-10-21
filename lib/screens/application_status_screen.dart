import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'application_detail_screen.dart';
import 'application_wizard_screen.dart';
import 'package:intl/intl.dart';
import '../widgets/parent_bottom_navigation.dart';
import '../theme/app_theme.dart';

class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  State<ApplicationStatusScreen> createState() =>
      _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _applications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('Not logged in.');

      final profile = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .single();

      final rows = await _client
          .from('applications')
          .select(
            'id, application_number, submitted_at, status, admin_notes, '
            'learners(full_name, grade, date_of_birth)',
          )
          .eq('parent_id', profile['id'])
          .order('submitted_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _applications = List<Map<String, dynamic>>.from(rows);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load applications: $e')),
      );
    }
  }

  Future<void> _deleteApplication(Map<String, dynamic> application) async {
    final learner = application['learners'] is Map
        ? Map<String, dynamic>.from(application['learners'])
        : <String, dynamic>{};
    final learnerName = '${learner['full_name'] ?? 'this learner'}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete application?'),
        content: Text(
          'Delete the application for $learnerName? Uploaded documents for this application will also be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB4232F)),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('Please sign in again.');
      final applicationId = '${application['id']}';

      // Confirm ownership on the server before touching any related records.
      final owned = await _client
          .from('applications')
          .select('id')
          .eq('id', applicationId)
          .eq('parent_id', user.id)
          .maybeSingle();
      if (owned == null) {
        throw Exception('This application was not found under your account.');
      }

      // Remove uploaded objects first, while their metadata is still available.
      final docs = await _client
          .from('documents')
          .select('storage_path')
          .eq('application_id', applicationId)
          .eq('owner_id', user.id);
      final paths = <String>[];
      for (final doc in docs) {
        final path = '${doc['storage_path'] ?? ''}'.trim();
        if (path.isNotEmpty) paths.add(path);
      }
      if (paths.isNotEmpty) {
        await _client.storage.from('application-documents').remove(paths);
      }

      // Delete document metadata explicitly; do not depend on cascade settings.
      await _client
          .from('documents')
          .delete()
          .eq('application_id', applicationId)
          .eq('owner_id', user.id);

      // Requires the parent-delete RLS policy in 03_parent_application_delete.sql.
      await _client
          .from('applications')
          .delete()
          .eq('id', applicationId)
          .eq('parent_id', user.id);

      // Verify the row is actually gone; PostgREST can return no error when RLS
      // silently filters a delete that affects zero rows.
      final stillExists = await _client
          .from('applications')
          .select('id')
          .eq('id', applicationId)
          .maybeSingle();
      if (stillExists != null) {
        throw Exception(
          'Supabase did not delete the application. Apply the included SQL migration and check your RLS policies.',
        );
      }

      if (!mounted) return;
      setState(() {
        _applications.removeWhere((item) => item['id'] == application['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application and uploaded documents deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete application: $e')),
      );
      // Refresh to keep the visible list consistent with the database.
      await _load();
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF711D28),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicationWizardScreen())),
                      icon: const Icon(Icons.add_circle_outline, size: 24),
                      label: const Text('Start Your Application', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_applications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text('No applications submitted yet.'),
                      ),
                    ),
                  ..._applications.map((a) {
                    final learner = Map<String, dynamic>.from(a['learners'] ?? {});
                    final status = '${a['status'] ?? 'Pending'}';
                    final color = _statusColor(status);
                    String submitted = 'Date not available';
                    try { submitted = DateFormat('dd MMM yyyy').format(DateTime.parse('${a['submitted_at']}').toLocal()); } catch (_) {}
                    final grade = '${learner['grade'] ?? 'Grade'}';
                    final normalizedGrade = grade.toLowerCase().startsWith('grade') ? grade : 'Grade $grade';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 5, offset: Offset(0, 2))],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ApplicationDetailScreen(application: a))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('$normalizedGrade Application', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
                                const SizedBox(height: 5),
                                Text('Learner: ${learner['full_name'] ?? 'Learner'}', style: const TextStyle(fontSize: 14, color: Color(0xFF34445B))),
                              ])),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
                                decoration: BoxDecoration(color: color.withOpacity(.13), borderRadius: BorderRadius.circular(30), border: Border.all(color: color.withOpacity(.55))),
                                child: Text(status[0].toUpperCase() + status.substring(1).toLowerCase(), style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                              ),
                              const SizedBox(width: 4),
                            ]),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFE8EDF4)),
                            const SizedBox(height: 11),
                            Row(children: [
                              Expanded(child: Text('Submitted: $submitted', style: const TextStyle(fontSize: 14, color: Color(0xFF34445B)))),
                              const SizedBox(width: 8),
                              const Flexible(child: Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                                Flexible(child: Text('View Status & Details', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: Color(0xFF7A0019), fontWeight: FontWeight.w500))),
                                SizedBox(width: 4), Icon(Icons.chevron_right, size: 20, color: Color(0xFF7A0019)),
                              ])),
                            ]),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 3),
    );
  }
}
