import 'package:firebase_auth/firebase_auth.dart';

class SignMailFirebase {
  UserCredential _userCredential;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      _userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print('trueeeeeeeeeeeeeeeeeeeeeeeeeeee');
    } on FirebaseAuthException catch (e) {
      print('faaaaaaaaaaaaaaaaaaaaaaaalse');
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    return _userCredential;
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      _userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('trueeeeeeeeeeeeeeeeeeeeeeeeeeee');
    } on FirebaseAuthException catch (e) {
      print('faaaaaaaaaaaaaaaaaaaaaaaalse');
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return _userCredential;
  }
}
