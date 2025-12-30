import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  File? imagenPerfil;
  final ImagePicker picker = ImagePicker();

  Future<void> cambiarFotoPerfil() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (imagen == null) return;

    final file = File(imagen.path);
    final path = 'usuarios/${user.uid}.jpg';

    // Subir a Supabase
    await Supabase.instance.client.storage
        .from('avatars')
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    // Obtener URL pública
    final imageUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(path);

    // Guardar URL en Firebase
    await FirebaseDatabase.instance
        .ref('usuarios/${user.uid}/foto')
        .set(imageUrl);

    // Actualizar UI
    setState(() {
      fotoUrl = imageUrl;
    });
  }

  String? fotoUrl;
  String? nombre;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref('usuarios/${user.uid}');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        fotoUrl = data['foto'];
        nombre = data['usuario'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// AVATAR
            GestureDetector(
              onTap: cambiarFotoPerfil,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[800],
                backgroundImage: fotoUrl != null && fotoUrl!.isNotEmpty
                    ? NetworkImage(fotoUrl!)
                    : null,
                child: fotoUrl == null || fotoUrl!.isEmpty
                    ? const Icon(
                        Icons.camera_alt,
                        size: 35,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            /// NOMBRE
            Text(
              nombre ?? 'Usuario',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            /// CORREO
            Text(
              user?.email ?? 'Sin correo',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const Spacer(),

            /// CERRAR SESIÓN
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Cerrar sesión",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
