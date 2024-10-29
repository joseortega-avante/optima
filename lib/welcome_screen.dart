import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() {
    return WelcomeScreenState();
  }
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool showLoginFields = false;

  void toggleLoginFields() {
    setState(() {
      showLoginFields = true;
    });
  }

  Future<void> _login() async {
    String username = _userController.text.trim();
    String password = _passwordController.text.trim();
    // ignore: unused_local_variable, no_leading_underscores_for_local_identifiers
    bool _isLoading = false;

    // Validaciones
    if (username.isEmpty || password.isEmpty) {
      _showMessage('Por favor, ingresa usuario y contraseña');
      return;
    }

    // JSON para el envío
    Map<String, String> loginData = {
      'username': username,
      'password': password,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://intranetcorporativo.avantetextil.com/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          _showMessage('Login exitoso');
          // Navegar a la siguiente pantalla o realizar otra acción aquí
        } else {
          _showMessage(data['message'] ?? 'Usuario o contraseña incorrectos');
        }
      } else {
        _showMessage('Error en el servidor');
      }
    } catch (e) {
      _showMessage('Error al conectar con el servidor');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', // Reemplaza con tu imagen de fondo
              fit: BoxFit.cover,
            ),
          ),
          // Contenido de la pantalla
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo
                Container(
                  margin: const EdgeInsets.only(top: 250),
                  child: Image.asset(
                    'assets/images/logo_content.png',
                  ),
                ),
                // Texto "Bienvenido!"
                const SizedBox(height: 20),
                const Text(
                  'Bienvenido!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Texto "Inicia Sesión en tu Cuenta"
                if (showLoginFields)
                  Container (
                    margin: const EdgeInsets.only(top: 20, bottom: 30),
                    child: const Text(
                        'Inicia Sesión en tu Cuenta',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                  )
                else
                  // Botón de "Inicia Sesión"
                  Container(
                    margin: const EdgeInsets.only(top: 50, bottom: 100),
                    child: ElevatedButton(
                      onPressed: toggleLoginFields,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: const Text(
                        'Inicia Sesión',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (showLoginFields)
                  Column(
                    children: [
                      // Campo de usuario
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 100),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Usuario',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(bottom: 13)
                            ),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 13
                            ),
                          ),
                        ),
                      ),
                      // Campo de contraseña
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            obscureText: true,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Contraseña',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(bottom: 13)
                            ),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      // Botón de iniciar sesión
                      Container (
                        margin: const EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14, 
                              color: Colors.white
                              ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const Spacer(),
                // Versión de la aplicación
                const Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Text(
                    'Version',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    '2 . 0 . 1',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}