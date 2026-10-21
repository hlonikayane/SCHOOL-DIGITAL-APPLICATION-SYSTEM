import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import '../models/application_draft.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'application_medical_screen.dart';
import '../widgets/parent_bottom_navigation.dart';

class ApplicationLearnerScreen extends StatefulWidget {
  final ApplicationDraft draft;
  const ApplicationLearnerScreen({super.key, required this.draft});

  @override
  State<ApplicationLearnerScreen> createState() =>
      _ApplicationLearnerScreenState();
}

class _ApplicationLearnerScreenState extends State<ApplicationLearnerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController dob;
  late final TextEditingController age;
  late final TextEditingController currentSchool;
  late final TextEditingController language;
  late final TextEditingController address;
  String gender = 'Female';
  String grade = 'Grade R';

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    name = TextEditingController(text: d.learnerFullName);
    dob = TextEditingController(text: d.dateOfBirth);
    age = TextEditingController(text: d.age);
    currentSchool = TextEditingController(text: d.currentSchool);
    language = TextEditingController(text: d.homeLanguage);
    address = TextEditingController(text: d.learnerAddress);
    gender = d.gender.isEmpty ? 'Female' : d.gender;
    grade = d.grade.isEmpty ? 'Grade R' : d.grade;
    dob.addListener(calculateAge);
  }
    void calculateAge() {
      final value = dob.text.trim();

      try {
        final birthDate = DateTime.parse(value);

        if (birthDate.year.toString().padLeft(4, '0') !=
                value.substring(0, 4) ||
            birthDate.month.toString().padLeft(2, '0') !=
                value.substring(5, 7) ||
            birthDate.day.toString().padLeft(2, '0') !=
                value.substring(8, 10) ||
            birthDate.isAfter(DateTime.now())) {
          age.clear();
          return;
        }

        final today = DateTime.now();

        int years = today.year - birthDate.year;

        if (today.month < birthDate.month ||
            (today.month == birthDate.month &&
                today.day < birthDate.day)) {
          years--;
        }

        age.text = years.toString();
      } catch (_) {
        age.clear();
      }
    }
  @override
  void dispose() {
    for (final c in [name, dob, age, currentSchool, language, address]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    final d = widget.draft;
    d.learnerFullName = name.text.trim();
    d.dateOfBirth = dob.text.trim();
    d.age = age.text.trim();
    d.currentSchool = currentSchool.text.trim();
    d.homeLanguage = language.text.trim();
    d.learnerAddress = address.text.trim();
    d.gender = gender;
    d.grade = grade;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicationMedicalScreen(draft: d),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LenyoraPageHeader(title: 'Application - 2 of 4', subtitle: 'Learner Admission Form · 2027 Cycle'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            const Text(
              '2. Learner Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: "Learner's Full Name",
              controller: name,
              validator: requiredField,
            ),
          
              AppTextField(
                label: 'Date of Birth (YYYY-MM-DD)',
                controller: dob,
                readOnly: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2010, 1, 1),
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: DateTime.now(),
                      helpText: 'Select Date of Birth',
                      initialEntryMode: DatePickerEntryMode.calendar,
                    );

                    if (selectedDate != null) {
                      dob.text =
                          '${selectedDate.year.toString().padLeft(4, '0')}-'
                          '${selectedDate.month.toString().padLeft(2, '0')}-'
                          '${selectedDate.day.toString().padLeft(2, '0')}';

                      calculateAge();
                    }
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a Date of Birth';
                  }

                  return null;
                },
              ),

            AppTextField(
              label: 'Age',
              controller: age,
              keyboardType: TextInputType.number,
              validator: requiredField,
            ),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: const ['Female', 'Male', 'Other']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => gender = v ?? 'Female'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: grade,
              decoration: const InputDecoration(labelText: 'Grade'),
              items: const [
                'Grade R',
                'Grade 1',
                'Grade 2',
                'Grade 3',
                'Grade 4',
                'Grade 5',
                'Grade 6',
                'Grade 7',
              ]
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => grade = v ?? 'Grade R'),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Current School (if any)',
              controller: currentSchool,
            ),
            AppTextField(
              label: 'Home language',
              controller: language,
              validator: requiredField,
            ),
            AppTextField(
              label: 'Learner Physical Address',
              controller: address,
              maxLines: 2,
              validator: requiredField,
            ),
            AppButton(text: 'Next', onPressed: _next),
          ],
        ),
      ),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 3),
    );
  }
}

String? requiredField(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required';
  return null;
}
