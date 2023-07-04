import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/presentation/pages/main_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../data/services/appwrite_service.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สแกนเพื่อเข้าสู่ระบบ'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          SizedBox(
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                if (result != null)
                  // call api to perform computer login
                  Text(
                    '${describeEnum(result!.format)}   Data: ${result!.code}',
                  )
                else
                  const Text('สแกน QR'),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getPermision();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }
  // void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
  //   debugPrint('${DateTime.now().toIso8601String()}_onPermissionSet $p');
  //   if (!p) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('No Permission')),
  //     );
  //   }
  // }

  void _getPermision() async {
    await Permission.camera.request();
  }

  void _onPermissionSet(
      BuildContext context, QRViewController ctrl, bool p) async {
    if (!p) {
      Get.snackbar(
        'Camera Permission Error',
        'To use QR Scanner, please go to setting to enable Camera',
        colorText: Colors.white,
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.error),
      );
      await Future.delayed(const Duration(seconds: 5));
      openAppSettings();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (result?.code != scanData.code) {
        setState(() {
          result = scanData;
        });
        if (scanData.code != null) {
          // call api
          var email = await storage.read(key: 'email');
          var password = await storage.read(key: 'password');
          debugPrint('accountData $email $password');
          var loginSuccess = await AppwriteService()
              .qrLogin('$email,$password,${scanData.code}');
          if (loginSuccess) {
            Get.snackbar(
              "สำเร็จ",
              "เข้าสู่ระบบสำเร็จ",
              colorText: Colors.white,
              icon: const Icon(Icons.check_circle),
              duration: const Duration(seconds: 1),
              snackPosition: SnackPosition.BOTTOM,
            );
          } else {
            Get.snackbar(
              "ล้มเหลว",
              "เข้าสู่ระบบล้มเหลว",
              colorText: Colors.white,
              icon: const Icon(Icons.cancel),
              duration: const Duration(seconds: 1),
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      }
    });
  }
}
