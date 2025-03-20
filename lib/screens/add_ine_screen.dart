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

  // Seleccionar imagen desde galería
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

  // Capturar datos desde la cámara
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

  // Llenar el formulario con datos extraídos
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
                  validator: Validators.fullNameValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'curp',
                  decoration: const InputDecoration(labelText: 'CURP'),
                  validator: Validators.curpValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderDateTimePicker(
                  name: 'birth_date',
                  inputType: InputType.date,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento',
                  ),
                  validator: Validators.dateValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown<String>(
                  name: 'gender',
                  decoration: const InputDecoration(labelText: 'Género'),
                  items:
                      ['M', 'F']
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(
                                gender == 'M' ? 'Masculino' : 'Femenino',
                              ),
                            ),
                          )
                          .toList(),
                  validator: Validators.genderValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'federal_entity',
                  decoration: const InputDecoration(
                    labelText: 'Entidad federativa',
                  ),
                  validator: Validators.federalEntityValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'voter_key',
                  decoration: const InputDecoration(
                    labelText: 'Clave de elector',
                  ),
                  validator: Validators.voterKeyValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'ocr_code',
                  decoration: const InputDecoration(labelText: 'Código OCR'),
                  validator: Validators.ocrCodeValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderDateTimePicker(
                  name: 'expiration_date',
                  inputType: InputType.date,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de vigencia',
                  ),
                  validator: Validators.dateValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'street',
                  decoration: const InputDecoration(labelText: 'Calle'),
                  validator: Validators.streetValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'house_number',
                  decoration: const InputDecoration(labelText: 'Número'),
                  validator: Validators.houseNumberValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'neighborhood',
                  decoration: const InputDecoration(labelText: 'Colonia'),
                  validator: Validators.neighborhoodValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'municipality',
                  decoration: const InputDecoration(labelText: 'Municipio'),
                  validator: Validators.municipalityValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'state',
                  decoration: const InputDecoration(labelText: 'Estado'),
                  validator: Validators.stateValidator,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'zip_code',
                  decoration: const InputDecoration(labelText: 'Código postal'),
                  validator: Validators.zipCodeValidator,
                ),
                const SizedBox(height: 16),
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
                if (_frontImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.file(_frontImage!, height: 100),
                  ),
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
                if (_backImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.file(_backImage!, height: 100),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
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
                        expirationDate: formData['expiration_date'].toString(),
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
                            content: Text('Error al agregar la credencial: $e'),
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
