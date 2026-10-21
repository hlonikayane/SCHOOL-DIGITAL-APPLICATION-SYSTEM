import 'package:flutter/material.dart';
import '../widgets/parent_bottom_navigation.dart';
import '../widgets/lenyora_page_header.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> application;
  const ApplicationDetailScreen({super.key, required this.application});
  @override State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  Map<String, dynamic> _school = {
    'school_name': 'Lenyora Primary School', 'motto': 'THUTO E TIMA LENYORA',
    'principal': 'Mrs. M. T. Molefe (Principal)', 'phone': '057 355 6974',
    'email': 'info@lenyoraschool.co.za', 'address': '8152 Mmatsa Street, Motsetsehabong, Welkom, 9463',
    'intake': '2027 Academic Intake', 'deadline': '31 October 2026', 'theme': 'heritage'
  };
  @override void initState() { super.initState(); _loadSchoolSettings(); }
  Future<void> _loadSchoolSettings() async {
    try {
      final row = await Supabase.instance.client.from('school_settings').select().eq('id', true).maybeSingle();
      if (row != null && mounted) setState(() => _school = {..._school, ...Map<String, dynamic>.from(row)});
    } catch (_) { /* Keep the safe school identity defaults if migration has not been applied yet. */ }
  }
  @override Widget build(BuildContext context) {
    final application = widget.application;
    final learner = application['learners'] is Map ? Map<String,dynamic>.from(application['learners']) : <String,dynamic>{};
    final status = '${application['status'] ?? 'Pending'}';
    final isApproved = ['approved','accepted'].contains(status.toLowerCase());
    final isRejected = status.toLowerCase() == 'rejected';
    final color = isApproved ? const Color(0xFF009C72) : isRejected ? Colors.red : const Color(0xFFF59E0B);
    final name = '${learner['full_name'] ?? 'Learner'}';
    final grade = '${learner['grade'] ?? 'Grade not specified'}';
    final reference = '${application['application_number'] ?? application['id'] ?? 'Pending'}';
    String date = 'Not available';
    try { date = DateFormat('dd MMM yyyy').format(DateTime.parse('${application['submitted_at']}').toLocal()); } catch (_) {}
    return Scaffold(appBar: LenyoraPageHeader(title: 'Application Status', subtitle: 'Application progress and admission decision'), body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: isApproved ? const Color(0xFFEAFBF4) : isRejected ? const Color(0xFFFFF0F0) : const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(.35))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 58, height: 58, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(isApproved ? Icons.check_circle_outline : isRejected ? Icons.cancel_outlined : Icons.schedule, color: Colors.white, size: 34)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isApproved ? 'Application Approved!' : isRejected ? 'Application Rejected' : 'Application In Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isApproved ? const Color(0xFF006B4D) : const Color(0xFF6B2B00))), const SizedBox(height: 6), Text(isApproved ? 'Provisional admission has been granted. Please keep this reference for your records.' : isRejected ? 'Please review the decision details and contact the school office if you need assistance.' : 'Your admission dossier has been received. The admissions committee is reviewing your application.', style: const TextStyle(height: 1.5, color: Color(0xFF34445B)))]))])),
      const SizedBox(height: 20), Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: AppTheme.maroon, borderRadius: BorderRadius.vertical(top: Radius.circular(17))), child: const Text('Application Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17))), Padding(padding: const EdgeInsets.all(18), child: Column(children: [_row('Full Name',name),_row('Grade Applied For',grade),_row('Application Date',date),_row('Reference Code',reference),_row('Status',status,valueColor:color)]))])),
      if (isApproved) ...[const SizedBox(height: 18), Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFFEAFBF4), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF8AE6BD))), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.check_circle_outline, color: Color(0xFF009C72)), SizedBox(width: 9), Text('Official Admission Clearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]), SizedBox(height: 12), Text('Please keep your application reference handy and follow any instructions issued by the school.', style: TextStyle(height: 1.5)), SizedBox(height: 12), Text('For certificate availability, contact the school office.', style: TextStyle(color: Color(0xFF006B4D), fontWeight: FontWeight.w600))]))],
      if (isRejected || isApproved) ...[
        const SizedBox(height: 18),
        _officialSlip(application, learner, name, grade, reference, isRejected),
      ],
      if (application['admin_notes'] != null && '${application['admin_notes']}'.trim().isNotEmpty) ...[const SizedBox(height: 16), Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF0F5FA), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('School Notes', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('${application['admin_notes']}')]))],
    ]),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 3),
    );
  }
  Widget _officialSlip(Map<String, dynamic> application, Map<String, dynamic> learner, String learnerName, String grade, String reference, bool rejected) {
    final schoolName = '${_school['school_name'] ?? 'Lenyora Primary School'}';
    final principal = '${_school['principal'] ?? 'School Principal'}';
    final phone = '${_school['phone'] ?? ''}';
    final email = '${_school['email'] ?? ''}';
    final address = '${_school['address'] ?? ''}';
    final parentName = '${application['profiles'] is Map ? (application['profiles']['full_name'] ?? 'Parent / Guardian') : 'Parent / Guardian'}';
    final dobRaw = '${learner['date_of_birth'] ?? ''}';
    String dob = 'Not provided';
    try { dob = DateFormat('yyyy-MM-dd').format(DateTime.parse(dobRaw)); } catch (_) {}
    final reason = '${application['admin_notes'] ?? application['rejection_reason'] ?? 'Please contact the school office for further details.'}';
    final accent = rejected ? const Color(0xFFBE123C) : const Color(0xFF047857);
    final tint = rejected ? const Color(0xFFFFF1F2) : const Color(0xFFECFDF5);
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFD9E2EF))),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFF701C29), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.school, color: Colors.white, size: 28)),
          const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(schoolName.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF701C29))),
            const SizedBox(height: 4), Text(address, style: const TextStyle(fontSize: 11, height: 1.4, color: Color(0xFF64748B))),
            Text('Tel: $phone · $email', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ])),
        ]),
        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: Color(0xFF701C29), thickness: 1.5)),
        const Text('OFFICIAL ADMISSION OUTCOME NOTICE', style: TextStyle(fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text("${_school['intake'] ?? '2027 Academic Intake'} — $grade", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF101D34)))), const SizedBox(width: 8), Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: tint, border: Border.all(color: accent.withOpacity(.25)), borderRadius: BorderRadius.circular(18)), child: Text(rejected ? 'Application Not Successful' : 'Application Successful', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold))))]),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: const Color(0xFFD9E2EF)), borderRadius: BorderRadius.circular(12)), child: Column(children: [
          _row('Learner Name', learnerName), _row('Date of Birth', dob), _row('Grade Applied', grade), _row('Parent / Guardian', parentName), _row('Reference Code', reference),
        ])),
        const SizedBox(height: 18), Text('Dear Parent / Guardian,', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8), Text(rejected ? 'Thank you for your interest in enrolling your child at $schoolName. Following a review of the submitted documentation and admissions capacity, we regret to inform you that we are unable to offer admission into $grade at this time.' : 'We are pleased to inform you that the application for $learnerName into $grade has been approved. Please contact the school to confirm registration and orientation arrangements.', style: const TextStyle(height: 1.55, color: Color(0xFF334155))),
        const SizedBox(height: 14),
        Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: tint, border: Border.all(color: accent.withOpacity(.25)), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(rejected ? 'Reason for Outcome:' : 'Admission Outcome:', style: TextStyle(color: accent, fontWeight: FontWeight.bold)), const SizedBox(height: 7), Text(rejected ? reason : 'Your application has been approved. Keep this notice and reference code for your records.', style: TextStyle(color: accent, height: 1.45, fontStyle: rejected ? FontStyle.italic : FontStyle.normal))])),
        if (rejected) ...[const SizedBox(height: 12), Text('If this decision relates to missing or uncertified documentation, contact the school within 14 working days about an appeal or corrected documents. Phone: $phone · Email: $email', style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF64748B)))],
        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
        Text(principal, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF101D34))),
        Text(schoolName, style: const TextStyle(color: Color(0xFF64748B))),
        Text('Issued: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}', style: const TextStyle(color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        const Text('Official electronic admission outcome notice', style: TextStyle(fontSize: 11, letterSpacing: .5, color: Color(0xFF94A3B8))),
      ]),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) => Padding(padding: const EdgeInsets.only(bottom: 17), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF60738C), fontSize: 14))), const SizedBox(width: 10), Flexible(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? Colors.black87)))]));
}
