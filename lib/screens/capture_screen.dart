import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import '../services/api_service.dart';
import '../models/ine_credential_model.dart';

class CaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CaptureScreen({super.key, required this.cameras});

  @override
  _CaptureScreenState createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  bool isInitialized = false;
  String extractedText = "";
  File? _frontImage;
  File? _backImage;
  Map<String, dynamic> extractedData = {};
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(_animationController);
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    if (!mounted) return;
    setState(() => isInitialized = true);
  }

  Future<void> _captureAndAnalyze(bool isFront) async {
    if (!_controller.value.isInitialized) return;
    final image = await _controller.takePicture();
    final croppedImage = await _cropToCredential(File(image.path));

    final inputImage = InputImage.fromFilePath(croppedImage.path);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      extractedText =
          recognizedText.text; // Guardar el texto extraído para depuración
      if (isFront) {
        _frontImage = croppedImage;
      } else {
        _backImage = croppedImage;
      }
      extractedData = _parseIneText(extractedText);
      print(
        'Texto extraído:\n$extractedText',
      ); // Imprimir en consola para depuración
      print('Datos parseados:\n$extractedData');
    });

    textRecognizer.close();

    // Regresar datos después de capturar el frente
    if (isFront) {
      Navigator.pop(context, {
        'imagePath': _frontImage!.path,
        'extractedData': extractedData,
      });
    }
  }

  Future<File> _cropToCredential(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes())!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.7;
    const credentialAspectRatio = 1.59; // Ancho / Alto de una INE
    final credentialWidth = screenWidth * 0.8;
    final credentialHeight = credentialWidth / credentialAspectRatio;

    final x = (image.width - credentialWidth) / 2;
    final y = (image.height - credentialHeight) / 2;

    final cropped = img.copyCrop(
      image,
      x: x.round(),
      y: y.round(),
      width: credentialWidth.round(),
      height: credentialHeight.round(),
    );

    final croppedFile = File(imageFile.path.replaceAll('.jpg', '_cropped.jpg'));
    await croppedFile.writeAsBytes(img.encodeJpg(cropped));
    return croppedFile;
  }

  Map<String, dynamic> _parseIneText(String text) {
    final lines = text.split('\n').map((line) => line.trim()).toList();
    final data = <String, dynamic>{};
    String? address;

    // Imprimir cada línea para depuración
    print('Líneas extraídas:');
    for (var line in lines) {
      print(line);
    }

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toUpperCase();

      // Nombre completo: varias palabras en mayúsculas, antes de CURP o CLAVE
      if (RegExp(r'^[A-Z\s]{5,}$').hasMatch(line) &&
          !line.contains('CURP') &&
          !line.contains('CLAVE')) {
        if (!data.containsKey('full_name')) {
          data['full_name'] = line;
        }
      }

      // CURP: formato estándar
      if (RegExp(r'[A-Z]{4}\d{6}[A-Z]{6}\d{2}').hasMatch(line)) {
        data['curp'] = line;
      }

      // Fecha de nacimiento: primera fecha en formato DD-MM-YYYY
      if (RegExp(r'\d{2}-\d{2}-\d{4}').hasMatch(line) &&
          !data.containsKey('birth_date')) {
        data['birth_date'] = line;
      }

      // Género: 'M' o 'F', o después de "SEXO"
      if (RegExp(r'^(M|F)$').hasMatch(line) || line.contains('SEXO')) {
        data['gender'] =
            line.contains('SEXO') ? line.replaceAll('SEXO', '').trim() : line;
      }

      // Entidad federativa: después de "ENTIDAD" o palabras en mayúsculas
      if (line.contains('ENTIDAD') ||
          (RegExp(r'[A-Z]{2,}\s*[A-Z]{2,}').hasMatch(line) &&
              !data.containsKey('federal_entity'))) {
        data['federal_entity'] =
            line.contains('ENTIDAD')
                ? line.replaceAll('ENTIDAD', '').trim()
                : line;
      }

      // Clave de elector: formato estándar
      if (RegExp(r'[A-Z]{6}\d{8}[A-Z]').hasMatch(line)) {
        data['voter_key'] = line;
      }

      // Código OCR: secuencia de 10-13 dígitos
      if (RegExp(r'\d{10,13}').hasMatch(line)) {
        data['ocr_code'] = line;
      }

      // Fecha de vigencia: después de "VIGENCIA" o segunda fecha
      if (line.contains('VIGENCIA') ||
          (RegExp(r'\d{2}-\d{2}-\d{4}').hasMatch(line) &&
              data.containsKey('birth_date'))) {
        data['expiration_date'] =
            line.contains('VIGENCIA')
                ? line.replaceAll('VIGENCIA', '').trim()
                : line;
      }

      // Dirección: acumular líneas después de "DOMICILIO" o "CALLE"
      if (line.contains('DOMICILIO') ||
          line.contains('CALLE') ||
          RegExp(r'[A-Z0-9\s]+').hasMatch(line)) {
        address = (address ?? '') + ' ' + line;
      }
    }

    // Parsear dirección
    if (address != null) {
      final addressParts = address.trim().split(RegExp(r'\s+'));
      data['street'] = addressParts.firstWhere(
        (part) => part.isNotEmpty,
        orElse: () => '',
      );
      data['house_number'] = addressParts.firstWhere(
        (part) => RegExp(r'^\d+[A-Za-z]?$').hasMatch(part),
        orElse: () => '',
      );
      data['neighborhood'] = addressParts.firstWhere(
        (part) => part.contains('COL') || part.contains('COLONIA'),
        orElse: () => '',
      );
      data['municipality'] = addressParts.firstWhere(
        (part) => part.contains('MUN') || part.contains('MUNICIPIO'),
        orElse: () => '',
      );
      data['state'] = addressParts.firstWhere(
        (part) => RegExp(r'[A-Z]{2,}\s*[A-Z]{2,}').hasMatch(part),
        orElse: () => '',
      );
      data['zip_code'] = addressParts.firstWhere(
        (part) => RegExp(r'\d{5}').hasMatch(part),
        orElse: () => '',
      );
    }

    return data;
  }

  Future<void> _saveToBackend() async {
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor captura ambas fotos')),
      );
      return;
    }

    try {
      final ineCredential = IneCredentialModel(
        fullName: extractedData['full_name'] ?? '',
        curp: extractedData['curp'] ?? '',
        birthDate: extractedData['birth_date'] ?? '',
        gender: extractedData['gender'] ?? '',
        federalEntity: extractedData['federal_entity'] ?? '',
        voterKey: extractedData['voter_key'] ?? '',
        ocrCode: extractedData['ocr_code'] ?? '',
        expirationDate: extractedData['expiration_date'] ?? '',
        street: extractedData['street'] ?? '',
        houseNumber: extractedData['house_number'] ?? '',
        neighborhood: extractedData['neighborhood'] ?? '',
        municipality: extractedData['municipality'] ?? '',
        state: extractedData['state'] ?? '',
        zipCode: extractedData['zip_code'] ?? '',
        photoUrlInverse: _frontImage!.path,
        photoUrlReverse: _backImage!.path,
      );

      await ApiService.addIneCredentialWithFiles(
        ineCredential,
        _frontImage!,
        _backImage!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credencial guardada exitosamente')),
      );
      Navigator.pop(context, {
        'imagePath': _frontImage!.path,
        'extractedData': extractedData,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la credencial: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Captura INE"), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;
          final maxWidth = constraints.maxWidth;
          const credentialAspectRatio = 1.59; // Ancho / Alto de una INE
          final credentialWidth = maxWidth * 0.8;
          final credentialHeight = credentialWidth / credentialAspectRatio;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Visor de cámara con contorno
              SizedBox(
                height: maxHeight * 0.7,
                width: maxWidth,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isInitialized)
                        SizedBox(
                          width: maxWidth,
                          height: maxHeight * 0.7,
                          child: CameraPreview(_controller),
                        )
                      else
                        const Center(child: CircularProgressIndicator()),
                      AnimatedBuilder(
                        animation: _opacityAnimation,
                        builder: (context, child) {
                          return Container(
                            width: credentialWidth,
                            height: credentialHeight,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green.withOpacity(
                                  _opacityAnimation.value,
                                ),
                                width: 2.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Botones
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _captureAndAnalyze(true),
                      child: const Text("Capturar Frente"),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _captureAndAnalyze(false),
                      child: const Text("Capturar Reverso"),
                    ),
                  ],
                ),
              ),
              // Imágenes capturadas
              if (_frontImage != null || _backImage != null)
                SizedBox(
                  height: maxHeight * 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_frontImage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.file(_frontImage!, height: 80),
                        ),
                      if (_backImage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.file(_backImage!, height: 80),
                        ),
                    ],
                  ),
                ),
              // Texto extraído para depuración
              if (extractedText.isNotEmpty)
                SizedBox(
                  height: maxHeight * 0.1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Texto extraído:\n$extractedText',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              // Botón de guardar
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: _saveToBackend,
                  child: const Text("Guardar"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
