import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider {


 Future<UserCredential> signInAnonymously() async{
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      log("Signed in with temporary account.");
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          log("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          log("Unknown error.");
      }
      rethrow;
  }
  }

}