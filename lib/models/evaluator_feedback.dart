class EvaluatorFeedback {
  String userUid;
  String userFullName;
  String userCourse;
  String userDepartment;
  bool satisfactionStatus;
  String studentEvaluation;
  bool attendanceStatus;
  bool isFeedbackDone;

  EvaluatorFeedback({
    required this.userUid,
    required this.userFullName,
    required this.userCourse,
    required this.userDepartment,
    required this.satisfactionStatus,
    required this.studentEvaluation,
    required this.attendanceStatus,
    required this.isFeedbackDone,
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
        'isFeedbackDone': isFeedbackDone,
      };

  // Create Evaluator object from a map
  static EvaluatorFeedback fromMap(Map<String, dynamic> map) {
    return EvaluatorFeedback(
      userUid: map['userUid'],
      userFullName: map['userFullName'],
      userCourse: map['userCourse'],
      userDepartment: map['userDepartment'],
      satisfactionStatus: map['satisfactionStatus'],
      studentEvaluation: map['studentEvaluation'],
      attendanceStatus: map['attendanceStatus'],
      isFeedbackDone: map['isFeedbackDone'],
    );
  }
}
