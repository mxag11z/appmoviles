import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/onboarding.dart';
import '../features/auth/screens/login.dart';
import '../features/auth/screens/register.dart';
import '../features/auth/screens/forgot_password.dart';
import '../features/auth/screens/reset_password_token.dart';

class PlaceholderScreen extends StatelessWidget {
  final String text;
  const PlaceholderScreen(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: "/onboarding",
  routes: [
    GoRoute(
      path: "/onboarding",
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: "/login",
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: "/register",
      builder: (_, _) => const RegisterScreen(),
    ),

    GoRoute(
      path: "/forgot-password",
      builder: (_, __) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: "/reset-password-form",
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return ResetPasswordWithTokenScreen(email: email);
      },
    ),

    GoRoute(
      path: "/estudiante/home",
      builder: (context, state) =>
          const PlaceholderScreen("Home Estudiante"),
    ),
    GoRoute(
      path: "/organizador/home",
      builder: (context, state) =>
          const PlaceholderScreen("Home Organizador"),
    ),
    GoRoute(
      path: "/admin/home",
      builder: (context, state) => const PlaceholderScreen("Home Admin"),
    ),
  ],
);

