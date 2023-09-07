class Profile {
  String? fullName;
  String? firstName;
  String? middleName;
  String? lastName;
  String? phoneNumber;
  String? department;
  String? course;
  String? year;
  String? section;
  String? position;
  String? organization;
  String? profileImage;

  Profile({
    this.fullName,
    this.firstName,
    this.middleName,
    this.lastName,
    this.phoneNumber,
    this.department,
    this.course,
    this.year,
    this.section,
    this.position,
    this.organization,
    this.profileImage,
  });

  // Convert Profile object to JSON
  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'department': department,
        'course': course,
        'year': year,
        'section': section,
        'position': position,
        'organization': organization,
        'profileImage': profileImage,
      };

  // Create Profile object from a map
  static Profile fromMap(Map<String, dynamic> map) {
    return Profile(
      fullName: map['fullName'],
      firstName: map['firstName'],
      middleName: map['middleName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      department: map['department'],
      course: map['course'],
      year: map['year'],
      section: map['section'],
      position: map['position'],
      organization: map['organization'],
      profileImage: map['profileImage'],
    );
  }
}
