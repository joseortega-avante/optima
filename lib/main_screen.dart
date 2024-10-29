 import 'package:flutter/material.dart';
 
 class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() {
    return MainScreenState();
  }
}
 
class MainScreenState extends State<MainScreen> {
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
        ],
      ),
    );
  }
}