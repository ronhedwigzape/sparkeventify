import '../resources/auth_methods.dart';

class AuthRepository {
  Future<String> signIn({ required String email, required String password,}) =>
      AuthMethods().signIn(email: email, password: password);
}
