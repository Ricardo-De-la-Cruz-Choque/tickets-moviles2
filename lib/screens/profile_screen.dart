import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final String nombre;
  final String email;
  final String rol;

  const ProfileScreen({
    super.key,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF3B5998),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF3B5998),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 40, indent: 40, endIndent: 40),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Rol en la Municipalidad'),
              subtitle: Text(rol.toUpperCase()),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}