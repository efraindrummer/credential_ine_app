import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
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
    final dateFormat = DateFormat('dd-MM-yyyy');
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
      appBar: AppBar(
        title: const Text('Agregar Credencial INE'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sección de Datos Personales
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Datos Personales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'full_name',
                            'Nombre completo',
                            Validators.fullNameValidator,
                          ),
                          _buildTextField(
                            'curp',
                            'CURP',
                            Validators.curpValidator,
                          ),
                          _buildDateField('birth_date', 'Fecha de nacimiento'),
                          _buildDropdownField('gender', 'Género', ['M', 'F']),
                          _buildTextField(
                            'federal_entity',
                            'Entidad Federativa',
                            Validators.federalEntityValidator,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sección de Datos de la Credencial
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Datos de la Credencial',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'voter_key',
                            'Clave de Elector',
                            Validators.voterKeyValidator,
                          ),
                          _buildTextField(
                            'ocr_code',
                            'Código OCR',
                            Validators.ocrCodeValidator,
                          ),
                          _buildDateField(
                            'expiration_date',
                            'Fecha de Vigencia',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sección de Dirección
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dirección',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'street',
                            'Calle',
                            Validators.streetValidator,
                          ),
                          _buildTextField(
                            'house_number',
                            'Número',
                            Validators.houseNumberValidator,
                          ),
                          _buildTextField(
                            'neighborhood',
                            'Colonia',
                            Validators.neighborhoodValidator,
                          ),
                          _buildTextField(
                            'municipality',
                            'Municipio',
                            Validators.municipalityValidator,
                          ),
                          _buildTextField(
                            'state',
                            'Estado',
                            Validators.stateValidator,
                          ),
                          _buildTextField(
                            'zip_code',
                            'Código Postal',
                            Validators.zipCodeValidator,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sección de Fotos
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fotos de la Credencial',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildImageSection('Foto Frontal', true),
                          const SizedBox(height: 16),
                          _buildImageSection('Foto Trasera', false),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón de Guardar
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        if (_frontImage == null || _backImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor captura o selecciona ambas fotos',
                              ),
                            ),
                          );
                          return;
                        }
                        final formData = _formKey.currentState!.value;
                        final ineCredential = IneCredentialModel(
                          fullName: formData['full_name'],
                          curp: formData['curp'],
                          birthDate: formData['birth_date'].toString(),
                          gender: formData['gender'],
                          federalEntity: formData['federal_entity'],
                          voterKey: formData['voter_key'],
                          ocrCode: formData['ocr_code'],
                          expirationDate:
                              formData['expiration_date'].toString(),
                          street: formData['street'],
                          houseNumber: formData['house_number'],
                          neighborhood: formData['neighborhood'],
                          municipality: formData['municipality'],
                          state: formData['state'],
                          zipCode: formData['zip_code'],
                          photoUrlInverse: _frontImage!.path,
                          photoUrlReverse: _backImage!.path,
                        );
                        try {
                          await ApiService.addIneCredentialWithFiles(
                            ineCredential,
                            _frontImage!,
                            _backImage!,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Credencial agregada exitosamente'),
                            ),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error al agregar la credencial: $e',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Guardar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para campos de texto
  Widget _buildTextField(
    String name,
    String label,
    String? Function(String?)? validator,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: FormBuilderTextField(
        name: name,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        validator: validator,
      ),
    );
  }

  // Widget para campos de fecha
  Widget _buildDateField(String name, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: FormBuilderDateTimePicker(
        name: name,
        inputType: InputType.date,
        format: DateFormat('dd-MM-yyyy'),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        validator: Validators.dateValidator,
      ),
    );
  }

  // Widget para dropdown
  Widget _buildDropdownField(String name, String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: FormBuilderDropdown<String>(
        name: name,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items:
            options
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option == 'M' ? 'Masculino' : 'Femenino'),
                  ),
                )
                .toList(),
        validator: Validators.genderValidator,
      ),
    );
  }

  // Widget para sección de imágenes
  Widget _buildImageSection(String title, bool isFront) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _captureIneData(isFront),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cámara'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery, isFront),
              icon: const Icon(Icons.photo),
              label: const Text('Galería'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        if (isFront && _frontImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_frontImage!, height: 120, fit: BoxFit.cover),
            ),
          ),
        if (!isFront && _backImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_backImage!, height: 120, fit: BoxFit.cover),
            ),
          ),
      ],
    );
  }
}
