import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import '../widgets/app_button.dart';
import 'application_status_screen.dart';
import '../widgets/parent_bottom_navigation.dart';

class ConfirmationScreen extends StatelessWidget {
  final String learnerName;
  final String grade;
  final String applicationId;

  const ConfirmationScreen({
    super.key,
    required this.learnerName,
    required this.grade,
    required this.applicationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LenyoraPageHeader(
          title: 'Lenyora Primary School',
          subtitle: 'Parent Portal · 2027 Academic Intake'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 25),
          const Icon(Icons.verified, color: Colors.lightGreen, size: 85),
          const Text(
            'Thank You!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your application has been submitted to Lenyora Primary School.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFFE8E8E8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  const Text(
                    'Application Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Learner: $learnerName'),
                  Text('Grade Applied For: $grade'),
                  Text('Application ID: $applicationId'),
                  const Text('Status: Pending'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            text: 'View My Applications',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ApplicationStatusScreen(),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 3),
    );
  }
}
