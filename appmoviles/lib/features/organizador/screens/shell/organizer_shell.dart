import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrganizerShell extends StatefulWidget {
  final Widget child;

  const OrganizerShell({super.key, required this.child});

  @override
  State<OrganizerShell> createState() => _OrganizerShellState();
}

class _OrganizerShellState extends State<OrganizerShell> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndexFromLocation();
  }

  void _updateIndexFromLocation() {
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains('/organizador/home')) {
      _currentIndex = 0;
    } else if (location.contains('/organizador/mis-eventos')) {
      _currentIndex = 1;
    } else if (location.contains('/organizador/perfil')) {
      _currentIndex = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);

          switch (index) {
            case 0:
              context.go('/organizador/home');
              break;
            case 1:
              context.go('/organizador/mis-eventos');
              break;
            case 2:
              context.go('/organizador/perfil');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Mis Eventos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/organizador/registrar-evento');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo evento'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
    );
  }
}
