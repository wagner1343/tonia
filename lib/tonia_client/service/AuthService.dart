import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  static AuthService _instance;
  static AuthService get instance {
    if(_instance == null){
      _instance = new AuthService();
    }

    return _instance;
  }
  Stream<FirebaseUser> currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> loginWithEmailAndPassword(String email, String password) async{
    AuthResult result = await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> registerWithEmailAndPassword(String email, String password) async{
    AuthResult result = await auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async{
    await auth.signOut();
  }

}