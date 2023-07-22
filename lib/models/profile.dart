class Profile {
  String? fullName;
  String? phoneNumber;
  String? department;
  String? course;
  String? year;
  String? section;
  String? profileImage;

  Profile({
    this.fullName,
    this.phoneNumber,
    this.department,
    this.course,
    this.year,
    this.section,
    this.profileImage,
  });

  // Convert Profile object to JSON
  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'department': department,
    'course': course,
    'year': year,
    'section': section,
    'profileImage': profileImage,
  };

  // Create Profile object from a map
  static Profile fromMap(Map<String, dynamic> map) {
    return Profile(
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      department: map['department'],
      course: map['course'],
      year: map['year'],
      section: map['section'],
      profileImage: map['profileImage'],
    );
  }
}
