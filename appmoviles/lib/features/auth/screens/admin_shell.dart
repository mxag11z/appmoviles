import 'package:flutter/material.dart';
import 'usuarios_admin_screen.dart';
import 'perfil_admin_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    UsuariosAdminScreen(),
    PerfilAdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    assert(_index >= 0 && _index < _pages.length);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people), label: 'Usuarios'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
