import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:prior_list/controllers/auth_controller.dart';
import 'package:prior_list/repositories/auth_repository.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
      appBar: AppBar(title: const Text('Criar conta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/icons/icon_prior_list.svg',
                  height: 80,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Criar conta',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),

                /// EMAIL
                TextFormField(
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// PASSWORD
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

                /// REGISTER BUTTON
                ValueListenableBuilder<bool>(
                  valueListenable: controller.isLoading,
                  builder: (_, loading, __) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : controller.register,
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Criar conta'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                /// VOLTAR PARA LOGIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Já tem conta?'),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Entrar'),
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