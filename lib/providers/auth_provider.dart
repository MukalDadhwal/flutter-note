import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class GoogleAuth extends ChangeNotifier {
  final GoogleSignIn googleSignInInstance;
  Map<String, String> userData = {};

  GoogleAuth(this.googleSignInInstance);

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleAccount =
        await googleSignInInstance.signIn();

    if (googleAccount == null) {
      throw HttpException('Something went wrong while authenticating');
    }

    try {
      final googleAuth = await googleAccount.authentication;

      final userCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(userCredential);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final User currentSignedInUser = FirebaseAuth.instance.currentUser!;

      final userData = json.encode({
        'uid': currentSignedInUser.uid,
        'name': currentSignedInUser.displayName,
        'email': currentSignedInUser.email,
        'photourl': currentSignedInUser.photoURL,
      });

      await prefs.setString('flutternote18', userData);
      notifyListeners();
    } catch (e) {
      throw HttpException(
        'Something went wrong while signing in with your account',
      );
    } finally {
      await googleSignInInstance.disconnect();
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<void> signOutWithGoogle() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {
      throw HttpException('Something went wrong while signing out');
    }
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('flutternote18')) {
      return false;
    }

    final Map map = jsonDecode(prefs.getString('flutternote18')!);

    userData['uid'] = map['uid'];
    userData['email'] = map['email'];
    userData['displayName'] = map['name'];
    userData['photoUrl'] = map['photourl'];

    return true;
  }

  void refreshAuth() {
    notifyListeners();
  }
}
