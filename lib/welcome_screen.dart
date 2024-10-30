import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

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
  String? tiendaCodigo;

  @override
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    var box = Hive.box('loginBox');
    String? savedUsername = box.get('username');
    String? savedPassword = box.get('password');
    int? loginTimestamp = box.get('login_timestamp');

    if (savedUsername != null && savedPassword != null && loginTimestamp != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      const sessionDuration = 30 * 60 * 1000; // 30 minutos en milisegundos

      if (currentTime - loginTimestamp < sessionDuration) {
        // Las credenciales aún son válidas
        Navigator.pushReplacementNamed(context, '/main_screen');
        return;
      }
    }

    setState(() {
      showLoginFields = false;
    });
  }

  Future<void> _login() async {
    String username = _userController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage("Por favor, ingrese usuario y contraseña");
      return;
    }

    var loginData = {
      "username": username,
      "password": password,
    };

    try {
      final response = await http.post(
        Uri.parse('https://intranetcorporativo.avantetextil.com/Auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (!data.containsKey('error')) {
          // Guardar las credenciales y el tiempo de autenticación
          var box = Hive.box('loginBox');
          await box.put('username', username);
          await box.put('password', password);
          await box.put('login_timestamp', DateTime.now().millisecondsSinceEpoch);
          // Validación de usuario con 'osuc'
          if (username.startsWith('osuc')) {
            // Extrae los caracteres de la posición 4-6 para el código de tienda
            tiendaCodigo = '2${username.substring(4, 7)}';
            // Redirigir a la pantalla principal y evitar regresar a la pantalla de inicio de sesión
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/main_screen');
            }
          } else {
            // Muestra el cuadro de diálogo para ingresar el número de tienda
            _showTiendaInputDialog(username, password);
            // Redirigir a la pantalla principal y evitar regresar a la pantalla de inicio de sesión
          }
        } else {
          _showMessage(data['error']);
        }
      } else {
        _showMessage("Error en el servidor. Intente nuevamente.");
      }
    } catch (e) {
      _showMessage("Error: $e");
      _showMessage("Error de conexión. Intente nuevamente.");
    }
  }

  void _showTiendaInputDialog(String username, String password) {
    TextEditingController tiendaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ingrese el número de la tienda"),
          content: TextField(
            controller: tiendaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Número de tienda (2001-2999)"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Aceptar"),
              onPressed: () {
                int? tienda = int.tryParse(tiendaController.text);
                if (tienda != null && tienda >= 2001 && tienda <= 2999) {
                  tiendaCodigo = tiendaController.text;
                  // Redirigir a la pantalla principal y evitar regresar a la pantalla de inicio de sesión
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/main_screen');
                  } else {
                    _showMessage("Número de tienda no válido. Intente nuevamente.");
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void toggleLoginFields() {
    setState(() {
      showLoginFields = !showLoginFields;
    });
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
                            controller: _userController, // Asignar el controlador
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
                            controller: _passwordController,
                            obscureText: false,
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