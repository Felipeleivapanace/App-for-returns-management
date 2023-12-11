import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shiphero_shipment_status/shipheroClient.dart';

class ShipmentStatusScannerPage extends StatefulWidget {
  const ShipmentStatusScannerPage({Key? key}) : super(key: key);

  @override
  State<ShipmentStatusScannerPage> createState() =>
      _ShipmentStatusScannerPageState();
}

class _ShipmentStatusScannerPageState extends State<ShipmentStatusScannerPage> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isScanning = true;
  bool isWaitingForResponse = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Align(
            alignment: Alignment.center,
            child: CustomPaint(
              painter: BorderPainter(),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isScanning) {
        // Manejar el escaneo aquí si es necesario
        print('QR Code detected: ${scanData.code}');

        // Verificar si la cadena JSON contiene la clave "shipping_code"
        if (scanData.code != null &&
            scanData.code!.contains('"shipping_code"')) {
          // Detener el escaneo mientras se procesa la información
          controller.pauseCamera();
          isScanning = false;
          isWaitingForResponse = true;

          Map<String, dynamic> jsonMap = jsonDecode(scanData.code!);
          String shippingCode = jsonMap['shipping_code'];

          // Obtener el token de acceso de ShipHero
          getShipHeroAccessToken('fleiva@edarkstore.cl', 'xF&EY*B^0936')
              .then((accessToken) {
            if (accessToken != null) {
              // Realizar la consulta a ShipHero
              print('Access token: $accessToken');
              getShipHeroOrderById(accessToken, shippingCode).then((order) {
                if (order != null) {
                  // Mostrar la información de la orden
                  print('Order: $order');

                  // Analizar las listas shipments y rma_labels
                  List<dynamic> shipments = order['shipments'];
                  List<dynamic> rmaLabels = order['rma_labels'];

                  String popupMessage = '';

                  if (rmaLabels.length == 1 && shipments.length == 1) {
                    popupMessage = 'Es logística inversa, debes regresarlo';
                  } else if (rmaLabels.isEmpty && shipments.length > 0) {
                    if (shipments.length == 1) {
                      popupMessage =
                          'No debes ingresarlo, se deja en rack "no ingresar"';
                    } else {
                      popupMessage = 'Es Reship, debes ingresarlo';
                    }
                  }

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Mensaje'),
                        content: Text(
                          '$popupMessage\n\n'
                          'Order ID: ${order['id']}\n'
                          'Order date: ${order['order_date']}\n'
                          'Shipments Quantity: ${order['shipments'].length}\n'
                          'Shipments: ${jsonEncode(order['shipments'])}\n'
                          'Returns Quantity: ${order['returns'].length}\n'
                          'Returns: ${jsonEncode(order['returns'])}\n'
                          'RMA labels Quantity: ${order['rma_labels'].length}\n'
                          'RMA labels: ${jsonEncode(order['rma_labels'])}\n',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Mostrar un mensaje de error
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Order not found'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              });
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: const Text('Error obtaining access token'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }

            // Reanudar el escaneo
            controller.resumeCamera();
            isScanning = true;
            isWaitingForResponse = false;
          });
        } else {
          // Si no contiene "shipping_code", continuar el escaneo
          controller.resumeCamera();
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double width = 4.0;
    const double radius = 20.0;
    const double tRadius = 3 * radius;
    final Rect rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.width - 2 * width,
    );
    final RRect rrect =
        RRect.fromRectAndRadius(rect, const Radius.circular(radius));
    const Rect clippingRect0 = Rect.fromLTWH(
      0,
      0,
      tRadius,
      tRadius,
    );
    final Rect clippingRect1 = Rect.fromLTWH(
      size.width - tRadius,
      0,
      tRadius,
      tRadius,
    );
    final Rect clippingRect2 = Rect.fromLTWH(
      0,
      size.width - tRadius,
      tRadius,
      tRadius,
    );
    final Rect clippingRect3 = Rect.fromLTWH(
      size.width - tRadius,
      size.width - tRadius,
      tRadius,
      tRadius,
    );

    final Path path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color =
            Colors.blue // Personaliza el color del borde según tus necesidades
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
