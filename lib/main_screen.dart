import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:optima/welcome_screen.dart';
import 'dart:convert';
import 'result_screen.dart';

class MainScreen extends StatefulWidget {
  final String nombre;
  final String tiendaCodigo;
  final String username;
  final String password;

  const MainScreen({super.key, required this.nombre, required this.tiendaCodigo, required this.username, required this.password});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  String nombreTienda = '';
  String codigo = '';
  String tiendaNum = '';
  late double precioInicial;
  late double precioActual;
  String precioPromo = '';
  String descripcion = '';
  String material = '';
  String promo = '';
  String piso = '';
  String bodega = '';
  String transito = '';
  String promoNombre = '';
  String promoDesc = '';
  String usuario = '';
  String contrasena = '';

  // Función para realizar el POST
  Future<void> fetchStoreName() async {
    final url = 'https://intranetcorporativo.avantetextil.com/Store/store_name/osuc${widget.tiendaCodigo}';

    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        // Obtiene la respuesta como JSON
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          if (data.containsKey('displayname') && data['displayname'] is String) {
            String displayName = data['displayname'];
            
            // Verifica si termina en un número de tres dígitos
            final regex = RegExp(r'\d{3}$');
            if (regex.hasMatch(displayName)) {
              nombreTienda = displayName.substring(0, displayName.length - 3); // Elimina los últimos tres caracteres
            } else {
              nombreTienda = displayName; // Almacena el nombre sin cambios
            }
          } else {
            nombreTienda = 'Nombre de tienda no disponible';
          }
        });
      } else {
        _showMessage('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
    }
  }

  Future<void> postData() async {
    const String url = 'http://srveccqas1.corporativo.avantetextil.com.mx:8000/sap/bc/rest/zws_consultapro?sap-client=400';
    
    // Crea el JSON que enviarás al servidor
    final Map<String, dynamic> jsonData = {
      'tienda': '2${widget.tiendaCodigo}',
      'cod_barr': codigo,
    };

    // Autenticación básica (reemplaza con tus credenciales)
    String username = 'WEBTNDA'; // Cambia esto por el usuario real
    String password = '#20servic3OPMA'; // Cambia esto por la contraseña real
    String credentials = '$username:$password';
    String basicAuth = 'Basic ${base64Encode(credentials.codeUnits)}';

    // Realiza la solicitud POST
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: jsonEncode(jsonData),
      );

      if (response.statusCode == 200) {
        // Solicitud exitosa
        var data = jsonDecode(response.body);
        
        setState(() {
          // Verifica y asigna valores predeterminados si están vacíos
          piso = data['piso']?.endsWith('-') == true ? data['piso']?.substring(0, data['piso'].length - 1) : data['piso'] ?? '';
          bodega = data['bodega']?.endsWith('-') == true ? data['bodega']?.substring(0, data['bodega'].length - 1) : data['bodega'] ?? '';
          transito = data['transito']?.endsWith('-') == true ? data['transito']?.substring(0, data['transito'].length - 1) : data['transito'] ?? '';
          
          // Asignación de precios
          precioInicial = data['precIni'] ?? 0.0;
          precioActual = data['precAct'] ?? 0.0;
          
          // Asignación de valores promocionales con valores predeterminados si están vacíos
          precioPromo = data['calc']?.isEmpty ?? true ? '' : data['calc'] ?? '';
          promoNombre = data['promName']?.isEmpty ?? true ? 'N/A' : data['promName'] ?? 'N/A';
          promoDesc = data['promDesc']?.isEmpty ?? true ? 'N/A' : data['promDesc'] ?? 'N/A';

          // Descripción y material con valores predeterminados si están vacíos
          descripcion = data['desc'] ?? 'Descripción no disponible';
          material = data['material'] ?? 'Material no disponible';
          promo = data['promo']?.isEmpty ?? true ? 'No Hay' : data['promo'] ?? 'No Hay';
        });

        _navigateToResultScreen();
      }    
      else {
        var data = jsonDecode(response.body);
        String comp = data['material']?.toString() ?? '';

        if (comp.isEmpty) {
          _showMessage('El código de barras no existe, intenta con otro');
        }
        else {
        // Maneja el error aquí
        _showMessage('Error en la solicitud: ${response.body}');
        }
      }
    } catch (e) {
      // Maneja errores de conexión
      _showMessage('Error de conexión: $e');
    }
  }

  void _scanBarcode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Escanear Código'),
            backgroundColor: Colors.grey.shade700,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
            ),
          ),
          body: MobileScanner(
            onDetect: (barcodeCapture) {
              final List<Barcode> barcodes = barcodeCapture.barcodes;
              setState(() {
                codigo = barcodes.first.rawValue ?? 'Código no detectado';
              });
              Navigator.pop(context); // Cierra el escáner después de detectar un código
              postData();
            },
          ),
        ),
      ),
    );
  }

  void _showDialogCode() {
    TextEditingController codigoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ingresa el Código'),
          content: TextField(
            controller: codigoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '2050000000645',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  codigo = codigoController.text.trim();
                });
                Navigator.of(context).pop(); // Cerrar el diálogo
                postData();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void logout() {
    // Limpiar datos de sesión
    setState(() {
      usuario = '';
      contrasena = '';
    });

    // Navegar a la pantalla de bienvenida y limpiar el stack de navegación
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    usuario = widget.username;
    contrasena = widget.password;
    fetchStoreName(); // Llama a la función en el initState o en algún evento específico
  }

  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Parte superior con logo y saludo
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 60.h, bottom: 20.h),
                      child: Image.asset(
                        'assets/images/logo_content.png',
                        height: 100.h,
                      ),
                    ),
                    Text(
                      '¡Bienvenido!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      margin: EdgeInsets.only(bottom: 10.h),
                      child: Text(
                        widget.nombre,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.h, bottom: 4.h),
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            nombreTienda,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Botones de "Escanear un Código" y "Ingresar un Código"
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _scanBarcode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 47.w, vertical: 12.h),
                      ),
                      child: Text(
                        'Escanea un Código',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Container(
                      margin: EdgeInsets.only(bottom: 30.h),
                      child: ElevatedButton(
                        onPressed: _showDialogCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 12.h),
                        ),
                        child: Text(
                          'Ingresa un Código',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Botón de cerrar sesión en la parte inferior
                Padding(
                  padding: EdgeInsets.only(bottom: 40.h),
                  child: IconButton(
                    onPressed: () {
                      logout();
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 40.sp,
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

  void _navigateToResultScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          barcodeValue: codigo,
          precioInicial: precioInicial,
          precioActual: precioActual,
          precioPromo: precioPromo,
          descripcion: descripcion,
          material: material,
          piso: piso,
          bodega: bodega,
          transito: transito,
          promo: promo,
          promoNombre: promoNombre,
          promoDesc: promoDesc,
        ),
      ),
    );
  }
}