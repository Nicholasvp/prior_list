import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:prior_list/controllers/auth_controller.dart';
import 'package:prior_list/repositories/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthController controller;

  @override
  void initState() {
    super.initState();
    controller = AuthController(AuthRepository());

    controller.errorMessage.addListener(() {
      final error = controller.errorMessage.value;
      if (error != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                SvgPicture.asset('assets/icons/icon_prior_list.svg', height: 100),
                const SizedBox(height: 16),

                const Text(
                  'Prior List',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: controller.passwordController,
                  validator: controller.validatePassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                ValueListenableBuilder(
                  valueListenable: controller.isLoading,
                  builder: (_, loading, __) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : controller.login,
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Entrar'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                ValueListenableBuilder(
                  valueListenable: controller.isLoading,
                  builder: (_, loading, __) {
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: loading ? null : controller.loginWithGoogle,
                        child: const Text('Entrar com Google'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem conta?'),
                    TextButton(
                      onPressed: () =>
                          context.go('/register'),
                      child: const Text('Criar conta'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}