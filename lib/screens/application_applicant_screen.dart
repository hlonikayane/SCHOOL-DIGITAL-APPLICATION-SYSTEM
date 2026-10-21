import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import '../models/application_draft.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'application_learner_screen.dart';
import '../widgets/parent_bottom_navigation.dart';
import 'package:flutter/services.dart';

class ApplicationApplicantScreen extends StatefulWidget {
  final ApplicationDraft draft;
  const ApplicationApplicantScreen({super.key, required this.draft});

  @override
  State<ApplicationApplicantScreen> createState() =>
      _ApplicationApplicantScreenState();
}

class _ApplicationApplicantScreenState
    extends State<ApplicationApplicantScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController fullName;
  late final TextEditingController id;
  late final TextEditingController email;
  late final TextEditingController phone;
  late final TextEditingController relationship;
  late final TextEditingController address;

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    fullName = TextEditingController(text: d.parentFullName);
    id = TextEditingController(text: d.parentIdNumber);
    email = TextEditingController(text: d.parentEmail);
    phone = TextEditingController(text: d.parentPhone);
    relationship = TextEditingController(text: d.relationship);
    address = TextEditingController(text: d.parentAddress);
  }

  @override
  void dispose() {
    for (final c in [fullName, id, email, phone, relationship, address]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    final d = widget.draft;
    d.parentFullName = fullName.text.trim();
    d.parentIdNumber = id.text.trim();
    d.parentEmail = email.text.trim();
    d.parentPhone = phone.text.trim();
    d.relationship = relationship.text.trim();
    d.parentAddress = address.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicationLearnerScreen(draft: d),
      ),
    );
  }

  // Added a helper method to handle saving and closing
  void _saveAndClose() {
    // 1. Validate the form (Optional: Remove the 'if' check if you want to save incomplete forms)
    if (!_formKey.currentState!.validate()) return;

    // 2. Save the current form data to the draft
    final d = widget.draft;
    d.parentFullName = fullName.text.trim();
    d.parentIdNumber = id.text.trim();
    d.parentEmail = email.text.trim();
    d.parentPhone = phone.text.trim();
    d.relationship = relationship.text.trim();
    d.parentAddress = address.text.trim();

    // 3. Close the screen and return to the previous page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LenyoraPageHeader(title: 'Application - 1 of 4', subtitle: 'Learner Admission Form · 2027 Cycle'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            const Text(
              '1. Parent/Guardian Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Full name',
              controller: fullName,
              validator: requiredField,
            ),
            AppTextField(
              label: 'ID/Passport Number',
              controller: id,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'ID/Passport Number is required';
                }
                if (value.length != 13) {
                  return 'ID Number must be exactly 13 digits';
                }
                return null;
              },
            ),
            AppTextField(
              label: 'Email Address',
              controller: email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            AppTextField(
              label: 'Phone Number',
              controller: phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
             validator: (value) {
               if (value == null || value.isEmpty) {
                 return 'Phone Number is required';
                  }
               if (value.length != 10) {
                 return 'Phone Number must be exactly 10 digits';
                  }
                   return null;
                  },
            ),
            AppTextField(
              label: 'Relationship to learner',
              controller: relationship,
              validator: requiredField,
            ),
            AppTextField(
              label: 'Physical Address',
              controller: address,
              maxLines: 2,
              validator: requiredField,
            ),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Save & Close',
                    onPressed: _saveAndClose,
                  ),
                ),
                const SizedBox(width: 12), // Adds spacing between buttons
                Expanded(
                  child: AppButton(
                    text: 'Next',
                    onPressed: _next,
                  ),
                ),
              ],
            ),

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