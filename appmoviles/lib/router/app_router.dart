import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/onboarding.dart';
import '../features/auth/screens/login.dart';
import '../features/auth/screens/register.dart';
import '../features/organizer_organizador.dart';
import '../features/register_event_organizador.dart';
import '../features/mis_eventos_screen_organizador.dart';
import '../features/eventos_aprobados_organizador.dart';
import '../features/todos_eventos_usuarioGeneral.dart';
import '../features/asistentes_evento_organizador.dart';

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
      builder: (_, _) => const RegisterScreen(),
    ),
    GoRoute(
      path: "/estudiante/home",
      builder: (context, state) =>
          const PlaceholderScreen("Home Estudiante"),
    ),
    GoRoute(
      path: "/organizador/home",
      builder: (context, state) => const OrganizerHomeScreen(),
    ),
    GoRoute(
      path: "/admin/home",
      builder: (context, state) => const PlaceholderScreen("Home Admin"),
    ),
    GoRoute(
      path: "/organizador/registrar_evento",
      builder: (context, state) => const RegisterEventScreen(), 
    ),
    GoRoute(
      path: "/organizador/mis_eventos",
      builder: (context, state) => const MisEventosScreen(),
    ),
    GoRoute(
      path: "/organizador/eventos-aprobados",
      builder: (context, state) => const EventosAprobadosScreen(),
    ),
    GoRoute(
      path: "/all-eventos",
      builder: (context, state) => const AllEventosScreen(),
    ),
    GoRoute(
      path: '/organizador/evento/:eventoId/invitados',
      builder: (context, state) {
        final eventoId = state.pathParameters['eventoId']!;
        return AsistentesEventosScreen(eventoId: eventoId);
      },
    ),

  ],
);
