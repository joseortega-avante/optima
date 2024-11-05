import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResultScreen extends StatefulWidget {
  final String barcodeValue;
  final String nombreTienda;
  final String precioInicial; 
  final String precioActual;
  final String precioPromo;
  final String descripcion;

  const ResultScreen({super.key, required this.barcodeValue, required this.nombreTienda, required this.precioInicial, required this.precioActual, required this.precioPromo, required this.descripcion});

  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(bottom: 15.h), // Adapta con ScreenUtil
          child: Image.asset(
            'assets/images/logo_content.png',
            height: 30.h, // Ajuste adaptable
          ),
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h, bottom: 0.h),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'Resultado de la Consulta',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on, // Icono de ubicación
                            color: Colors.white,
                            size: 16.sp, // Tamaño adaptable
                          ),
                          SizedBox(width: 4.w), // Espacio entre el icono y el texto
                          Text(
                            widget.nombreTienda,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 301.w,
                        height: 248.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                'HOLA',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10.h,
                              right: 10.w,
                              child: GestureDetector(
                                onTap: () {
                                  showAdditionalInfo();
                                },
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Text(
                          'UPC: ${widget.barcodeValue}',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        margin: EdgeInsets.only(top: 0.h, bottom: 20.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          widget.descripcion,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 40.w, // Espacio horizontal entre elementos
                        runSpacing: 10.h, // Espacio vertical si los elementos se alinean en múltiples filas
                        children: [
                          if (widget.precioInicial.isNotEmpty)
                            _buildPriceColumn('Precio Inicial', widget.precioInicial, Colors.white),
                          if (widget.precioActual.isNotEmpty)
                            _buildPriceColumn('Precio Actual', widget.precioActual, Colors.white),
                          if (widget.precioPromo.isNotEmpty)
                            _buildPriceColumn('Precio Promo', widget.precioPromo, Colors.red),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25.h),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Regresar',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
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

  Widget _buildPriceColumn(String label, String price, Color color) {
    return price.isNotEmpty
        ? Column(
            children: [
              Text(
                price,
                style: TextStyle(
                  color: color,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          )
        : const SizedBox.shrink(); // No muestra nada si price está vacío
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