import 'package:appmoviles/features/estudiante/screens/shell/student_shell.dart';
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
import '../features/auth/screens/forgot_password.dart';
import '../features/auth/screens/reset_password_token.dart';

import 'package:appmoviles/features/estudiante/screens/home/home_student.dart';
import 'package:appmoviles/features/estudiante/screens/evento_detalle/evento_detalle_screen.dart';
import 'package:appmoviles/features/estudiante/screens/guardados/mis_eventos_screen.dart';
import 'package:appmoviles/features/estudiante/screens/perfil/perfil_screen.dart';
import 'package:appmoviles/features/estudiante/screens/calendario/calendario_screen.dart';
import 'package:appmoviles/data/models/evento_model.dart';


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
    // =========================
    // AUTH (sin shell)
    // =========================
    GoRoute(path: "/onboarding", builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: "/login", builder: (_, __) => const LoginScreen()),
    GoRoute(path: "/register", builder: (_, _) => const RegisterScreen()),

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

    // =========================
    // DETALLE DE EVENTO (sin shell/navbar)
    // =========================
    GoRoute(
      path: "/estudiante/evento",
      builder: (context, state) {
        final evento = state.extra as Evento;
        return EventoDetalleScreen(evento: evento);
      },
    ),

    // =========================
    // ESTUDIANTE (con shell/navbar)
    // =========================
    ShellRoute(
      builder: (context, state, child) {
        return StudentShell(child: child);
      },
      routes: [
        GoRoute(
          path: "/estudiante/home",
          builder: (_, __) => const HomeScreen(),
        ),

        // placeholders por ahora (pon aquí tus pantallas reales)
        GoRoute(
          path: "/estudiante/calendario",
          builder: (_, __) => const CalendarioScreen(),
        ),
        GoRoute(
          path: "/estudiante/guardados",
          builder: (_, __) => const MisEventosScreen(),
        ),
        GoRoute(
          path: "/estudiante/perfil",
          builder: (_, __) => const PerfilScreen(),
        ),
      ],
    ),

    // =========================
    // ORGANIZADOR / ADMIN (sin shell por ahora)
    // =========================
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
