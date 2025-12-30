import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taller1/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contraseniaController = TextEditingController();

  bool _ocultarContrasenia = true;

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

                  const Spacer(),

                  const Text(
                    "Iniciar sesión",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: correoController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      label: "Correo electrónico",
                      icon: Icons.email,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: contraseniaController,
                    obscureText: _ocultarContrasenia,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      label: "Contraseña",
                      icon: Icons.lock,
                      suffix: IconButton(
                        icon: Icon(
                          _ocultarContrasenia
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _ocultarContrasenia = !_ocultarContrasenia;
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
                      onPressed: () => login(
                        correoController,
                        contraseniaController,
                        context,
                      ),
                      child: const Text(
                        "INICIAR SESIÓN",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      restaurar(correoController.text.trim(), context);
                    },
                    child: const Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    prefixIcon: Icon(icon, color: Color(0xFF6C4AB6)),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.black.withOpacity(0.35),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}

Future<void> login(
  TextEditingController correo,
  TextEditingController contrasenia,
  BuildContext context,
) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo.text.trim(),
      password: contrasenia.text.trim(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } on FirebaseAuthException catch (e) {
    String mensaje = "Error al iniciar sesión";

    if (e.code == 'user-not-found') {
      mensaje = "Usuario no encontrado";
    } else if (e.code == 'wrong-password') {
      mensaje = "Contraseña incorrecta";
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }
}

Future<void> restaurar(String correo, BuildContext context) async {
  await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color(0xFF1F1F2E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: const Text(
        "Se ha enviado un correo para restablecer la contraseña",
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}
