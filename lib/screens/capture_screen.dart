import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import '../services/api_service.dart'; // Asegúrate de importar tu ApiService
import '../models/ine_credential_model.dart';

class CaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CaptureScreen({super.key, required this.cameras});

  @override
  _CaptureScreenState createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late CameraController _controller;
  bool isInitialized = false;
  String extractedText = "";
  File? _frontImage;
  File? _backImage;
  Map<String, dynamic> extractedData = {};

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    await _controller.initialize();
    if (!mounted) return;
    setState(() => isInitialized = true);
  }

  // Capturar imagen y analizar texto
  Future<void> _captureAndAnalyze(bool isFront) async {
    if (!_controller.value.isInitialized) return;
    final image = await _controller.takePicture();
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      extractedText = recognizedText.text;
      if (isFront) {
        _frontImage = File(image.path);
      } else {
        _backImage = File(image.path);
      }
      extractedData.addAll(_parseIneText(extractedText));
    });

    textRecognizer.close();
  }

  // Parsear el texto de la INE
  Map<String, dynamic> _parseIneText(String text) {
    final lines = text.split('\n');
    final data = <String, dynamic>{};

    for (var line in lines) {
      line = line.trim();
      if (line.contains('Nombre') ||
          RegExp(r'[A-Z]{2,}\s[A-Z]{2,}').hasMatch(line)) {
        data['full_name'] = line.replaceAll('Nombre', '').trim();
      } else if (RegExp(r'[A-Z]{4}\d{6}[A-Z]{6}\d{2}').hasMatch(line)) {
        data['curp'] = line;
      } else if (RegExp(r'\d{2}-\d{2}-\d{4}').hasMatch(line)) {
        data['birth_date'] = line; // Mantén el formato DD-MM-YYYY
      } else if (line.contains('Clave de Elector') ||
          RegExp(r'[A-Z]{6}\d{8}[A-Z]').hasMatch(line)) {
        data['voter_key'] = line.replaceAll('Clave de Elector', '').trim();
      } // Agrega más reglas según necesites
    }

    return data;
  }

  // Guardar los datos en el backend
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

      // Enviar al backend
      await ApiService.addIneCredentialWithFiles(
        ineCredential,
        _frontImage!,
        _backImage!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credencial guardada exitosamente')),
      );
      Navigator.pop(context, {
        'imagePath': _frontImage!.path, // Por compatibilidad con AddIneScreen
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Captura INE")),
      body: Column(
        children: [
          isInitialized
              ? Expanded(child: CameraPreview(_controller))
              : const Center(child: CircularProgressIndicator()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _captureAndAnalyze(true),
                child: const Text("Capturar Frente"),
              ),
              ElevatedButton(
                onPressed: () => _captureAndAnalyze(false),
                child: const Text("Capturar Reverso"),
              ),
            ],
          ),
          if (_frontImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(_frontImage!, height: 100),
            ),
          if (_backImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(_backImage!, height: 100),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                extractedText.isNotEmpty
                    ? "Texto Extraído:\n\n$extractedText"
                    : "No hay texto capturado",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _saveToBackend,
            child: const Text("Guardar"),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
