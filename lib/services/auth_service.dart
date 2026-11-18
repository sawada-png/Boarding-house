import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Checks the SMS code the user typed. Signs them in if it's right.
typedef CodeChecker = Future<void> Function(String code);

/// All login and logout calls go through here.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Sends an SMS code to [phone] (format +639XXXXXXXXX) and returns the code checker.
  Future<CodeChecker> sendCode(String phone) async {
    if (kIsWeb) {
      // On web, Firebase shows a reCAPTCHA check before sending.
      final result = await _auth.signInWithPhoneNumber(phone);
      return (code) => result.confirm(code);
    }

    final completer = Completer<CodeChecker>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      // Android can read the SMS by itself and sign in without typing the code.
      verificationCompleted: (credential) => _auth.signInWithCredential(credential),
      verificationFailed: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (verificationId, _) {
        if (completer.isCompleted) return;
        completer.complete(
          (code) =>
              _auth.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code)),
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }

  Future<void> signInWithGoogle() => _signInWith(GoogleAuthProvider());

  // shortcut: uses Firebase's browser login on Android too; switch to the Facebook SDK if
  // that turns out unreliable when we move to Android.
  Future<void> signInWithFacebook() => _signInWith(FacebookAuthProvider());

  Future<void> _signInWith(AuthProvider provider) async {
    if (kIsWeb) {
      await _auth.signInWithPopup(provider);
    } else {
      await _auth.signInWithProvider(provider);
    }
  }

  Future<void> signOut() => _auth.signOut();
}

/// Turns "0912 345 6789", "912-345-6789" or "+63 912..." into "+639123456789".
/// Returns null if it isn't a Philippine mobile number.
String? normalizePhPhone(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('63')) digits = digits.substring(2);
  if (digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length != 10 || !digits.startsWith('9')) return null;
  return '+63$digits';
}

/// Short, friendly message for a login error. Returns null when the user just closed the popup.
String? authErrorMessage(Object error) {
  if (error is! FirebaseAuthException) return 'Something went wrong. Please try again.';
  return switch (error.code) {
    'popup-closed-by-user' || 'cancelled-popup-request' || 'web-context-canceled' => null,
    'invalid-verification-code' => 'Wrong code. Please check the SMS and try again.',
    'invalid-phone-number' => 'That phone number looks wrong.',
    'too-many-requests' => 'Too many tries. Please wait a few minutes.',
    'operation-not-allowed' => 'This login type is not turned on in Firebase yet.',
    'account-exists-with-different-credential' =>
      'This email already uses a different login. Try Google or phone instead.',
    'network-request-failed' => 'No internet connection.',
    _ => error.message ?? 'Login failed. Please try again.',
  };
}
