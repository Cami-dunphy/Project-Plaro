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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        "381063348704-crl2r9amlaer6v747t0hsurj89g076pi.apps.googleusercontent.com",
  );

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

      debugPrint('SignUp response: ${response.user?.email}');

      if (response.user != null) {
        if (response.session != null) {
          debugPrint('SignUp successful with immediate session');
          return true;
        } else {
          debugPrint('SignUp successful - email confirmation required');
          return true;
        }
      } else {
        debugPrint('SignUp failed: No user created');
        return false;
      }
    } catch (e) {
      debugPrint('SignUp error: $e');
      return false;
    }
  }

  /// 🔹 Google Sign-In
  Future<bool> googleSignIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();
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

      if (response.session != null) {
        debugPrint('Google Sign-In successful');
        return true;
      } else {
        debugPrint('Google Sign-In failed: No session created');
        return false;
      }
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      return false;
    }
  }

  /// 🔹 Logout with Google disconnect
  Future<void> logout() async {
    try {
      await ref.read(supAuthProv).signOut();
      debugPrint('User logged out from Supabase');

      // Also disconnect from Google to clear session cache
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
      debugPrint('Google session disconnected');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
