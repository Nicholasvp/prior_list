import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prior_list/repositories/auth_repository.dart';

class AuthController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  /// ================= FORM =================
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// ================= STATE =================
  final isLoading = ValueNotifier<bool>(false);
  final errorMessage = ValueNotifier<String?>(null);
  final user = ValueNotifier<User?>(null);

  bool get isLoggedIn => _authRepository.isLoggedIn;

  /// ================= ACTIONS =================
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _authRepository.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      user.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _authRepository.signUpWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      user.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authRepository.signInWithGoogle();
      user.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// ================= VALIDATORS =================
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Digite seu email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Digite sua senha';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  /// ================= HELPERS =================
  void _setLoading(bool value) => isLoading.value = value;
  void _clearError() => errorMessage.value = null;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    user.dispose();
  }
}
