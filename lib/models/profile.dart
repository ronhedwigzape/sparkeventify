class Profile {
  String? fullName;
  String? firstName;
  String? middleInitial;
  String? lastName;
  String? phoneNumber;
  String? department;
  String? program;
  String? year;
  String? section;
  String? position;
  String? organization;
  String? profileImage;

  Profile({
    this.fullName,
    this.firstName,
    this.middleInitial,
    this.lastName,
    this.phoneNumber,
    this.department,
    this.program,
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
        'middleInitial': middleInitial,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'department': department,
        'program': program,
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
      middleInitial: map['middleInitial'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      department: map['department'],
      program: map['program'],
      year: map['year'],
      section: map['section'],
      position: map['position'],
      organization: map['organization'],
      profileImage: map['profileImage'],
    );
  }
}
