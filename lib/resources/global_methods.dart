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
    return Map<String, String>.from(
        documentSnapshot.get('programDepartmentMap'));
  }

  // Get all available staff positions
  Future<List<String>> getStaffPositions() async {
    DocumentSnapshot documentSnapshot = await getConstants();
    return List<String>.from(documentSnapshot.get('staffPositions'));
  }

  // Get all available programs
  Future<List<String>> getOrganizations() async {
    DocumentSnapshot documentSnapshot = await getConstants();
    return List<String>.from(documentSnapshot.get('organizations'));
  }

  Future<Map<String, String>> getProgramDepartmentWithOrganizationMap() async {
    DocumentSnapshot documentSnapshot = await getConstants();
    return Map<String, String>.from(documentSnapshot.get(
        'programDepartmentWithOrganization')); // BLIS - CCS - Information Science: "JPCS - CSPC Chapter"
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
  Future<bool> insertProgramAndDepartment(
      String program, String department) async {
    try {
      DocumentSnapshot documentSnapshot = await getConstants();
      if (documentSnapshot.exists) {
        List<String> programsAndDepartments = List<String>.from(
            documentSnapshot.get('programsAndDepartments') ?? []);
        String programAndDepartment = '$program - $department';

        // Check for existing entry
        if (programsAndDepartments.contains(programAndDepartment)) {
          print("Program and Department already exists. Skipping insert.");
          return false;
        }

        await firestoreInstance.collection('global').doc('constants').update({
          'programsAndDepartments':
              FieldValue.arrayUnion([programAndDepartment]),
        });

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Update program, department, and major description
  Future<bool> updateProgramAndDepartment(String oldProgram,
      String oldDepartment, String newProgram, String newDepartment) async {
    try {
      DocumentSnapshot documentSnapshot = await getConstants();
      if (documentSnapshot.exists) {
        List<String> programsAndDepartments = List<String>.from(
            documentSnapshot.get('programsAndDepartments') ?? []);
        String oldProgramAndDepartment = '$oldProgram - $oldDepartment';
        String newProgramAndDepartment = '$newProgram - $newDepartment';

        // Remove old entry if exists
        programsAndDepartments.remove(oldProgramAndDepartment);

        await firestoreInstance.collection('global').doc('constants').update({
          'programsAndDepartments':
              FieldValue.arrayRemove([oldProgramAndDepartment]),
        });
        await firestoreInstance.collection('global').doc('constants').update({
          'programsAndDepartments':
              FieldValue.arrayUnion([newProgramAndDepartment]),
        });

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Remove program, department, and major description
  Future<bool> emptyProgramAndDepartment(
      String program, String department) async {
    try {
      String programAndDepartment = '$program - $department';

      DocumentSnapshot documentSnapshot = await getConstants();
      Map<String, dynamic> constants =
          documentSnapshot.data() as Map<String, dynamic>;
      Map<String, String> programDepartmentMap =
          Map<String, String>.from(constants['programDepartmentMap']);

      programDepartmentMap.remove(program);

      await firestoreInstance.collection('global').doc('constants').update({
        'programsAndDepartments':
            FieldValue.arrayRemove([programAndDepartment]),
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
  Future<bool> insertStaffPosition(
      String staffPosition, String staffDescription, String staffType) async {
    try {
      String fullStaffPosition =
          '$staffPosition - $staffDescription - $staffType';

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
  Future<bool> updateStaffPosition(
      String oldStaffPosition,
      String newStaffPosition,
      String newStaffDescription,
      String newStaffType) async {
    try {
      String fullNewStaffPosition =
          '$newStaffPosition - $newStaffDescription - $newStaffType';

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

  // Insert Organization with Proponent
  Future<bool> insertOrganization(String organizationWithProponent) async {
    try {
      DocumentSnapshot documentSnapshot = await getConstants();
      if (documentSnapshot.exists) {
        List<String> organizations =
            List<String>.from(documentSnapshot.get('organizations') ?? []);

        // Check for existing organization
        if (organizations.contains(organizationWithProponent)) {
          print("Organization already exists. Skipping insert.");
          return false;
        }

        await firestoreInstance.collection('global').doc('constants').update({
          'organizations': FieldValue.arrayUnion([organizationWithProponent]),
        });

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Update Organization with Proponent
  Future<bool> updateOrganization(
      String oldOrganization, String newOrganization,
      {String? oldProponent, String? newProponent}) async {
    try {
      DocumentSnapshot documentSnapshot = await getConstants();
      if (documentSnapshot.exists) {
        await firestoreInstance.collection('global').doc('constants').update({
          'organizations': FieldValue.arrayRemove([oldOrganization]),
        });
        await firestoreInstance.collection('global').doc('constants').update({
          'organizations': FieldValue.arrayUnion([newOrganization]),
        });

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Delete Organization with Proponent
  Future<bool> deleteOrganization(String organizationWithProponent) async {
    try {
      await firestoreInstance.collection('global').doc('constants').update({
        'organizations': FieldValue.arrayRemove([organizationWithProponent]),
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> insertProgramDepartmentWithOrganization(
      String program, String department, String organization,
      {String? proponent}) async {
    try {
      DocumentSnapshot documentSnapshot = await getConstants();
      if (documentSnapshot.exists) {
        List<dynamic> programDepartmentWithOrganization = List.from(
            documentSnapshot.get('programDepartmentWithOrganization') ?? []);
        String key = '$program - $department';
        String value = proponent?.isNotEmpty == true
            ? '$organization - $proponent'
            : organization;

        // Check if the entry already exists with the same key and value
        var existingEntry = programDepartmentWithOrganization.firstWhere(
            (element) =>
                element.keys.first == key && element.values.first == value,
            orElse: () => null);
        if (existingEntry != null) {
          // Entry already exists, no need to insert
          print("Entry already exists. Skipping insert.");
          return false;
        }

        // Proceed with insertion since entry does not exist
        programDepartmentWithOrganization.add({key: value});
        await firestoreInstance.collection('global').doc('constants').update({
          'programDepartmentWithOrganization':
              programDepartmentWithOrganization,
        });

        await insertProgramAndDepartment(program, department);
        await insertOrganization(value);

        return true;
      } else {
        print("Constants document does not exist.");
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }


  Future<bool> updateProgramDepartmentWithOrganization(
    String oldProgram,
    String oldDepartment,
    String newProgram,
    String newDepartment,
    String oldOrganization,
    String newOrganization,
    {String? oldProponent,
    String? newProponent}) async {
    try {
      // Update program and department if they have changed
      if (oldProgram != newProgram || oldDepartment != newDepartment) {
        await updateProgramAndDepartment(
          oldProgram, oldDepartment, newProgram, newDepartment);
      }

      // Update organization if it has changed
      if (oldOrganization != newOrganization || oldProponent != newProponent) {
        await updateOrganization(
          oldOrganization, newOrganization,
          oldProponent: oldProponent, newProponent: newProponent);
      }

      DocumentSnapshot documentSnapshot = await getConstants();
      if (documentSnapshot.exists) {
        var programDepartmentWithOrganization = List.from(
            documentSnapshot.get('programDepartmentWithOrganization') ?? []);
        String oldKey = '$oldProgram - $oldDepartment';
        String oldValue = oldProponent?.isNotEmpty == true
            ? '$oldOrganization - $oldProponent'
            : oldOrganization;
        String newKey = '$newProgram - $newDepartment';
        String newValue = newProponent?.isNotEmpty == true
            ? '$newOrganization - $newProponent'
            : newOrganization;

          // Find and remove the old entry
          programDepartmentWithOrganization.removeWhere((element) =>
              element.keys.first == oldKey && element.values.first == oldValue);

          // Add the new entry
          programDepartmentWithOrganization.add({newKey: newValue});

          // Update Firestore with the modified list
          await firestoreInstance.collection('global').doc('constants').update({
            'programDepartmentWithOrganization': programDepartmentWithOrganization,
          });
        return true;
      } else {
        print("Constants document does not exist.");
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteProgramDepartmentWithOrganization(String program, String department) async {
    try {
      // Fetch the current constants document to get the existing 'programDepartmentWithOrganization' array
      DocumentSnapshot documentSnapshot = await firestoreInstance.collection('global').doc('constants').get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        var programDepartmentWithOrganization = List.from(data['programDepartmentWithOrganization'] ?? []);

        // The key to find and remove
        String keyToRemove = '$program - $department';

        // Remove the entry with the matching key
        programDepartmentWithOrganization.removeWhere((entry) {
          var entryKey = entry.keys.first;
          return entryKey == keyToRemove;
        });

        // Update the document without the removed entry
        await firestoreInstance.collection('global').doc('constants').update({
          'programDepartmentWithOrganization': programDepartmentWithOrganization,
        });

        // await deleteOrganization(organizationWithProponent)

        await emptyProgramAndDepartment(program, department);

        return true;
      } else {
        print("Document does not exist.");
        return false;
      }
    } catch (e) {
      print("Error deleting program and department: $e");
      return false;
    }
  }

}
