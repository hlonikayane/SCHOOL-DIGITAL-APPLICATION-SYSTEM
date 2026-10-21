import 'package:flutter/material.dart';
import '../widgets/lenyora_page_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/parent_bottom_navigation.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});
  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final _client = Supabase.instance.client;
  String? _grade;
  List<Map<String, dynamic>> _subjects = [];
  bool _loading = false;
  static const grades = [
    'Grade R',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7'
  ];
  static const defaults = <String, List<String>>{
    'Grade R': ['Home Language', 'Mathematics', 'Life Skills'],
    'Grade 1': [
      'English First Additional Language',
      'Numeracy & Mathematics',
      'Life Skills',
      'Sesotho Home Language'
    ],
    'Grade 2': ['English', 'Mathematics', 'Life Skills', 'Sesotho'],
    'Grade 3': ['English', 'Mathematics', 'Life Skills', 'Sesotho'],
    'Grade 4': [
      'English',
      'Mathematics',
      'Life Skills',
      'Social Sciences',
      'Sesotho',
      'Natural Sciences & Technology'
    ],
    'Grade 5': [
      'English',
      'Mathematics',
      'Life Skills',
      'Social Sciences',
      'Sesotho',
      'Natural Sciences & Technology'
    ],
    'Grade 6': [
      'English',
      'Mathematics',
      'Life Skills',
      'Social Sciences',
      'Sesotho',
      'Natural Sciences & Technology'
    ],
    'Grade 7': [
      'English',
      'Mathematics',
      'Life Orientation',
      'Social Sciences',
      'Sesotho',
      'Natural Sciences & Technology',
      'Creative Arts',
      'Economic & Management Sciences'
    ],
  };
  static const _hours = <String, int>{
    'English First Additional Language': 6,
    'Numeracy & Mathematics': 5,
    'Mathematics': 5,
    'Life Skills': 4,
    'Sesotho Home Language': 6,
    'English': 6
  };
  Future<void> _openGrade(String grade) async {
    setState(() {
      _grade = grade;
      _subjects = [];
      _loading = true;
    });
    try {
      final rows = await _client
          .from('subjects')
          .select()
          .eq('grade', grade)
          .eq('active', true)
          .order('name');
      if (!mounted) return;
      var loaded = List<Map<String, dynamic>>.from(rows);
      if (loaded.isEmpty)
        loaded = [
          for (final name in defaults[grade] ?? const <String>[])
            {'name': name, 'grade': grade}
        ];
      setState(() {
        _subjects = loaded;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _subjects = [
          for (final name in defaults[grade] ?? const <String>[])
            {'name': name, 'grade': grade}
        ];
        _loading = false;
      });
    }
  }

  void _showDetails(Map<String, dynamic> subject) {
    final name = '${subject['name'] ?? subject['subject_name'] ?? 'Subject'}';
    showDialog<void>(
        context: context,
        builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
                  color: AppTheme.maroon,
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                              '${(_grade ?? '').toUpperCase()} · CAPS CURRICULUM',
                              style: const TextStyle(
                                  color: Color(0xFFFFE45C),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20))
                        ])),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white))
                  ])),
              Flexible(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Subject Description:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                                '${subject['description'] ?? _description(name)}',
                                style: const TextStyle(
                                    height: 1.5, color: Color(0xFF43536A))),
                            const SizedBox(height: 20),
                            const Text('Key CAPS Learning Outcomes:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ..._outcomes(name).map((x) => Padding(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('•  '),
                                      Expanded(
                                          child: Text(x,
                                              style: const TextStyle(
                                                  color: Color(0xFF43536A))))
                                    ]))),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(
                                  child: _detailMetric(
                                      'Weekly Instructional Time',
                                      '${subject['hours_per_week'] ?? _hours[name] ?? 4} Hours')),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _detailMetric(
                                      'Assessment Format', 'SBA + Examination'))
                            ]),
                          ]))),
              Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFF6F8FB),
                  child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close Subject Info'))),
            ])));
  }

  String _description(String name) {
    if (name.toLowerCase().contains('math') ||
        name.toLowerCase().contains('numeracy'))
      return 'Developing number concepts, calculations, patterns, problem-solving and mathematical reasoning.';
    if (name.toLowerCase().contains('language') ||
        name.toLowerCase().contains('english') ||
        name.toLowerCase().contains('sesotho'))
      return 'Listening, speaking, reading, phonics, vocabulary, comprehension and writing development.';
    if (name.toLowerCase().contains('life skills'))
      return 'Personal and social well-being, creative arts, physical education and foundational life skills.';
    return 'CAPS-aligned learning content, skills development and age-appropriate assessment for this grade.';
  }

  List<String> _outcomes(String name) {
    if (name.toLowerCase().contains('math') ||
        name.toLowerCase().contains('numeracy'))
      return [
        'Number concepts and operations',
        'Patterns, functions and problem-solving',
        'Measurement, space and shape'
      ];
    if (name.toLowerCase().contains('language') ||
        name.toLowerCase().contains('english') ||
        name.toLowerCase().contains('sesotho'))
      return [
        'Letter-sound relationships and vocabulary',
        'Reading and comprehension',
        'Writing words and simple sentences'
      ];
    return [
      'Knowledge and understanding of core concepts',
      'Practical participation and skills development',
      'Applying learning in everyday situations'
    ];
  }

  Widget _detailMetric(String label, String value) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F8FB),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFDDE5EF))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF71839B), fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
      ]));
  Color _gradeColor(int index) => [
        const Color(0xFFEF0046),
        const Color(0xFF1747E8),
        const Color(0xFF009C72),
        const Color(0xFF8A00D7),
        const Color(0xFFBD4A00)
      ][index % 5];

  @override
  Widget build(BuildContext context) {
    final selected = _grade;
    return Scaffold(
        appBar: LenyoraPageHeader(
            title: selected == null ? 'Subjects' : '$selected Subjects',
            subtitle: 'CAPS Aligned Curriculum & Outcomes',
            onBack: selected == null
                ? null
                : () => setState(() {
                      _grade = null;
                      _subjects = [];
                    })),
        body: selected == null
            ? ListView(padding: const EdgeInsets.all(18), children: [
                Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.border)),
                    child: const Row(children: [
                      Icon(Icons.menu_book, color: Color(0xFF2463F5), size: 32),
                      SizedBox(width: 15),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('Select Your Grade',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(
                                'Choose a grade to view the subjects available for that grade.',
                                style: TextStyle(color: Color(0xFF60738C)))
                          ]))
                    ])),
                const SizedBox(height: 16),
                ...List.generate(grades.length, (i) {
                  final g = grades[i];
                  return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.border)),
                      child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          leading: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                  color: _gradeColor(i),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('GRADE',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold)),
                                    Text(g.replaceAll('Grade ', ''),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold))
                                  ])),
                          title: Text(g,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17)),
                          subtitle: Text(
                              '${(defaults[g] ?? []).length} CAPS Core Subjects',
                              style: const TextStyle(color: Color(0xFF60738C))),
                          trailing: const Icon(Icons.chevron_right,
                              color: Color(0xFF8CA0B9)),
                          onTap: () => _openGrade(g)));
                })
              ])
            : _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(padding: const EdgeInsets.all(16), children: [
                    Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF0F5FA),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.border)),
                        child: Row(children: [
                          Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: _gradeColor(grades.indexOf(selected)),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Center(
                                  child: Text(selected.replaceAll('Grade ', ''),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold)))),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(selected.toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                const SizedBox(height: 5),
                                Text(
                                    '${_subjects.length} subjects available for this grade.',
                                    style: const TextStyle(
                                        color: Color(0xFF60738C)))
                              ]))
                        ])),
                    const SizedBox(height: 14),
                    ..._subjects.map((s) {
                      final name =
                          '${s['name'] ?? s['subject_name'] ?? 'Subject'}';
                      final isMath = name.toLowerCase().contains('math') ||
                          name.toLowerCase().contains('numeracy');
                      final isLife = name.toLowerCase().contains('life');
                      return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF0F5FA),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.border)),
                          child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              leading: Container(
                                  width: 62,
                                  height: 62,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border:
                                          Border.all(color: AppTheme.border)),
                                  child: Icon(
                                      isMath
                                          ? Icons.calculate_outlined
                                          : isLife
                                              ? Icons.favorite_border
                                              : Icons.abc,
                                      size: 30,
                                      color: Colors.black87)),
                              title: Text(name.toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      height: 1.3)),
                              subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 7),
                                  child: Text(
                                      '${s['learning_area'] ?? (isMath ? 'Mathematics' : isLife ? 'Life Skills & Arts' : 'Languages')}  ·  ${s['hours_per_week'] ?? _hours[name] ?? 4} hrs/week',
                                      style: const TextStyle(
                                          color: Color(0xFF60738C),
                                          fontSize: 12))),
                              trailing: TextButton(
                                  onPressed: () => _showDetails(s),
                                  child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Details'),
                                        Icon(Icons.chevron_right)
                                      ])),
                              onTap: () => _showDetails(s)));
                    })
                  ]),
        bottomNavigationBar: const ParentBottomNavigation(currentIndex: 2));
  }
}
