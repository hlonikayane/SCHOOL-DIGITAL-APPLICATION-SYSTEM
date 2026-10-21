import 'package:flutter/material.dart';
import 'announcements_screen.dart';
import 'application_status_screen.dart';
import 'application_wizard_screen.dart';
import 'subjects_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/parent_bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String> _name() async {
    try {
      final p = await AuthService().getMyProfile();
      return (p['full_name'] ?? 'Parent').toString();
    } catch (_) {
      return 'Parent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder<String>(
              future: _name(),
              builder: (context, snapshot) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  height: 176,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppTheme.maroon,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: AppTheme.maroon.withOpacity(.18), blurRadius: 18, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/lenyora-learners.jpg', fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                      Container(color: AppTheme.maroon.withOpacity(.78)),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(30)),
                              child: const Text('PARENT PORTAL · 2027 ACADEMIC INTAKE', style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700))),
                            const SizedBox(height: 12),
                            Text('Hello, ${snapshot.data ?? 'Parent'}!',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23)),
                            const SizedBox(height: 6),
                            const Text('Welcome to Lenyora Primary School Digital Application System',
                              style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _HomeCard(
                          color: const Color(0xFFFFF08A),
                          icon: Icons.campaign,
                          title: 'Announcements',
                          subtitle: 'Latest school news',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AnnouncementsScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HomeCard(
                          color: const Color(0xFFB8F5D0),
                          icon: Icons.menu_book,
                          title: 'Subjects',
                          subtitle: 'Subjects by grade',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SubjectsScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _HomeCard(
                          color: const Color(0xFF9AF1E4),
                          icon: Icons.description,
                          title: 'Applications',
                          subtitle: 'Apply for your child',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ApplicationWizardScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HomeCard(
                          color: const Color(0xFFC8D4FF),
                          icon: Icons.assignment,
                          title: 'Profile',
                          subtitle: 'Track status',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ApplicationStatusScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward), label: const Text('Start Your Application'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54), backgroundColor: AppTheme.maroon, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicationWizardScreen())),
                  )),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('YOUR APPLICATION STATUS', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.darkMaroon)),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicationStatusScreen())), child: const Text('View All')),
                  ]),
                  const _ApplicationPreview(),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('LATEST ANNOUNCEMENTS', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.darkMaroon)),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen())), child: const Text('View All')),
                  ]),
                  const _LatestAnnouncementPreview(),
                  const SizedBox(height: 12),
                  Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFD45B))), child: const Row(children: [Icon(Icons.schedule, color: Color(0xFFB45309)), SizedBox(width: 10), Expanded(child: Text('2027 Academic Intake: Online applications close on 31 October 2026.', style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w600)))])),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 0),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 122,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border.withOpacity(.75)),
          boxShadow: [BoxShadow(color: AppTheme.maroon.withOpacity(.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: AppTheme.maroon),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.darkMaroon),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }
}


class _ApplicationPreview extends StatefulWidget {
  const _ApplicationPreview();
  @override
  State<_ApplicationPreview> createState() => _ApplicationPreviewState();
}

class _ApplicationPreviewState extends State<_ApplicationPreview> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final rows = await client
          .from('applications')
          .select('id, application_number, submitted_at, status, learners(full_name, grade)')
          .eq('parent_id', user.id)
          .order('submitted_at', ascending: false)
          .limit(2);
      if (!mounted) return;
      setState(() {
        _items = List<Map<String, dynamic>>.from(rows);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'Date pending';
    final parsed = DateTime.tryParse(value.toString())?.toLocal();
    if (parsed == null) return value.toString();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  String _formatGrade(dynamic value) {
    final grade = (value ?? '').toString().trim();
    if (grade.isEmpty) return 'Grade not specified';
    return grade.toLowerCase().startsWith('grade') ? grade : 'Grade $grade';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDCE5F0)),
        ),
        child: const Text(
          'No submitted applications yet. Start an application to track its progress.',
          style: TextStyle(color: Color(0xFF60738C)),
        ),
      );
    }

    return Column(
      children: _items.map((a) {
        final learner = a['learners'] is Map
            ? Map<String, dynamic>.from(a['learners'])
            : <String, dynamic>{};
        final status = '${a['status'] ?? 'Pending'}';
        final normalized = status.toLowerCase();
        final approved = ['approved', 'accepted'].contains(normalized);
        final rejected = normalized == 'rejected';
        final color = approved
            ? const Color(0xFF009C72)
            : rejected
                ? const Color(0xFFB4232F)
                : const Color(0xFFB45309);
        final paleColor = approved
            ? const Color(0xFFD7FBEA)
            : rejected
                ? const Color(0xFFFCE7E7)
                : const Color(0xFFFFF3C4);
        final statusIcon = approved
            ? Icons.check_circle_outline
            : rejected
                ? Icons.cancel_outlined
                : Icons.access_time;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFDCE5F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080B2545),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ApplicationStatusScreen(),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 2,
                            children: [
                              Text(
                                '${learner['full_name'] ?? 'Learner'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Color(0xFF14243A),
                                ),
                              ),
                              Text(
                                '(${_formatGrade(learner['grade'])})',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF60738C),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Submitted: ${_formatDate(a['submitted_at'])}  ·  Ref: ${a['application_number'] ?? 'Pending'}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: Color(0xFF526B8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: paleColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: color.withOpacity(.55)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: color),
                          const SizedBox(width: 5),
                          Text(
                            status.isEmpty ? 'Pending' : '${status[0].toUpperCase()}${status.substring(1)}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Icon(Icons.chevron_right, color: Color(0xFF8CA0B9), size: 22),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LatestAnnouncementPreview extends StatefulWidget {
  const _LatestAnnouncementPreview();
  @override State<_LatestAnnouncementPreview> createState() => _LatestAnnouncementPreviewState();
}

class _LatestAnnouncementPreviewState extends State<_LatestAnnouncementPreview> {
  String _title = 'Welcome to Lenyora Primary School';
  String _description = 'Check announcements regularly for application dates, school events and important notices.';
  String _date = 'Date pending';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await Supabase.instance.client
          .from('announcements')
          .select('title, body, starts_at')
          .eq('published', true)
          .order('starts_at', ascending: false)
          .limit(1);
      if (!mounted || rows.isEmpty) return;
      final announcement = rows.first;
      final rawDate = announcement['starts_at']?.toString();
      var formattedDate = 'Date pending';
      if (rawDate != null && rawDate.isNotEmpty) {
        final parsed = DateTime.tryParse(rawDate)?.toLocal();
        if (parsed != null) {
          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          formattedDate = '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
        }
      }
      setState(() {
        _title = '${announcement['title'] ?? _title}';
        _description = '${announcement['body'] ?? _description}';
        _date = formattedDate;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 18, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F80FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.white, size: 27),
                ),
                const SizedBox(width: 17),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, height: 1.25, color: Color(0xFF101828))),
                      if (_description.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(_description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, height: 1.35, color: Color(0xFF405675))),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 13,
                        runSpacing: 6,
                        children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.calendar_today_outlined, size: 15, color: Color(0xFF60738C)),
                            const SizedBox(width: 6),
                            Text(_date, style: const TextStyle(fontSize: 12, color: Color(0xFF60738C))),
                          ]),
                          const Text('·', style: TextStyle(color: Color(0xFF60738C), fontSize: 13)),
                          const Text('Read full notice →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF8E1728))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
