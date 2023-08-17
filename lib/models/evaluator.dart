class Evaluator {
  String userUid;
  String userFullName;
  String userCourse;
  String userDepartment;
  bool satisfactionStatus;
  String studentEvaluation;
  bool attendanceStatus;

  Evaluator({
    required this.userUid,
    required this.userFullName,
    required this.userCourse,
    required this.userDepartment,
    required this.satisfactionStatus,
    required this.studentEvaluation,
    required this.attendanceStatus,
  });

  // Convert Evaluator object to JSON
  Map<String, dynamic> toJson() => {
        'userUid': userUid,
        'userFullName': userFullName,
        'userCourse': userCourse,
        'userDepartment': userDepartment,
        'satisfactionStatus': satisfactionStatus,
        'studentEvaluation': studentEvaluation,
        'attendanceStatus': attendanceStatus,
      };

  // Create Evaluator object from a map
  static Evaluator fromMap(Map<String, dynamic> map) {
    return Evaluator(
      userUid: map['userUid'],
      userFullName: map['userFullName'],
      userCourse: map['userCourse'],
      userDepartment: map['userDepartment'],
      satisfactionStatus: map['satisfactionStatus'],
      studentEvaluation: map['studentEvaluation'],
      attendanceStatus: map['attendanceStatus'],
    );
  }
}