import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import '../theme/app_theme.dart';
import '../widgets/parent_bottom_navigation.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _contact(BuildContext context, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Lenyora Primary School'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LenyoraPageHeader(
          title: 'Help & Support', subtitle: "We're here to help"),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppTheme.paleRose,
              borderRadius: BorderRadius.circular(12)),
          child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent, color: AppTheme.maroon, size: 42),
                SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('How can we help?',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text(
                          'We are here to help parents and guardians with applications, documents and account access.'),
                    ])),
              ]),
        ),
        const SizedBox(height: 16),
        _ContactTile(
            icon: Icons.call,
            title: 'Call Us',
            subtitle: '057 355 6974',
            detail:
                'School office: 057 355 6974\nOffice hours: Monday–Friday, 07:00–16:00',
            onTap: () => _contact(context,
                'School office: 057 355 6974\nOffice hours: Monday–Friday, 07:00–16:00')),
        _ContactTile(
            icon: Icons.email_outlined,
            title: 'Email Us',
            subtitle: 'info@lenyoraschool.co.za',
            detail:
                'Email the school at info@lenyoraschool.co.za for help with applications or your account.',
            onTap: () => _contact(context, 'Email: info@lenyoraschool.co.za')),
        _ContactTile(
            icon: Icons.location_on_outlined,
            title: 'Visit Us',
            subtitle: '8152 Matshaba Street, Motsethabong Welkom, 9463',
            detail:
                'Lenyora Primary School\n8152 Matshaba Street\nMotsethabong, Welkom, 9463',
            onTap: () => _contact(context,
                'Lenyora Primary School\n8152 Matshaba Street\nMotsethabong, Welkom, 9463')),
        const SizedBox(height: 12),
        const Text('Frequently asked questions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 6),
        const _Faq(
            question: 'Which documents do I need?',
            answer:
                'A certified birth certificate, parent/guardian ID or passport, and proof of residence are required. A latest school report and transfer letter may also be requested.'),
        const _Faq(
            question: 'How do I track my application?',
            answer:
                'Open My Applications to see whether each application is Pending, Approved or Rejected. If the school requests more information, contact the office.'),
        const _Faq(
            question: 'I cannot sign in. What should I do?',
            answer:
                'Use Forgot password on the login screen to request a password-reset email. Check your spam folder if it does not arrive.'),
      ]),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 4),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;
  final VoidCallback onTap;
  const _ContactTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.detail,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
      child: ListTile(
          leading: CircleAvatar(
              backgroundColor: AppTheme.paleRose,
              child: Icon(icon, color: AppTheme.maroon)),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap));
}

class _Faq extends StatelessWidget {
  final String question;
  final String answer;
  const _Faq({required this.question, required this.answer});
  @override
  Widget build(BuildContext context) => Card(
      child: ExpansionTile(
          title: Text(question,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [Text(answer)]));
}
