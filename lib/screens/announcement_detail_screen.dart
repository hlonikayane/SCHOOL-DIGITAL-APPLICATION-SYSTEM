import 'package:flutter/material.dart';
import '../widgets/parent_bottom_navigation.dart';
import '../widgets/lenyora_page_header.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final Map<String, dynamic> announcement;
  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final title = '${announcement['title'] ?? 'Official Circular'}';
    final body = '${announcement['body'] ?? announcement['description'] ?? ''}';
    final rawDate = announcement['starts_at'] ?? announcement['published_at'];
    String date = 'Date not specified';
    if (rawDate != null) {
      try { date = DateFormat('dd MMM yyyy').format(DateTime.parse('$rawDate').toLocal()); } catch (_) { date = '$rawDate'; }
    }
    return Scaffold(
      appBar: LenyoraPageHeader(title: 'Official Circular', subtitle: 'School Notices & Dates'),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFFF0F5FA), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF2463F5), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.info_outline, color: Colors.white, size: 30)),
          const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19)), const SizedBox(height: 8), Text('Published: $date  ·  ${announcement['category'] ?? 'School'}', style: const TextStyle(color: Color(0xFF60738C), fontSize: 13))]))
        ])),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFFF4F7FA), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(body.isEmpty ? 'Please contact the school office for more information about this notice.' : body, style: const TextStyle(fontSize: 17, height: 1.75, color: Color(0xFF26364B))),
          const SizedBox(height: 24), const Divider(), const SizedBox(height: 16), const Text('• Lenyora Primary School', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), const Text('Office of the Administration & Governance Body', style: TextStyle(color: Color(0xFF60738C))),
        ])),
        const SizedBox(height: 20), OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('←  Back to All Announcements')),
      ]),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 1),
    );
  }
}
