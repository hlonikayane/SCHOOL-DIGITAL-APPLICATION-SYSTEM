import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import '../models/application_draft.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'documents_screen.dart';
import '../widgets/parent_bottom_navigation.dart';

class ApplicationMedicalScreen extends StatefulWidget {
  final ApplicationDraft draft;
  const ApplicationMedicalScreen({super.key, required this.draft});

  @override
  State<ApplicationMedicalScreen> createState() =>
      _ApplicationMedicalScreenState();
}

class _ApplicationMedicalScreenState extends State<ApplicationMedicalScreen> {
  late final TextEditingController condition;
  late final TextEditingController doctor;
  late final TextEditingController aid;
  late final TextEditingController emergencyName;
  late final TextEditingController emergencyPhone;
  late final TextEditingController disability;

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    condition = TextEditingController(text: d.medicalCondition);
    doctor = TextEditingController(text: d.doctorNameContact);
    aid = TextEditingController(text: d.medicalAidNameNumber);
    emergencyName = TextEditingController(text: d.emergencyContactName);
    emergencyPhone = TextEditingController(text: d.emergencyContactPhone);
    disability = TextEditingController(text: d.disability);
  }

  @override
  void dispose() {
    for (final c in [
      condition,
      doctor,
      aid,
      emergencyName,
      emergencyPhone,
      disability
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    final d = widget.draft;
    d.medicalCondition = condition.text.trim();
    d.doctorNameContact = doctor.text.trim();
    d.medicalAidNameNumber = aid.text.trim();
    d.emergencyContactName = emergencyName.text.trim();
    d.emergencyContactPhone = emergencyPhone.text.trim();
    d.disability = disability.text.trim();

    if (d.emergencyContactName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency contact name is required.'),
        ),
      );
      return;
    }
     if ( d.emergencyContactPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency contact phone is required.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentsScreen(draft: d),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LenyoraPageHeader(title: 'Application - 3 of 4', subtitle: 'Learner Admission Form · 2027 Cycle'),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text(
            '3. Medical & Emergency Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          AppTextField(label: 'Learner Medical Condition', controller: condition),
          AppTextField(label: "Doctor's Name & Contact", controller: doctor),
          AppTextField(label: 'Medical Aid Name & Number', controller: aid),
          AppTextField(
            label: 'Emergency Contact Name',
            controller: emergencyName,
          ),
          AppTextField(
              label: 'Emergency Phone Number',
              controller: emergencyPhone,
              keyboardType: TextInputType.phone,
             validator: (value) {
               if (value == null || value.isEmpty) {
                 return 'Emergency Phone Number is required';
                  }
               if (value.length != 10) {
                 return 'Phone Number must be exactly 10 digits';
                  }
                   return null;
                  },
            ),
          AppTextField(label: 'Disability (if any)', controller: disability),
          AppButton(text: 'Next', onPressed: _next),
        ],
      ),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 3),
    );
  }
}
