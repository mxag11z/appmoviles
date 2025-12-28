import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/onboarding.dart';
import '../features/auth/screens/login.dart';
import '../features/auth/screens/register.dart';
import '../features/auth/screens/admin_shell.dart';

/// Screens placeholders de prueba
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

/// definicion del router global
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
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: "/estudiante/home",
      builder: (context, state) => const PlaceholderScreen("Home Estudiante"),
    ),
    GoRoute(
      path: "/organizador/home",
      builder: (context, state) => const PlaceholderScreen("Home Organizador"),
    ),
    GoRoute(
      path: "/admin/home",
      builder: (context, state) => const AdminShell(),
    ),
  ],
);
