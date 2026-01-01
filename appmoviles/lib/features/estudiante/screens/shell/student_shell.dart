import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class StudentShell extends StatefulWidget {
  final Widget child;

  const StudentShell({super.key, required this.child});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child, 
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() => index = i);

          switch (i) {
            case 0:
              context.go('/estudiante/home');
              break;
            case 1:
              context.go('/estudiante/calendario');
              break;
            case 2:
              context.go('/estudiante/guardados');
              break;
            case 3:
              context.go('/estudiante/perfil');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            label: 'Guardados',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
