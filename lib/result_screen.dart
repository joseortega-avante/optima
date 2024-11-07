import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResultScreen extends StatefulWidget {
  final String barcodeValue;
  final String descripcion;
  final double precioInicial;
  final double precioActual;
  final String precioPromo;
  final String material;
  final String piso;
  final String bodega;
  final String transito;
  final String promo;
  final String promoNombre;
  final String promoDesc;

  const ResultScreen({
    super.key,
    required this.barcodeValue,
    required this.descripcion,
    required this.precioInicial,
    required this.precioActual,
    required this.precioPromo, 
    required this.material, 
    required this.piso, 
    required this.bodega,
    required this.transito,
    required this.promo,
    required this.promoNombre,
    required this.promoDesc,
  });

    @override
    ResultScreenState createState() {
    return ResultScreenState();
  }
}

class ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {

    String inicial = widget.precioInicial.toString();
    String actual = widget.precioActual.toString();
    String promo = widget.precioPromo.toString();
    double ps = double.parse(widget.piso);
    double bd = double.parse(widget.bodega);
    double tr = double.parse(widget.transito);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade700,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_content.png',
          height: 40.h,
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png', // Imagen de fondo
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildDataRow(),
                  SizedBox(height: 20.h),
                  _buildUPCCode(),
                  SizedBox(height: 20.h),
                  _buildMaterialDescriptionRow(),
                  SizedBox(height: 10.h),
                  _buildDescriptionBox(),
                  SizedBox(height: 30.h),
                  _buildInventorySection(ps, bd, tr),
                  SizedBox(height: 20.h),
                  _buildPromotionSection(),
                  SizedBox(height: 30.h),
                  _buildPricesRow(inicial, actual, promo),
                  SizedBox(height: 30.h),
                  _buildBackButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildInfoBox('Resultado', width: 110.w, height: 40.h, fontWeight: FontWeight.bold, fontSize: 16.sp)
      ],
    );
  }

  Widget _buildUPCCode() {
    return Center(
      child: Text(
        'UPC: ${widget.barcodeValue}',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildMaterialDescriptionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoBox('Material', width: 140.w, height: 35.h, fontWeight: FontWeight.bold, fontSize: 12.sp),
        _buildInfoBox(widget.material, width: 170.w, height: 35.h, fontWeight: FontWeight.w500, fontSize: 12.sp),
      ],

    );
  }

  Widget _buildDescriptionBox() {
    return _buildInfoBox(widget.descripcion, width: double.infinity, height: 35.h, fontWeight: FontWeight.w500,fontSize: 12.sp);
  }

  Widget _buildInventorySection(double ps, double bd, double tr) {
    int pisoRed = ps.ceil();
    int bodegaRed = bd.ceil();
    int transRed = tr.ceil();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInventoryBox('Piso', '$pisoRed pzs', width: 100.w),
            _buildInventoryBox('Bodega', '$bodegaRed pzs', width: 100.w),
            _buildInventoryBox('Tránsito', '$transRed pzs', width: 100.w),
          ],
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildPromotionSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoBox('Promoción', width: 140.w, height: 35.h, fontWeight: FontWeight.bold, fontSize: 12.sp),
            _buildInfoBox(widget.promoNombre, width: 170.w, height: 35.h, fontWeight: FontWeight.w500, fontSize: 12.sp),
          ],
        ),
        SizedBox(height: 10.h),
        _buildInfoBox(widget.promoDesc, width: double.infinity, height: 35.h, fontWeight: FontWeight.w500, fontSize: 12.sp),
      ],
    );
  }

  Widget _buildPricesRow(String inicial, String actual, String ppromo) {
    // Si el precio promo está vacío, mostramos solo los precios inicial y actual centrados.
    if (widget.precioPromo.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPriceBox('Precio Inicial', inicial, Colors.white),
          SizedBox(width: 20.w), // Espacio entre los precios
          _buildPriceBox('Precio Actual', actual, Colors.white),
        ],
      );
    }
    
    // Si el precio promo no está vacío, mostramos los tres precios.

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPriceBox('Precio Inicial', inicial, Colors.white),
        _buildPriceBox('Precio Actual', actual, Colors.white),
        _buildPriceBox('Precio Promo', ppromo, Colors.red),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Center(
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
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String text, {required double width, double? height, required fontWeight, required fontSize}) {
    return Container(
      width: width,
      height: height ?? 40.h,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInventoryBox(String label, String value, {required double width}) {
    return Container(
      width: width,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBox(String label, String price, Color color) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
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
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}