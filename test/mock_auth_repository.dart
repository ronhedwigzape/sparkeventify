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
