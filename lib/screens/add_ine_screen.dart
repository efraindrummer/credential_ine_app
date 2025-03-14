import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart'; // Importa intl
import '../models/ine_credential_model.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import './capture_screen.dart';

class AddIneScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const AddIneScreen({super.key, required this.cameras});

  @override
  _AddIneScreenState createState() => _AddIneScreenState();
}

class _AddIneScreenState extends State<AddIneScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  File? _frontImage;
  File? _backImage;

  Future<void> _pickImage(ImageSource source, bool isFront) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(pickedFile.path);
        } else {
          _backImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _captureIneData(bool isFront) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaptureScreen(cameras: widget.cameras),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (isFront) {
          _frontImage = File(result['imagePath']);
        } else {
          _backImage = File(result['imagePath']);
        }
        _fillFormWithData(result['extractedData']);
      });
    }
  }

  void _fillFormWithData(Map<String, dynamic> data) {
    final dateFormat = DateFormat('dd-MM-yyyy'); // Formato de entrada

    _formKey.currentState?.patchValue({
      'full_name': data['full_name'] ?? '',
      'curp': data['curp'] ?? '',
      'birth_date':
          data['birth_date'] != null
              ? dateFormat.parse(data['birth_date'] as String)
              : null,
      'gender': data['gender'] ?? '',
      'federal_entity': data['federal_entity'] ?? '',
      'voter_key': data['voter_key'] ?? '',
      'ocr_code': data['ocr_code'] ?? '',
      'expiration_date':
          data['expiration_date'] != null
              ? dateFormat.parse(data['expiration_date'] as String)
              : null,
      'street': data['street'] ?? '',
      'house_number': data['house_number'] ?? '',
      'neighborhood': data['neighborhood'] ?? '',
      'municipality': data['municipality'] ?? '',
      'state': data['state'] ?? '',
      'zip_code': data['zip_code'] ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Credencial del INE')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: 'full_name',
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                  ),
                  validator: Validators.requiredValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'curp',
                  decoration: const InputDecoration(labelText: 'CURP'),
                  validator: Validators.curpValidator,
                ),
                const SizedBox(height: 16),

                // Otros campos...
                const Text('Foto frontal de la credencial'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _captureIneData(true),
                      child: const Text('Cámara'),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery, true),
                      child: const Text('Galería'),
                    ),
                  ],
                ),
                if (_frontImage != null) Image.file(_frontImage!, height: 100),
                const SizedBox(height: 16),

                const Text('Foto trasera de la credencial'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _captureIneData(false),
                      child: const Text('Cámara'),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery, false),
                      child: const Text('Galería'),
                    ),
                  ],
                ),
                if (_backImage != null) Image.file(_backImage!, height: 100),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final formData = _formKey.currentState!.value;
                      final ineCredential = IneCredentialModel(
                        fullName: formData['full_name'],
                        curp: formData['curp'],
                        birthDate: formData['birth_date'].toString(),
                        gender: formData['gender'],
                        federalEntity: formData['federal_entity'],
                        voterKey: formData['voter_key'],
                        ocrCode: formData['ocr_code'],
                        expirationDate: formData['expiration_date'].toString(),
                        street: formData['street'],
                        houseNumber: formData['house_number'],
                        neighborhood: formData['neighborhood'],
                        municipality: formData['municipality'],
                        state: formData['state'],
                        zipCode: formData['zip_code'],
                        photoUrlInverse: _frontImage?.path,
                        photoUrlReverse: _backImage?.path,
                      );

                      try {
                        await ApiService.addIneCredential(
                          ineCredential.toJson(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Credencial agregada exitosamente'),
                          ),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al agregar la credencial'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
