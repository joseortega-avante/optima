import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final String barcodeValue;

  const ResultScreen({super.key, required this.barcodeValue});

  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Image.asset(
            'assets/images/logo_content.png',
            height: 45,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Image.asset(
            'assets/images/background.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Contenido de la pantalla
          Column(
            children: [
              // Fila con 'Tienda Optima Cadereyta' y '2001'
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: const Text(
                        'Tienda Optima Cadereyta',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ), 
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: const Text(
                        '2001',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppinss',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Fila con 'Resultado'
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 16.0),
                child: Container (
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: const Text(
                    'Resultado',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  ),
              ),
              // Resto del contenido
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 301,
                        height: 248,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Stack(
                          children: [
                            // Texto centrado dentro del contenedor
                            Center(
                              child: Text(
                                'HOLA',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            // Ícono de información en la esquina inferior derecha
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  showAdditionalInfo();
                                },
                                child: const Icon(
                                  Icons.info_outline,
                                  color: Colors.white, // Puedes cambiar el color si lo deseas
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'UPC: 2050000000645',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(top: 0, bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: const Text(
                          'Material Prueba IGNACIO... 06M, NEGRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Precio Inicial
                            Column(
                              children: [
                                Text(
                                  '\$100.00',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Precio Inicial',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                            // Precio Actual
                            Column(
                              children: [
                                Text(
                                  '\$100.00',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Precio Actual',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600, 
                                    fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                            // Precio Promo
                            Column(
                              children: [
                                Text(
                                  '\$80.00',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  'Precio Promo',
                                  style: TextStyle(
                                    color: Colors.red, 
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 40),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Radio de los bordes
                            ),
                          ),
                          onPressed: () {
                            // Navegar a la pantalla anterior
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Regresar',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showAdditionalInfo() {
    // Aquí puedes agregar lógica para mostrar información adicional
    // del producto cuando se hace clic en el icono de información
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Información del Producto'),
          content: const Text('Esta es la información adicional del producto.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}