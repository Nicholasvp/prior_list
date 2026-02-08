import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final AuthRepository authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: StreamBuilder<User?>(
          stream: authRepository.authStateChanges, // Escuta mudanças no estado de autenticação
          builder: (context, snapshot) {
            final user = snapshot.data;

            return Column(
              children: [
                // Exibe informações do usuário autenticado
                if (user != null) ...[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? Icon(Icons.person)
                          : null,
                    ),
                    title: Text(user.displayName ?? 'Usuário'),
                    subtitle: Text(user.email ?? ''),
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Sair'),
                    onTap: () async {
                      await authRepository.signOut(); // Realiza logout
                      Navigator.of(context).pop(); // Fecha o Drawer
                    },
                  ),
                ] else ...[
                  // Exibe opções para login
                  ListTile(
                    leading: Icon(Icons.login),
                    title: Text('Login com Google'),
                    onTap: () async {
                      try {
                        await authRepository.signInWithGoogle(); // Login com Google
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao fazer login: $e')),
                        );
                      }
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}