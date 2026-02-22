import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/repositories/auth_repository.dart';
import 'package:prior_list/views/auth/login_page.dart';
import 'package:prior_list/views/home/home_page.dart';

class AuthGate extends StatelessWidget {
  

  const AuthGate({super.key,});

  @override
  Widget build(BuildContext context) {
    final authRepository = autoInjector.get<AuthRepository>();
    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {

        // 🔹 Loading enquanto verifica sessão
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔹 Se não estiver logado → Login
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // 🔹 Se estiver logado → Home
        return const HomePage();
      },
    );
  }
}