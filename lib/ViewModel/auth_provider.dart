import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

final supAuthProv = Provider((ref) => Supabase.instance.client.auth);

final authStateProvider = StreamProvider((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session,
  );
});

final authControllerProvider = Provider((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  /// 🔹 Email/Password Login
  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await ref
          .read(supAuthProv)
          .signInWithPassword(email: email, password: password);

      return response.session != null;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  /// 🔹 Signup
  Future<bool> logUp({required String email, required String password}) async {
    try {
      final response = await ref
          .read(supAuthProv)
          .signUp(email: email, password: password);

      return response.user != null; // User created, may need email confirm
    } catch (e) {
      debugPrint('SignUp error: $e');
      return false;
    }
  }

  /// 🔹 Logout
  Future<void> logout() async {
    await ref.read(supAuthProv).signOut();
  }

  /// 🔹 Google OAuth Sign-In
  /// 🔹 Google OAuth Sign-In
  Future<bool> googleSignIn() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // IMPORTANT → use Web Client ID from Google Cloud
        serverClientId:
            "381063348704-crl2r9amlaer6v747t0hsurj89g076pi.apps.googleusercontent.com",
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("Google Sign-In cancelled");
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        debugPrint("Google ID Token is null");
        return false;
      }

      final response = await ref
          .read(supAuthProv)
          .signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );

      return response.session != null;
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      return false;
    }
  }
}
