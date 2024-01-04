import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalMethods {
  final firestoreInstance = FirebaseFirestore.instance;

  // Get constants document
  Stream<DocumentSnapshot> getConstantsStream() {
    return firestoreInstance.collection('global').doc('constants').snapshots();
  }

  Future<DocumentSnapshot> getConstants() async {
    return await firestoreInstance.collection('global').doc('constants').get();
  }

  // Get all available programs and departments
  Future<List<String>> getProgramsAndDepartments() async {
    DocumentSnapshot documentSnapshot = await getConstants();
    return List<String>.from(documentSnapshot.get('programsAndDepartments'));
  }

  // Get all available programs
  Future<List<String>> getProgramParticipants() async {
    DocumentSnapshot documentSnapshot = await getConstants();
    return List<String>.from(documentSnapshot.get('programParticipants'));
  }

  // Get all available departments
  Future<List<String>> getDepartmentParticipants() async {
    DocumentSnapshot documentSnapshot = await getConstants();
    return List<String>.from(documentSnapshot.get('departmentParticipants'));
  }

  // Get the related programs and departments
  Future<Map<String, String>> getProgramDepartmentMap() async {
    DocumentSnapshot documentSnapshot = await getConstants();
    return Map<String, String>.from(documentSnapshot.get('programDepartmentMap'));
  }

  // Get all available staff positions
  Future<List<String>> getStaffPositions() async {
    DocumentSnapshot documentSnapshot = await getConstants();
    return List<String>.from(documentSnapshot.get('staffPositions'));
  }

  // Insert app constants
  Future<void> insertConstants({
    int? webScreenSize,
    String? schoolName,
    String? schoolAddress,
    String? schoolLogoWhite,
    String? schoolLogoBlack,
    String? schoolLogo,
    String? schoolBackground,
    String? appName,
  }) async {
    await firestoreInstance.collection('global').doc('constants').set({
      'webScreenSize': webScreenSize,
      'schoolName': schoolName,
      'schoolAddress': schoolAddress,
      'schoolLogoWhite': schoolLogoWhite,
      'schoolLogoBlack': schoolLogoBlack,
      'schoolLogo': schoolLogo,
      'schoolBackground': schoolBackground,
      'appName': appName,
    }, SetOptions(merge: true));
  }

  // Update app constants
  Future<void> updateConstants({
    int? webScreenSize,
    String? schoolName,
    String? schoolAddress,
    String? schoolLogoWhite,
    String? schoolLogoBlack,
    String? schoolLogo,
    String? schoolBackground,
    String? appName,
  }) async {
    await firestoreInstance.collection('global').doc('constants').update({
      if (webScreenSize != null) 'webScreenSize': webScreenSize,
      if (schoolName != null) 'schoolName': schoolName,
      if (schoolAddress != null) 'schoolAddress': schoolAddress,
      if (schoolLogoWhite != null) 'schoolLogoWhite': schoolLogoWhite,
      if (schoolLogoBlack != null) 'schoolLogoBlack': schoolLogoBlack,
      if (schoolLogo != null) 'schoolLogo': schoolLogo,
      if (schoolBackground != null) 'schoolBackground': schoolBackground,
      if (appName != null) 'appName': appName,
    });
  }

  // Remove app constants
  Future<void> emptyConstants() async {
    await firestoreInstance.collection('global').doc('constants').update({
      'webScreenSize': 0,
      'schoolName': '',
      'schoolAddress': '',
      'schoolLogoWhite': '',
      'schoolLogoBlack': '',
      'schoolLogo': '',
      'schoolBackground': '',
      'appName': '',
    });
  }

  // Insert program, department, and major description
  Future<bool> insertProgramAndDepartment(String program, String department, String major) async {
    try {
      String programAndDepartment = '$program - $department - $major';

      await firestoreInstance.collection('global').doc('constants').update({
        'programsAndDepartments': FieldValue.arrayUnion([programAndDepartment]),
        'programParticipants': FieldValue.arrayUnion([program]),
        'departmentParticipants': FieldValue.arrayUnion([department]),
        'programDepartmentMap': {program: department},
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Update program, department, and major description
  Future<bool> updateProgramAndDepartment(String oldProgram, String oldDepartment, String oldMajor, String newProgram, String newDepartment, String newMajor) async {
    try {
      String oldProgramAndDepartment = '$oldProgram - $oldDepartment - $oldMajor';
      String newProgramAndDepartment = '$newProgram - $newDepartment - $newMajor';

      DocumentSnapshot documentSnapshot = await getConstants();
      Map<String, dynamic> constants = documentSnapshot.data() as Map<String, dynamic>;
      Map<String, String> programDepartmentMap = Map<String, String>.from(constants['programDepartmentMap']);

      programDepartmentMap.remove(oldProgram);
      programDepartmentMap[newProgram] = newDepartment;

      await firestoreInstance.collection('global').doc('constants').update({
        'programsAndDepartments': FieldValue.arrayRemove([oldProgramAndDepartment]),
        'programParticipants': FieldValue.arrayRemove([oldProgram]),
        'departmentParticipants': FieldValue.arrayRemove([oldDepartment]),
        'programDepartmentMap': programDepartmentMap,
      });

      await firestoreInstance.collection('global').doc('constants').update({
        'programsAndDepartments': FieldValue.arrayUnion([newProgramAndDepartment]),
        'programParticipants': FieldValue.arrayUnion([newProgram]),
        'departmentParticipants': FieldValue.arrayUnion([newDepartment]),
        'programDepartmentMap': programDepartmentMap,
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Remove program, department, and major description
  Future<bool> emptyProgramAndDepartment(String program, String department, String major) async {
    try {
      String programAndDepartment = '$program - $department - $major';

      DocumentSnapshot documentSnapshot = await getConstants();
      Map<String, dynamic> constants = documentSnapshot.data() as Map<String, dynamic>;
      Map<String, String> programDepartmentMap = Map<String, String>.from(constants['programDepartmentMap']);

      programDepartmentMap.remove(program);

      await firestoreInstance.collection('global').doc('constants').update({
        'programsAndDepartments': FieldValue.arrayRemove([programAndDepartment]),
        'programParticipants': FieldValue.arrayRemove([program]),
        'departmentParticipants': FieldValue.arrayRemove([department]),
        'programDepartmentMap': programDepartmentMap,
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Insert Staff Position details
  Future<bool> insertStaffPosition(String staffPosition, String staffDescription, String staffType) async {
    try {
      String fullStaffPosition = '$staffPosition - $staffDescription - $staffType';

      await firestoreInstance.collection('global').doc('constants').update({
        'staffPositions': FieldValue.arrayUnion([fullStaffPosition]),
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Update Staff Position details
  Future<bool> updateStaffPosition(String oldStaffPosition, String newStaffPosition, String newStaffDescription, String newStaffType) async {
    try {
      String fullNewStaffPosition = '$newStaffPosition - $newStaffDescription - $newStaffType';

      await firestoreInstance.collection('global').doc('constants').update({
        'staffPositions': FieldValue.arrayRemove([oldStaffPosition]),
      });

      await firestoreInstance.collection('global').doc('constants').update({
        'staffPositions': FieldValue.arrayUnion([fullNewStaffPosition]),
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Remove Staff Position
  Future<bool> emptyStaffPosition(String staffPosition) async {
    try {
      await firestoreInstance.collection('global').doc('constants').update({
        'staffPositions': FieldValue.arrayRemove([staffPosition]),
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

}