import 'dart:convert';
import 'main_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        var nombre = data['nombre'];
        if (!data.containsKey('error')) {
          if (username.startsWith('osuc')) {
            tiendaCodigo = '2${username.substring(4, 7)}';
            if (mounted) {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder: (context) => MainScreen(
                    nombre: nombre,
                    tiendaCodigo: tiendaCodigo ?? '',
                    username: username,
                    password: password,
                  ),
                ),
              );
            }
          } else {
            _showTiendaInputDialog(username, password, nombre);
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

  void _showTiendaInputDialog(String username, String password, String nombre) {
    TextEditingController tiendaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ingrese el número de la tienda"),
          content: TextField(
            controller: tiendaController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Número de tienda (001-999)",
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
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
                if (tienda != null && tienda >= 001 && tienda <= 999) {
                  tiendaCodigo = tiendaController.text;
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(
                          nombre: nombre,
                          tiendaCodigo: tiendaCodigo!,
                          username: username,
                          password: password,
                        ),
                      ),
                    );
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo
                Container(
                  margin: EdgeInsets.only(top: 90.h),
                  child: Image.asset(
                    'assets/images/logo_content.png',
                    width: 150.w, // Ancho adaptable
                    height: 100.h, // Alto adaptable
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  'Bienvenido!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.h),
                if (showLoginFields)
                  Container(
                    margin: EdgeInsets.only(top: 20.h, bottom: 30.h),
                    child: Text(
                      'Inicia Sesión en tu Cuenta',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.only(top: 100.h, bottom: 100.h),
                    child: ElevatedButton(
                      onPressed: toggleLoginFields,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                      ),
                      child: Text(
                        'Inicia Sesión',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20.sp,
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
                        margin: EdgeInsets.symmetric(horizontal: 100.w),
                        //padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: SizedBox(
                          height: 28.h,
                          child: TextField(
                            controller: _userController,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: 'Usuario',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(bottom: 11.5.h),
                            ),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 100.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: SizedBox (
                          height: 28.h,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: 'Contraseña',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8.5.h),
                            ),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.h),
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          ),
                          child: Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: 0.h),
                  child: Text(
                    'Version',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 30.h),
                  child: Text(
                    '2 . 0 . 1',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
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
