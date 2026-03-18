import 'package:easy_localization/easy_localization.dart';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
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
      appBar: AppBar(
        title: Text('auth.register'.tr()),
      ),
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

                Text(
                  'auth.register'.tr(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                /// EMAIL
                TextFormField(
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                  decoration: InputDecoration(
                    labelText: 'auth.email'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// PASSWORD
                TextFormField(
                  controller: controller.passwordController,
                  validator: controller.validatePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'auth.password'.tr(),
                    border: const OutlineInputBorder(),
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
                        onPressed: loading
                            ? null
                            : () async {
                                final success = await controller.register();
                                if (success && context.mounted) {
                                  context.go('/home');
                                }
                              },
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('auth.register_button'.tr()),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                /// VOLTAR PARA LOGIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('auth.already_have_account'.tr()),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text('auth.login'.tr()),
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