import 'package:easy_localization/easy_localization.dart';
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
          stream: authRepository.authStateChanges,
          builder: (context, snapshot) {
            final user = snapshot.data;

            return ListView(
              children: [
                /// USER INFO
                if (user != null) ...[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(user.displayName ?? 'User'),
                    subtitle: Text(user.email ?? ''),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text('auth.logout'.tr()),
                    onTap: () async {
                      await authRepository.signOut();
                      Navigator.of(context).pop();
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: Text('auth.login_google'.tr()),
                    onTap: () async {
                      try {
                        await authRepository.signInWithGoogle();
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                  ),
                ],

                const Divider(),

                ExpansionTile(
                  leading: const Icon(Icons.language),
                  title: Text('language.title'.tr()),
                  children: [
                    ListTile(
                      leading: const Text("🇬🇧"),
                      title: Text('language.english'.tr()),
                      onTap: () {
                        context.setLocale(const Locale('en'));
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Text("🇧🇷"),
                      title: Text('language.portuguese'.tr()),
                      onTap: () {
                        context.setLocale(const Locale('pt'));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),

                // 👇 Empurra o botão para baixo da tela
                SizedBox(height: MediaQuery.of(context).size.height * 0.4),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'auth.delete_account'.tr(),
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    // ... mesmo código de antes
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
