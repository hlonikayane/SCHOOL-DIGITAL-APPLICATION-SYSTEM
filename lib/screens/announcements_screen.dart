import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/parent_bottom_navigation.dart';
import 'announcement_detail_screen.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});
  @override State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}
class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _client = Supabase.instance.client;
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String _filter = 'All';
  static const _filters = ['All', 'Urgent', 'Admissions', 'Academic', 'Events'];

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final rows = await _client.from('announcements').select().eq('published', true).order('starts_at', ascending: false);
      if (!mounted) return;
      setState(() { _items = List<Map<String, dynamic>>.from(rows); _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _items = []; _loading = false; });
    }
  }
  String _date(dynamic value) {
    if (value == null) return 'Date not specified';
    try { return DateFormat('dd MMM yyyy').format(DateTime.parse('$value').toLocal()); } catch (_) { return '$value'; }
  }
  List<Map<String, dynamic>> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return _items.where((a) {
      final title = '${a['title'] ?? ''}'; final body = '${a['body'] ?? ''}';
      final category = '${a['category'] ?? a['type'] ?? 'General'}';
      final matchesQuery = q.isEmpty || title.toLowerCase().contains(q) || body.toLowerCase().contains(q);
      final matchesFilter = _filter == 'All' || category.toLowerCase().contains(_filter.toLowerCase()) || (_filter == 'Urgent' && (a['urgent'] == true || title.toLowerCase().contains('urgent')));
      return matchesQuery && matchesFilter;
    }).toList();
  }
  @override void dispose() { _search.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final rows = _filtered;
    return Scaffold(
      appBar: LenyoraPageHeader(title: 'Announcements', subtitle: 'School Notices & Dates'),
      body: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 24), children: [
        TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'Search Announcements...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: const Color(0xFFF0F5FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
        const SizedBox(height: 14),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _filters.map((f) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(f), selected: _filter == f, onSelected: (_) => setState(() => _filter = f), selectedColor: AppTheme.maroon, labelStyle: TextStyle(color: _filter == f ? Colors.white : const Color(0xFF33445B), fontWeight: FontWeight.w600), backgroundColor: const Color(0xFFF0F5FA), side: BorderSide.none))).toList())),
        const SizedBox(height: 12),
        if (rows.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 70), child: Center(child: Text('No announcements match your search.'))),
        ...rows.map((a) {
          final title = '${a['title'] ?? 'School announcement'}';
          final body = '${a['body'] ?? ''}'.trim();
          final announcementDate = _date(a['starts_at']);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
              boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 5, offset: Offset(0, 2))],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnnouncementDetailScreen(announcement: a))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 18, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(color: const Color(0xFF2F80FF), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.info_outline, color: Colors.white, size: 27),
                    ),
                    const SizedBox(width: 17),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, height: 1.25, color: Color(0xFF101828))),
                          if (body.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, height: 1.35, color: Color(0xFF405675))),
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
                                Text(announcementDate, style: const TextStyle(fontSize: 12, color: Color(0xFF60738C))),
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
        }),
      ])),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 1),
    );
  }
}
