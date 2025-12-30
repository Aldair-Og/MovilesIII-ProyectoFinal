import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  
  Future<void> seleccionarImagen() async {
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (imagen != null) {
      setState(() {
        imagenPerfil = File(imagen.path);
      });
    }
  }

  Future<String?> subirImagenSupabase(String uid) async {
    if (imagenPerfil == null) return null;

    final path = 'usuarios/$uid.jpg';

    await Supabase.instance.client.storage
        .from('avatars')
        .upload(
          path,
          imagenPerfil!,
          fileOptions: const FileOptions(upsert: true),
        );

    final imageUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(path);

    return imageUrl;
  }

  File? imagenPerfil;
  final ImagePicker picker = ImagePicker();

  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController contraseniaController = TextEditingController();

  String generoSeleccionado = 'Masculino';
  bool ocultarContrasenia = true;

  Future<void> guardarRegistro() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: correoController.text.trim(),
            password: contraseniaController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      // Subir imagen a Supabase
      String? fotoUrl = await subirImagenSupabase(uid);

      DatabaseReference ref = FirebaseDatabase.instance.ref('usuarios/$uid');

      await ref.set({
        "usuario": usuarioController.text.trim(),
        "correo": correoController.text.trim(),
        "telefono": telefonoController.text.trim(),
        "genero": generoSeleccionado,
        "foto": fotoUrl ?? "",
        "fecha": DateTime.now().toIso8601String(),
      });

      await FirebaseAuth.instance.signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro exitoso. Inicia sesión")),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error al registrar usuario";

      if (e.code == 'email-already-in-use') {
        mensaje = "El correo ya está registrado";
      } else if (e.code == 'weak-password') {
        mensaje = "La contraseña es muy débil";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo1.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xAA1F2A5A),
                  Color(0xAA47307E),
                  Color(0xFF0E0E0E),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Crear cuenta",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),



                    GestureDetector(
                      onTap: seleccionarImagen,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white24,
                        backgroundImage: imagenPerfil != null
                            ? FileImage(imagenPerfil!)
                            : null,
                        child: imagenPerfil == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 35,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextField(
                      controller: usuarioController,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                        label: "Nombre de usuario",
                        icon: Icons.person,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: correoController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                        label: "Correo electrónico",
                        icon: Icons.email,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: telefonoController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                        label: "Teléfono",
                        icon: Icons.phone,
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: generoSeleccionado,
                      dropdownColor: const Color(0xFF1F1F2E),
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                        label: "Género",
                        icon: Icons.wc,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Masculino',
                          child: Text('Masculino'),
                        ),
                        DropdownMenuItem(
                          value: 'Femenino',
                          child: Text('Femenino'),
                        ),
                        DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          generoSeleccionado = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: contraseniaController,
                      obscureText: ocultarContrasenia,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                        label: "Contraseña",
                        icon: Icons.lock,
                        suffix: IconButton(
                          icon: Icon(
                            ocultarContrasenia
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              ocultarContrasenia = !ocultarContrasenia;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6C4AB6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          guardarRegistro();
                        },
                        child: const Text(
                          "REGISTRARSE",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration inputDecoration({
  required String label,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    prefixIcon: Icon(icon, color: const Color(0xFF6C4AB6)),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.black.withOpacity(0.35),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}
