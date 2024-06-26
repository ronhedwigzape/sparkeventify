import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:student_event_calendar/data/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Future<String> signIn({required String email, required String password}) =>
      super.noSuchMethod(
        Invocation.method(#signIn, [], {#email: email, #password: password}),
        returnValue: Future.value('Success'),
        returnValueForMissingStub: Future.value('Failure'),
      );
}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  // Use Case Testing: For Students, CSPC Organization Officers, and Admin
  group("Validate the account's credentials", () {
    test('Sign in with invalid email', () async {
      when(mockAuthRepository.signIn(email: 'invalid_email', password: 'password123'))
          .thenAnswer((_) async => 'Invalid email or password');

      final result = await mockAuthRepository.signIn(email: 'invalid_email', password: 'password123');
      expect(result, 'Invalid email or password');
    });

    test('Sign in with short password', () async {
      when(mockAuthRepository.signIn(email: 'student@my.cspc.edu.ph', password: 'short'))
          .thenAnswer((_) async => 'Invalid email or password');

      final result = await mockAuthRepository.signIn(email: 'student@my.cspc.edu.ph', password: 'short');
      expect(result, 'Invalid email or password');
    });
  });

  // Requirement-Based Testing: Login Test for Student, CSPC Organization Officers, and Admin
  group("User login with valid credentials", () {
    test("The user enters valid login credentials and can successfully enter the system", () async {
      when(mockAuthRepository.signIn(email: 'person@my.cspc.edu.ph', password: 'password123'))
          .thenAnswer((_) async => 'Success');

      var result = await mockAuthRepository.signIn(email: 'person@my.cspc.edu.ph', password: 'password123');
      expect(result, 'Success');
    });

    test("The user enters valid login credentials and is unable to successfully enter the system", () async {
      when(mockAuthRepository.signIn(email: 'person@my.cspc.edu.ph', password: 'password123'))
          .thenThrow(Exception());

      expect(() async => await mockAuthRepository.signIn(email: 'person@my.cspc.edu.ph', password: 'password123'), throwsException);
    });
  });

}