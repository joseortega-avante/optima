import 'result_screen.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MainScreen extends StatefulWidget {
  final String nombre;
  final String tiendaCodigo;

  const MainScreen({super.key, required this.nombre, required this.tiendaCodigo}); // Cambia esto según el usuario
    @override
    MainScreenState createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> {

  void _scanBarcode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Escanear Código'),
            backgroundColor: Colors.grey.shade700,
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: Colors.white
            ),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontFamily: 'Popppins',
              fontWeight: FontWeight.bold,
              fontSize: 24
            ),
          ),
          body: MobileScanner(
            onDetect: (barcodeCapture) {
              final List<Barcode> barcodes = barcodeCapture.barcodes;
              if (barcodes.isNotEmpty) {
                final String code = barcodes.first.rawValue ?? 'Código no detectado';
                Navigator.pop(context); // Cierra el escáner después de detectar un código
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                       barcodeValue: code,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  String? codigoIngresado;

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
                Navigator.of(context).pop(); // Cerrar el diálogo
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResultScreen(
                       barcodeValue: '',
                    ),
                  ),
                );
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
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
              'assets/images/background.png', // Ruta de la imagen de fondo
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
                      margin: const EdgeInsets.only(top: 120),
                      child: Image.asset(
                        'assets/images/logo_content.png', // Cambia por la ruta de tu logo
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '¡Bienvenido!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.nombre,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                // Botones de "Escanear un Código" y "Ingresar un Código"
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _scanBarcode();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      ),
                      child: const Text(
                        'Escanea un Código',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          _showDialogCode();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        ),
                        child: const Text(
                          'Ingresa un Código',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Botón de cerrar sesión en la parte inferior
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: IconButton(
                    onPressed: () {
                      //Logica
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 40,
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
