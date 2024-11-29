import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hive/hive.dart';
import 'package:network_info_plus/network_info_plus.dart';
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
  bool _obscurePassword = true;
  String tiendaCodigo = '';
  String nombreTienda = '';
  String ipAddress = '';
  String macAddress = '';
  String deviceName = '';

  @override
  void initState() {
    super.initState();
    _loadLastUser();
  }

    Future<void> displayDeviceInfo() async {
    ipAddress = await getIpAddress();
    macAddress = await getMacAddress();
    deviceName = await getDeviceName();

    // Imprimir los datos en consola
    debugPrint('Dirección IP: $ipAddress');
    debugPrint('Dirección MAC: $macAddress');
    debugPrint('Nombre del dispositivo: $deviceName');
  }

  Future<void> _loadLastUser() async {
    var box = await Hive.openBox('userBox');
    String? lastUser = box.get('lastUser');
    if (lastUser != null) {
      _userController.text = lastUser;
    }
  }

  Future<void> _saveUser(String username) async {
    var box = await Hive.openBox('userBox');
    await box.put('lastUser', username);
  }

  Future<void> sendDeviceData(String username) async {
    final url = Uri.parse('https://intranetcorporativo.avantetextil.com/Auth/registerDevice');
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'ci_session=bae0ded296e633fbf6ccade6d81e2db5664f28ff',
    };
    final body = jsonEncode({
      'ipAddress': ipAddress = await getIpAddress(),
      'macAddress': macAddress = await getMacAddress(),
      'deviceName': deviceName = await getDeviceName(),
      'username': username
    });
    
    debugPrint(body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        debugPrint('Los datos se insertaron exitosamente');
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Excepción: $e');
    }
  }


  Future<void> _login() async {
    String username = _userController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage("Por favor, ingrese usuario y contraseña");
      return;
    }

    if (username.isNotEmpty) {
      await _saveUser(username);
    }

    var loginData = {
      "username": username,
      "password": password,
    };

    http.Client client = http.Client();

    try {
      final response = await client.post(
        Uri.parse('https://intranetcorporativo.avantetextil.com/Auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        displayDeviceInfo();
        sendDeviceData(username);
        var data = jsonDecode(response.body);
        var nombre = data['nombre'];
        if (!data.containsKey('error')) {
          if (username.startsWith('osuc')) {
            tiendaCodigo = username.substring(4, 7);
            if (mounted) {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder: (context) => MainScreen(
                    nombre: nombre,
                    nombreTienda: nombreTienda,
                    tiendaCodigo: tiendaCodigo,
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
    } finally {
      client.close();
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
                  fetchStoreName(username, password, nombre);
                }
              },
            ),
          ],
        );
      },
    );
  }

    // Función para realizar el POST
  Future<void> fetchStoreName(String username, String password, String nombre) async {
    final url = 'https://intranetcorporativo.avantetextil.com/Store/store_name/osuc$tiendaCodigo';

    http.Client client = http.Client();

    try {
      final response = await client.post(Uri.parse(url));

      if (response.statusCode == 200) {
        // Obtiene la respuesta como JSON
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['displayname'] == 'Generico') {
          if (mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Número de tienda no existe. Intenta de nuevo.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Aceptar'),
                    ),
                  ],
                );
              },
            );
          }
          return;
        }

        setState(() {
          if (data.containsKey('displayname') && data['displayname'] is String) {
            String displayName = data['displayname'];
            
            // Verifica si termina en un número de tres dígitos
            final regex = RegExp(r'\d{3}$');
            if (regex.hasMatch(displayName)) {
              nombreTienda = displayName.substring(0, displayName.length - 3); // Elimina los últimos tres caracteres
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(
                      nombre: nombre,
                      nombreTienda: nombreTienda,
                      tiendaCodigo: tiendaCodigo,
                      username: username,
                      password: password,
                    ),
                  ),
                );
              } 
            } else {
              nombreTienda = displayName; // Almacena el nombre sin cambios
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(
                      nombre: nombre,
                      nombreTienda: nombreTienda,
                      tiendaCodigo: tiendaCodigo,
                      username: username,
                      password: password,
                    ),
                  ),
                );
              }
            }
          } else {
            _showMessage('Nombre de tienda no existe');
          }
        });
      } else {
        _showMessage('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
    } finally {
      client.close();
    }
  }

  Future<String> getIpAddress() async {
    final info = NetworkInfo();
    return await info.getWifiIP() ?? 'No disponible';
  }

  Future<String> getMacAddress() async {
    final info = NetworkInfo();
    return await info.getWifiBSSID() ?? 'No disponible';
  }

  Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine;
    }
    return 'No disponible';
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

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 30.h,
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
                                    contentPadding: EdgeInsets.only(bottom: 12.5.h, left: 15.w),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 0.w, right: 14),
                              child: Icon(
                                Icons.person,
                                color: Colors.grey.shade500,
                                size: 15.h, // Tamaño ajustado del icono
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 100.w, vertical: 10.h),
                        padding: EdgeInsets.only(left: 30.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: SizedBox (
                          height: 30.h,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    hintText: 'Contraseña',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(bottom: 13.h),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10.5.sp,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                  size: 15.h, // Tamaño ajustado
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ],
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
                    '1 . 0 . 0',
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
