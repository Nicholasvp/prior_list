import 'package:go_router/go_router.dart';
import 'package:prior_list/views/auth/auth_gate.dart';
import 'package:prior_list/views/auth/login_page.dart';
import 'package:prior_list/views/auth/register_page.dart';
import 'package:prior_list/views/home/home_page.dart';


class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthGate(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}