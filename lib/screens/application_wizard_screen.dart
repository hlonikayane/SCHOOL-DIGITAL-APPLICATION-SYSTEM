import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/application_draft.dart';
import '../services/draft_storage.dart';
import '../widgets/parent_bottom_navigation.dart';
import 'confirmation_screen.dart';

const Color _wine = Color(0xFF711D28);
const Color _page = Color(0xFFF6F8FB);
const Color _line = Color(0xFFD1DCEB);
const Color _muted = Color(0xFF60738F);

class ApplicationWizardScreen extends StatefulWidget {
  const ApplicationWizardScreen({super.key});

  @override
  State<ApplicationWizardScreen> createState() =>
      _ApplicationWizardScreenState();
}

class _ApplicationWizardScreenState extends State<ApplicationWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _client = Supabase.instance.client;
  final _draft = ApplicationDraft();

  int _step = 0;
  bool _loadingDraft = true;
  bool _hasSavedDraft = false;
  bool _submitting = false;
  bool _saving = false;
  Timer? _autosaveTimer;

  final Map<String, TextEditingController> _fields = {
    'parentFullName': TextEditingController(),
    'parentIdNumber': TextEditingController(),
    'parentEmail': TextEditingController(),
    'parentPhone': TextEditingController(),
    'relationship': TextEditingController(),
    'parentAddress': TextEditingController(),
    'learnerFullName': TextEditingController(),
    'learnerSurname': TextEditingController(),
    'dateOfBirth': TextEditingController(),
    'currentSchool': TextEditingController(),
    'learnerAddress': TextEditingController(),
    'medicalCondition': TextEditingController(),
    'doctorNameContact': TextEditingController(),
    'medicalAidNameNumber': TextEditingController(),
    'emergencyContactName': TextEditingController(),
    'emergencyContactPhone': TextEditingController(),
    'disability': TextEditingController(),
  };

  String _relationship = 'Father';
  String _grade = 'Grade R';
  String _gender = 'Male';
  String _language = 'Sesotho';
  final Map<String, PlatformFile> _files = {};

  static const _documentLabels = <String, String>{
    'birth_certificate': 'Certified copy of birth certificate',
    'parent_id': 'Certified copy of parent ID / passport',
    'proof_of_residence': 'Proof of residence',
    'latest_report': 'Latest school report (if available)',
    'proof_of_transfer': 'Proof of transfer (if available)',
  };
  static const _requiredDocuments = <String>[
    'birth_certificate',
    'parent_id',
    'proof_of_residence',
  ];

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? get _userId => _client.auth.currentUser?.id;

  Future<void> _loadDraft() async {
    final uid = _userId;
    if (uid == null) {
      if (mounted) setState(() => _loadingDraft = false);
      return;
    }
    final saved = await DraftStorage.load(uid);
    if (!mounted) return;
    if (saved != null) {
      _copyDraftToForm(saved);
      setState(() {
        _hasSavedDraft = true;
        _loadingDraft = false;
      });
    } else {
      setState(() => _loadingDraft = false);
    }
  }

  void _copyDraftToForm(ApplicationDraft source) {
    _draft
      ..parentFullName = source.parentFullName
      ..parentIdNumber = source.parentIdNumber
      ..parentEmail = source.parentEmail
      ..parentPhone = source.parentPhone
      ..relationship = source.relationship
      ..parentAddress = source.parentAddress
      ..learnerFullName = source.learnerFullName
      ..learnerSurname = source.learnerSurname
      ..dateOfBirth = source.dateOfBirth
      ..gender = source.gender
      ..currentSchool = source.currentSchool
      ..homeLanguage = source.homeLanguage
      ..learnerAddress = source.learnerAddress
      ..age = source.age
      ..grade = source.grade
      ..medicalCondition = source.medicalCondition
      ..doctorNameContact = source.doctorNameContact
      ..medicalAidNameNumber = source.medicalAidNameNumber
      ..emergencyContactName = source.emergencyContactName
      ..emergencyContactPhone = source.emergencyContactPhone
      ..disability = source.disability
      ..updatedAt = source.updatedAt;
    for (final entry in _fields.entries) {
      entry.value.text = _valueFor(source, entry.key);
    }
    _relationship =
        source.relationship.isEmpty ? 'Father' : source.relationship;
    _grade = source.grade.isEmpty ? 'Grade R' : source.grade;
    _gender = source.gender.isEmpty ? 'Male' : source.gender;
    _language = source.homeLanguage.isEmpty ? 'Sesotho' : source.homeLanguage;
  }

  String _valueFor(ApplicationDraft d, String key) {
    switch (key) {
      case 'parentFullName':
        return d.parentFullName;
      case 'parentIdNumber':
        return d.parentIdNumber;
      case 'parentEmail':
        return d.parentEmail;
      case 'parentPhone':
        return d.parentPhone;
      case 'relationship':
        return d.relationship;
      case 'parentAddress':
        return d.parentAddress;
      case 'learnerFullName':
        return d.learnerFullName;
      case 'learnerSurname':
        return d.learnerSurname;
      case 'dateOfBirth':
        return d.dateOfBirth;
      case 'currentSchool':
        return d.currentSchool;
      case 'learnerAddress':
        return d.learnerAddress;
      case 'medicalCondition':
        return d.medicalCondition;
      case 'doctorNameContact':
        return d.doctorNameContact;
      case 'medicalAidNameNumber':
        return d.medicalAidNameNumber;
      case 'emergencyContactName':
        return d.emergencyContactName;
      case 'emergencyContactPhone':
        return d.emergencyContactPhone;
      case 'disability':
        return d.disability;
      default:
        return '';
    }
  }

  void _copyFormToDraft() {
    String v(String key) => _fields[key]!.text.trim();
    _draft
      ..parentFullName = v('parentFullName')
      ..parentIdNumber = v('parentIdNumber')
      ..parentEmail = v('parentEmail')
      ..parentPhone = v('parentPhone')
      ..relationship = _relationship
      ..parentAddress = v('parentAddress')
      ..learnerFullName = v('learnerFullName')
      ..learnerSurname = v('learnerSurname')
      ..dateOfBirth = v('dateOfBirth')
      ..gender = _gender
      ..currentSchool = v('currentSchool')
      ..homeLanguage = _language
      ..learnerAddress = v('learnerAddress')
      ..grade = _grade
      ..medicalCondition = v('medicalCondition')
      ..doctorNameContact = v('doctorNameContact')
      ..medicalAidNameNumber = v('medicalAidNameNumber')
      ..emergencyContactName = v('emergencyContactName')
      ..emergencyContactPhone = v('emergencyContactPhone')
      ..disability = v('disability');
    final dob = _parseDate(_draft.dateOfBirth);
    if (dob != null) {
      final now = DateTime.now();
      var years = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        years--;
      }
      _draft.age = years.toString();
    } else {
      _draft.age = '';
    }
    _draft.documentPaths
      ..clear()
      ..addEntries(_files.entries.map((e) => MapEntry(e.key, e.value.name)));
  }

  DateTime? _parseDate(String value) {
    final normalized = value.trim().replaceAll('/', '-');
    final parts = normalized.split('-');
    if (parts.length != 3) return null;
    // Accept the screenshot format yyyy/MM/dd and ISO yyyy-MM-dd.
    return DateTime.tryParse(
        '${parts[0].padLeft(4, '0')}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}');
  }

  Future<void> _saveDraft({bool exit = false}) async {
    final uid = _userId;
    if (uid == null) {
      _message('Please sign in before saving an application draft.');
      return;
    }
    _copyFormToDraft();
    setState(() => _saving = true);
    try {
      await DraftStorage.save(uid, _draft);
      if (!mounted) return;
      setState(() => _hasSavedDraft = true);
      _message('Application progress saved on this device.');
      if (exit) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) _message('Could not save draft: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _startFresh() async {
    final uid = _userId;
    if (uid != null) await DraftStorage.clear(uid);
    for (final controller in _fields.values) {
      controller.clear();
    }
    _files.clear();
    _draft.documentPaths.clear();
    _draft.updatedAt = null;
    setState(() {
      _step = 0;
      _hasSavedDraft = false;
      _relationship = 'Father';
      _grade = 'Grade R';
      _gender = 'Male';
      _language = 'Sesotho';
    });
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 800), () {
      _saveSilently();
    });
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  String? _validEmail(String? value) {
    if (value == null ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validPhone(String? value) {
    if (value == null ||
        !RegExp(r'^\d{10}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a 10-digit phone number';
    }
    return null;
  }

  Future<void> _next() async {
    if (_step < 3 && !_formKey.currentState!.validate()) return;
    _copyFormToDraft();
    if (_step < 3) {
      await _saveSilently();
      if (mounted) setState(() => _step++);
    } else {
      await _submit();
    }
  }

  Future<void> _backStep() async {
    _copyFormToDraft();
    await _saveSilently();
    if (mounted && _step > 0) setState(() => _step--);
  }

  Future<void> _saveSilently() async {
    final uid = _userId;
    if (uid == null) return;
    _copyFormToDraft();
    try {
      await DraftStorage.save(uid, _draft);
      if (mounted) setState(() => _hasSavedDraft = true);
    } catch (_) {
      // Keep the form usable even if local storage is temporarily unavailable.
    }
  }

  Future<void> _pickDocument(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (!mounted || result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (file.size > 10 * 1024 * 1024) {
        _message('Each document must be 10 MB or smaller.');
        return;
      }
      if ((file.bytes == null || file.bytes!.isEmpty) &&
          (file.path == null || file.path!.isEmpty)) {
        _message('Could not read this file. Please select it again.');
        return;
      }
      setState(() => _files[type] = file);
      await _saveSilently();
      if (mounted) _message('Selected ${file.name}');
    } catch (e) {
      if (mounted) _message('Could not select document: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    for (final type in _requiredDocuments) {
      if (!_files.containsKey(type)) {
        _message('Please attach ${_documentLabels[type]}.');
        return;
      }
    }
    final user = _client.auth.currentUser;
    if (user == null) {
      _message('Please sign in before submitting.');
      return;
    }
    _copyFormToDraft();
    setState(() => _submitting = true);
    try {
      final dob = _parseDate(_draft.dateOfBirth);
      final learner = await _client
          .from('learners')
          .insert({
            'parent_id': user.id,
            'full_name':
                '${_draft.learnerFullName} ${_draft.learnerSurname}'.trim(),
            'age': int.tryParse(_draft.age) ?? 0,
            'grade': _draft.grade,
            if (dob != null)
              'date_of_birth':
                  '${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}',
          })
          .select('id')
          .single();

      final notes = <String>[
        'Parent: ${_draft.parentFullName}',
        'Parent ID/Passport: ${_draft.parentIdNumber}',
        'Email: ${_draft.parentEmail}',
        'Phone: ${_draft.parentPhone}',
        'Relationship: ${_draft.relationship}',
        'Parent address: ${_draft.parentAddress}',
        'Learner gender: ${_draft.gender}',
        'Home language: ${_draft.homeLanguage}',
        if (_draft.currentSchool.isNotEmpty)
          'Current school: ${_draft.currentSchool}',
        if (_draft.learnerAddress.isNotEmpty)
          'Learner address: ${_draft.learnerAddress}',
        if (_draft.medicalCondition.isNotEmpty)
          'Medical condition: ${_draft.medicalCondition}',
        if (_draft.doctorNameContact.isNotEmpty)
          'Doctor contact: ${_draft.doctorNameContact}',
        if (_draft.medicalAidNameNumber.isNotEmpty)
          'Medical aid: ${_draft.medicalAidNameNumber}',
        'Emergency contact: ${_draft.emergencyContactName}',
        'Emergency phone: ${_draft.emergencyContactPhone}',
        if (_draft.disability.isNotEmpty) 'Disability: ${_draft.disability}',
      ].join('\n');

      final application = await _client
          .from('applications')
          .insert({
            'parent_id': user.id,
            'learner_id': learner['id'],
            'parent_notes': notes,
          })
          .select('id')
          .single();
      final applicationId = application['id'].toString();

      for (final entry in _files.entries) {
        final file = entry.value;
        final bytes = file.bytes;
        if (bytes == null || bytes.isEmpty) {
          throw Exception(
              'Could not read ${file.name}. Please choose it again.');
        }
        final ext = (file.extension ?? 'bin').toLowerCase();
        final storagePath = '${user.id}/$applicationId/${entry.key}.$ext';
        await _client.storage.from('application-documents').uploadBinary(
              storagePath,
              bytes,
              fileOptions:
                  FileOptions(contentType: _contentType(ext), upsert: true),
            );
        await _client.from('documents').insert({
          'application_id': applicationId,
          'owner_id': user.id,
          'document_type': const [
            'birth_certificate',
            'parent_id',
            'proof_of_residence'
          ].contains(entry.key)
              ? entry.key
              : 'other',
          'file_name': file.name,
          'storage_path': storagePath,
          'content_type': _contentType(ext),
          'size_bytes': bytes.length,
        });
      }

      await DraftStorage.clear(user.id);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ConfirmationScreen(
            learnerName:
                '${_draft.learnerFullName} ${_draft.learnerSurname}'.trim(),
            grade: _draft.grade,
            applicationId: applicationId,
          ),
        ),
      );
    } catch (e) {
      if (mounted) _message('Submission failed: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _contentType(String ext) => switch (ext) {
        'pdf' => 'application/pdf',
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        _ => 'application/octet-stream',
      };

  Widget _textField(String key, String label,
      {bool required = false,
      String? Function(String?)? validator,
      TextInputType? keyboard,
      int lines = 1,
      String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _fields[key],
        onChanged: (_) => _scheduleAutosave(),
        keyboardType: keyboard,
        maxLines: lines,
        validator: validator ?? (required ? _required : null),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _line)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _line)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _wine, width: 2)),
        ),
      ),
    );
  }

  Widget _dateOfBirthField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _fields['dateOfBirth'],
        readOnly: true,
        onTap: () async {
          final today = DateTime.now();
          final existing = _parseDate(_fields['dateOfBirth']?.text ?? '');
          final picked = await showDatePicker(
            context: context,
            initialDate: existing != null && !existing.isAfter(today)
                ? existing
                : DateTime(today.year - 5, today.month, today.day),
            firstDate: DateTime(1900),
            lastDate: today,
            helpText: 'Select learner date of birth',
          );
          if (picked != null && mounted) {
            _fields['dateOfBirth']!.text =
                '${picked.year.toString().padLeft(4, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
            _scheduleAutosave();
            setState(() {});
          }
        },
        validator: (v) {
          final date = _parseDate(v ?? '');
          if (date == null) return 'Select the date of birth';
          if (date.isAfter(DateTime.now()))
            return 'Date cannot be in the future';
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Date of Birth *',
          hintText: 'YYYY/MM/DD',
          suffixIcon: IconButton(
            tooltip: 'Choose date of birth',
            icon: const Icon(Icons.calendar_month_outlined, color: _wine),
            onPressed: () async {
              final today = DateTime.now();
              final existing = _parseDate(_fields['dateOfBirth']?.text ?? '');
              final picked = await showDatePicker(
                context: context,
                initialDate: existing != null && !existing.isAfter(today)
                    ? existing
                    : DateTime(today.year - 5, today.month, today.day),
                firstDate: DateTime(1900),
                lastDate: today,
                helpText: 'Select learner date of birth',
              );
              if (picked != null && mounted) {
                _fields['dateOfBirth']!.text =
                    '${picked.year.toString().padLeft(4, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
                _scheduleAutosave();
                setState(() {});
              }
            },
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _line)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _line)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _wine, width: 2)),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: '$label *',
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _line)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _line)),
      ),
      items: options
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null || v.isEmpty ? 'Choose $label' : null,
    );
  }

  Widget _sectionHeader() {
    const titles = [
      'Applicant Details',
      'Learner Details',
      'Medical & Emergency',
      'Documents'
    ];
    const icons = [
      Icons.person_outline,
      Icons.school_outlined,
      Icons.favorite_outline,
      Icons.description_outlined
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: const BoxDecoration(
        color: _wine,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(icons[_step], color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
              child: Text('${_step + 1}. ${titles[_step]}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16))),
          Text('Step ${_step + 1} of 4',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _stepper() {
    const titles = [
      'Applicant\nDetails',
      'Learner\nDetails',
      'Medical &\nEmergency',
      'Documents'
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE0E7F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(
                child: Text('Application',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'serif'))),
            if (_draft.updatedAt != null)
              Text(
                  'Auto-saved: ${TimeOfDay.fromDateTime(_draft.updatedAt!).format(context)}',
                  style: const TextStyle(color: _muted, fontSize: 11)),
          ]),
          const SizedBox(height: 14),
          Row(
              children: List.generate(4, (i) {
            final complete = i < _step;
            final active = i == _step;
            return Expanded(
                child: InkWell(
              onTap: i < _step ? () => setState(() => _step = i) : null,
              child: Column(children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: complete
                        ? const Color(0xFF009B70)
                        : active
                            ? const Color(0xFF55DCEC)
                            : const Color(0xFFE1E7F0),
                    border: active
                        ? Border.all(color: const Color(0xFFB9F5FA), width: 5)
                        : null,
                  ),
                  child: Icon(complete ? Icons.check : null,
                      color: Colors.white, size: 23),
                ),
                if (!complete)
                  Transform.translate(
                      offset: const Offset(0, -34),
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: active
                                  ? Colors.black
                                  : const Color(0xFF45556D)))),
                SizedBox(height: complete ? 8 : 0),
                Text(titles[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: active ? Colors.black : _muted,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.normal)),
              ]),
            ));
          })),
        ],
      ),
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return Column(children: [
          _textField('parentFullName', 'Full name', required: true),
          _textField('parentIdNumber', 'ID/Passport Number',
              required: true,
              keyboard: TextInputType.number,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'This field is required'
                  : (v.replaceAll(' ', '').length < 6
                      ? 'Enter a valid ID/passport number'
                      : null)),
          _textField('parentEmail', 'Email Address',
              required: true,
              keyboard: TextInputType.emailAddress,
              validator: _validEmail),
          _textField('parentPhone', 'Phone number',
              required: true,
              keyboard: TextInputType.phone,
              validator: _validPhone),
          _dropdown('Relationship to learner', _relationship, const [
            'Mother',
            'Father',
            'Guardian',
            'Grandparent',
            'Other'
          ], (v) {
            setState(() => _relationship = v ?? 'Father');
            _scheduleAutosave();
          }),
          const SizedBox(height: 16),
          _textField('parentAddress', 'Physical Address',
              required: true, lines: 3, hint: 'Street address, suburb/town'),
        ]);
      case 1:
        return Column(children: [
          _textField('learnerFullName', "Learner's Full name", required: true),
          _textField('learnerSurname', 'Learner surname',
              hint: 'Enter surname', required: false),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: _dropdown('Grade Applying For', _grade, const [
              'Grade R',
              'Grade 1',
              'Grade 2',
              'Grade 3',
              'Grade 4',
              'Grade 5',
              'Grade 6',
              'Grade 7'
            ], (v) {
              setState(() => _grade = v ?? 'Grade R');
              _scheduleAutosave();
            })),
            const SizedBox(width: 12),
            Expanded(
                child: _dropdown(
                    'Gender', _gender, const ['Male', 'Female', 'Other'], (v) {
              setState(() => _gender = v ?? 'Male');
              _scheduleAutosave();
            })),
          ]),
          _dateOfBirthField(),
          _dropdown('Home language', _language, const [
            'Sesotho',
            'English',
            'Afrikaans',
            'isiZulu',
            'isiXhosa',
            'Setswana',
            'Sepedi',
            'Xitsonga',
            'Tshivenda',
            'siSwati',
            'isiNdebele',
            'Other'
          ], (v) {
            setState(() => _language = v ?? 'Sesotho');
            _scheduleAutosave();
          }),
          _textField('currentSchool', 'Current School (if any)',
              hint: 'e.g. Motsetsethabong Creche / None'),
          _textField('learnerAddress', 'Learner residential address', lines: 2),
        ]);
      case 2:
        return Column(children: [
          _textField('medicalCondition', 'Learner Medical Condition',
              hint: 'None / Healthy'),
          _textField('doctorNameContact', "Doctor's Name & Contact",
              hint: 'Doctor name and phone number'),
          _textField('medicalAidNameNumber', 'Medical Aid Name and Number',
              hint: 'Medical aid details, if any'),
          _textField('emergencyContactName', 'Emergency Contact (Name)',
              required: true),
          _textField(
              'emergencyContactPhone', 'Emergency contact (Phone Number)',
              required: true,
              keyboard: TextInputType.phone,
              validator: _validPhone),
          _textField('disability', 'Disability (if yes, please specify)',
              hint: 'None'),
        ]);
      default:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              'Upload the required supporting documents. PDF, JPG or PNG; maximum 10 MB per file.',
              style: TextStyle(color: _muted, height: 1.4)),
          const SizedBox(height: 12),
          ..._documentLabels.entries.map((entry) {
            final file = _files[entry.key];
            final required = _requiredDocuments.contains(entry.key);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: _line)),
              child: Row(children: [
                Icon(file == null ? Icons.description_outlined : Icons.task_alt,
                    color: file == null ? _wine : const Color(0xFF009B70),
                    size: 28),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('${entry.value}${required ? ' *' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(
                          file?.name ??
                              (required
                                  ? 'Required document · No file selected'
                                  : 'Optional document'),
                          style: const TextStyle(fontSize: 12, color: _muted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ])),
                TextButton(
                    onPressed:
                        _submitting ? null : () => _pickDocument(entry.key),
                    child: Text(file == null ? 'Choose' : 'Change')),
              ]),
            );
          }),
          const SizedBox(height: 4),
          const Text('* Required documents must be attached before submission.',
              style: TextStyle(fontSize: 12, color: _muted)),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        child: _loadingDraft
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: _wine,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white)),
                        const Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Lenyora Primary School',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22)),
                              SizedBox(height: 3),
                              Text('Learner Admission Form · 2027 Cycle',
                                  style: TextStyle(color: Colors.white70)),
                            ])),
                        const SizedBox(width: 8),
                        Column(children: [
                          OutlinedButton.icon(
                              onPressed: _saving ? null : () => _saveDraft(),
                              icon: const Icon(Icons.save_outlined, size: 16),
                              label: const Text('Save Progress'),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side:
                                      const BorderSide(color: Colors.white38))),
                          TextButton(
                              onPressed:
                                  _saving ? null : () => _saveDraft(exit: true),
                              child: const Text('Save & Exit',
                                  style: TextStyle(color: Colors.white))),
                        ]),
                      ]),
                    ),
                    if (_hasSavedDraft) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEE),
                            border: Border.all(color: const Color(0xFFFFC928)),
                            borderRadius: BorderRadius.circular(18)),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.bookmark_added_outlined,
                                  color: Color(0xFFCE6800)),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    const Text('Saved Draft Detected',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        'Saved for ${_draft.learnerFullName.isEmpty ? 'your learner' : _draft.learnerFullName} (${_draft.grade.isEmpty ? 'Grade R' : _draft.grade}) · Step ${_step + 1} of 4',
                                        style: const TextStyle(
                                            color: _muted, fontSize: 12)),
                                    if (_draft.updatedAt != null)
                                      Text(
                                          'Last saved: ${MaterialLocalizations.of(context).formatShortDate(_draft.updatedAt!)} ${TimeOfDay.fromDateTime(_draft.updatedAt!).format(context)}',
                                          style: const TextStyle(
                                              color: _muted, fontSize: 12)),
                                  ])),
                              const SizedBox(width: 6),
                              Column(children: [
                                FilledButton(
                                    onPressed: () => setState(() {}),
                                    style: FilledButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFB94D00),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10)),
                                    child: const Text('Resume',
                                        style: TextStyle(fontSize: 12))),
                                TextButton(
                                    onPressed: _startFresh,
                                    child: const Text('Start Fresh',
                                        style: TextStyle(fontSize: 12))),
                              ]),
                            ]),
                      ),
                    ],
                    const SizedBox(height: 18),
                    _stepper(),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _line)),
                      child: Column(children: [
                        _sectionHeader(),
                        Padding(
                            padding: const EdgeInsets.all(18),
                            child: _stepContent()),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      if (_step > 0)
                        Expanded(
                            child: OutlinedButton.icon(
                                onPressed: _backStep,
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Previous'),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: _wine,
                                    side: const BorderSide(color: _line),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15)))),
                      if (_step > 0) const SizedBox(width: 12),
                      Expanded(
                          child: FilledButton.icon(
                        onPressed: _submitting ? null : _next,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Icon(_step == 3
                                ? Icons.send_outlined
                                : Icons.chevron_right),
                        label: Text(_step == 3
                            ? (_submitting
                                ? 'Submitting...'
                                : 'Submit Application')
                            : 'Next Step'),
                        style: FilledButton.styleFrom(
                            backgroundColor: _wine,
                            padding: const EdgeInsets.symmetric(vertical: 15)),
                      )),
                    ]),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                        onPressed: _saving ? null : () => _saveDraft(),
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_saving ? 'Saving...' : 'Save Progress'),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF9B4D00),
                            side: const BorderSide(color: Color(0xFFFFC928)),
                            padding: const EdgeInsets.symmetric(vertical: 14))),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const ParentBottomNavigation(currentIndex: 3),
    );
  }
}
