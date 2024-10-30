import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'welcome_screen.dart';
import 'main_screen.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  await Hive.initFlutter();
  await Hive.openBox('loginBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación',
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/main_screen': (context) => const MainScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Error de Ruta'),
              ),
              body: Center(
                child: AlertDialog(
                  title: const Text('Error de Ruta'),
                  content: const Text('La ruta a la que intentaste acceder no existe.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}