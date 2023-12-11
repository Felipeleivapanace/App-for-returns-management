import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shiphero_shipment_status/scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Cambiado a MaterialApp
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Shipment Reships'),
        ),
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  void _navigateToScannerPage(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ShipmentStatusScannerPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "¿QUÉ DESEA HACER?",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 25,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            SizedBox(
              width: 350,
              child: Tooltip(
                padding: const EdgeInsets.all(8.0),
                showDuration: Duration(seconds: 2),
                preferBelow: false,
                message:
                    "Permite validar la entrega de paquetes a un courier a partir de sus características y la fecha.",
                child: CupertinoButton.filled(
                  padding: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.qr_code_scanner),
                      Text(
                        "Escanear Pedido",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                  onPressed: () {
                    _navigateToScannerPage(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
