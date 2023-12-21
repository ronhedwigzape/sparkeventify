class EvaluatorFeedback {
  String? userUid;
  String? userFullName;
  String? userProgram;
  String? userDepartment;
  bool? satisfactionStatus;
  String? studentEvaluation;
  bool? attendanceStatus;
  bool? isFeedbackDone;

  EvaluatorFeedback({
    this.userUid,
    this.userFullName,
    this.userProgram,
    this.userDepartment,
    this.satisfactionStatus,
    this.studentEvaluation,
    this.attendanceStatus,
    this.isFeedbackDone,
  });

  // Convert Evaluator object to JSON
  Map<String, dynamic> toJson() => {
        'userUid': userUid,
        'userFullName': userFullName,
        'userProgram': userProgram,
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
      userProgram: map['userProgram'],
      userDepartment: map['userDepartment'],
      satisfactionStatus: map['satisfactionStatus'],
      studentEvaluation: map['studentEvaluation'],
      attendanceStatus: map['attendanceStatus'],
      isFeedbackDone: map['isFeedbackDone'],
    );
  }
}
