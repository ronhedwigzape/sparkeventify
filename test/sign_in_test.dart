import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mock_auth_repository.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  test('signIn success', () async {
    when(mockAuthRepository.signIn(email: 'student@email.com', password: 'password123'))
        .thenAnswer((_) async => 'Success');

    var result = await mockAuthRepository.signIn(email: 'student@email.com', password: 'password123');
    expect(result, 'Success');
  });

  test('signIn failure', () async {
    when(mockAuthRepository.signIn(email: 'student@email.com', password: 'password123'))
        .thenThrow(Exception());

    expect(() async => await mockAuthRepository.signIn(email: 'student@email.com', password: 'password123'), throwsException);
  });
}