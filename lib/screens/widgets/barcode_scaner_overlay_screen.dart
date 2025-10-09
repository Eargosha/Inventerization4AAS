import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

@RoutePage()
class BarcodeScannerOverlayScreen extends StatefulWidget {
  const BarcodeScannerOverlayScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerOverlayScreen> createState() =>
      _BarcodeScannerOverlayScreenState();
}

class _BarcodeScannerOverlayScreenState
    extends State<BarcodeScannerOverlayScreen> {
  String? _barcodeResult;
  bool _isScanning = true;
  late MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(); // Инициализируем
  }

  @override
  void dispose() {
    _controller.dispose(); // Не забываем освободить ресурсы
    super.dispose();
  }

  void _onBarcodeScanned(BarcodeCapture barcodeCapture) {
    final barcode = barcodeCapture.barcodes.first;

    if (_isScanning && barcode.rawValue != null) {
      setState(() {
        _barcodeResult = barcode.rawValue;
        _isScanning = false;
      });

      // ✅ Добавь задержку и возврат результата
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, barcode.rawValue);
      });

      // Опционально: остановить камеру после сканирования
      // controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          // Камера
          MobileScanner(
            controller: _controller, // ← наш контроллер
            fit: BoxFit.cover,
            onDetect: _onBarcodeScanned,
          ),

          // Слой с вырезом
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Тёмный оверлей
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.6),
                ),

                // Белый вырез
                Container(
                  width: 300,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),

                // Текст внутри
                const Text(
                  "Наведите камеру на штрих-код",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      onPressed: () async {
                        try {
                          // Переключаем вспышку
                          final wasEnabled = await _controller.toggleTorch();
                          // `wasEnabled` — новое состояние (true = включена)
                        } catch (e) {
                          // Вспышка может быть недоступна (например, на эмуляторе)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Вспышка недоступна: $e')),
                          );
                        }
                      },
                      child: const Icon(Icons.flash_on),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Результат
          if (_barcodeResult != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Найден штрих-код: $_barcodeResult",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
