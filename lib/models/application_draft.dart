class ApplicationDraft {
  ApplicationDraft({
    this.parentFullName = '',
    this.parentIdNumber = '',
    this.parentEmail = '',
    this.parentPhone = '',
    this.relationship = '',
    this.parentAddress = '',
    this.learnerFullName = '',
    this.learnerSurname = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.currentSchool = '',
    this.homeLanguage = '',
    this.learnerAddress = '',
    this.age = '',
    this.grade = '',
    this.medicalCondition = '',
    this.doctorNameContact = '',
    this.medicalAidNameNumber = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.disability = '',
    Map<String, String>? documentPaths,
    this.updatedAt,
  }) : documentPaths = documentPaths ?? <String, String>{};

  // Applicant
  String parentFullName;
  String parentIdNumber;
  String parentEmail;
  String parentPhone;
  String relationship;
  String parentAddress;

  // Learner
  String learnerFullName;
  String learnerSurname;
  String dateOfBirth;
  String gender;
  String currentSchool;
  String homeLanguage;
  String learnerAddress;
  String age;
  String grade;

  // Medical
  String medicalCondition;
  String doctorNameContact;
  String medicalAidNameNumber;
  String emergencyContactName;
  String emergencyContactPhone;
  String disability;

  final Map<String, String> documentPaths;
  DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'parentFullName': parentFullName,
        'parentIdNumber': parentIdNumber,
        'parentEmail': parentEmail,
        'parentPhone': parentPhone,
        'relationship': relationship,
        'parentAddress': parentAddress,
        'learnerFullName': learnerFullName,
        'learnerSurname': learnerSurname,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'currentSchool': currentSchool,
        'homeLanguage': homeLanguage,
        'learnerAddress': learnerAddress,
        'age': age,
        'grade': grade,
        'medicalCondition': medicalCondition,
        'doctorNameContact': doctorNameContact,
        'medicalAidNameNumber': medicalAidNameNumber,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'disability': disability,
        'documentPaths': documentPaths,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ApplicationDraft.fromJson(Map<String, dynamic> json) {
    final rawPaths = json['documentPaths'];
    return ApplicationDraft(
      parentFullName: json['parentFullName'] as String? ?? '',
      parentIdNumber: json['parentIdNumber'] as String? ?? '',
      parentEmail: json['parentEmail'] as String? ?? '',
      parentPhone: json['parentPhone'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      parentAddress: json['parentAddress'] as String? ?? '',
      learnerFullName: json['learnerFullName'] as String? ?? '',
      learnerSurname: json['learnerSurname'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      currentSchool: json['currentSchool'] as String? ?? '',
      homeLanguage: json['homeLanguage'] as String? ?? '',
      learnerAddress: json['learnerAddress'] as String? ?? '',
      age: json['age'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      medicalCondition: json['medicalCondition'] as String? ?? '',
      doctorNameContact: json['doctorNameContact'] as String? ?? '',
      medicalAidNameNumber: json['medicalAidNameNumber'] as String? ?? '',
      emergencyContactName: json['emergencyContactName'] as String? ?? '',
      emergencyContactPhone: json['emergencyContactPhone'] as String? ?? '',
      disability: json['disability'] as String? ?? '',
      documentPaths: rawPaths is Map
          ? rawPaths.map((key, value) => MapEntry(key.toString(), value.toString()))
          : <String, String>{},
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}
