import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/inde_credential_model.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';

class AddIneScreen extends StatefulWidget {
  const AddIneScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddIneScreenState createState() => _AddIneScreenState();
}

class _AddIneScreenState extends State<AddIneScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  File? _frontImage;
  File? _backImage;

  // Función para seleccionar una imagen desde la cámara o galería
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Credencial del INE')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre completo
                FormBuilderTextField(
                  name: 'full_name',
                  decoration: InputDecoration(labelText: 'Nombre completo'),
                  validator: Validators.requiredValidator,
                ),
                SizedBox(height: 16),

                // CURP
                FormBuilderTextField(
                  name: 'curp',
                  decoration: InputDecoration(labelText: 'CURP'),
                  validator: Validators.curpValidator,
                ),
                SizedBox(height: 16),

                // Fecha de nacimiento
                FormBuilderDateTimePicker(
                  name: 'birth_date',
                  inputType: InputType.date,
                  decoration: InputDecoration(labelText: 'Fecha de nacimiento'),
                  //validator: Validators.requiredValidator,
                ),
                SizedBox(height: 16),

                // Género
                FormBuilderDropdown<String>(
                  name: 'gender',
                  decoration: InputDecoration(labelText: 'Género'),
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
                  validator: Validators.requiredValidator,
                ),
                SizedBox(height: 16),

                // Entidad federativa
                FormBuilderTextField(
                  name: 'federal_entity',
                  decoration: InputDecoration(labelText: 'Entidad federativa'),
                  validator: Validators.requiredValidator,
                ),
                SizedBox(height: 16),

                // Clave de elector
                FormBuilderTextField(
                  name: 'voter_key',
                  decoration: InputDecoration(labelText: 'Clave de elector'),
                  validator: Validators.requiredValidator,
                ),
                SizedBox(height: 16),

                // Código OCR
                FormBuilderTextField(
                  name: 'ocr_code',
                  decoration: InputDecoration(labelText: 'Código OCR'),
                  validator: Validators.requiredValidator,
                ),
                SizedBox(height: 16),

                // Fecha de vigencia
                FormBuilderDateTimePicker(
                  name: 'expiration_date',
                  inputType: InputType.date,
                  decoration: InputDecoration(labelText: 'Fecha de vigencia'),
                  //validator: Validators.requiredValidator(value: 'Fecha requerida'),
                ),
                SizedBox(height: 16),

                // Dirección
                FormBuilderTextField(
                  name: 'street',
                  decoration: InputDecoration(labelText: 'Calle'),
                  validator: Validators.requiredValidator,
                ),
                FormBuilderTextField(
                  name: 'house_number',
                  decoration: InputDecoration(labelText: 'Número'),
                  validator: Validators.requiredValidator,
                ),
                FormBuilderTextField(
                  name: 'neighborhood',
                  decoration: InputDecoration(labelText: 'Colonia'),
                  validator: Validators.requiredValidator,
                ),
                FormBuilderTextField(
                  name: 'municipality',
                  decoration: InputDecoration(labelText: 'Municipio'),
                  validator: Validators.requiredValidator,
                ),
                FormBuilderTextField(
                  name: 'state',
                  decoration: InputDecoration(labelText: 'Estado'),
                  validator: Validators.requiredValidator,
                ),
                FormBuilderTextField(
                  name: 'zip_code',
                  decoration: InputDecoration(labelText: 'Código postal'),
                  validator: Validators.zipCodeValidator,
                ),
                SizedBox(height: 16),

                // Fotografías
                Text('Foto frontal de la credencial'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera, true),
                      child: Text('Cámara'),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery, true),
                      child: Text('Galería'),
                    ),
                  ],
                ),
                if (_frontImage != null) Image.file(_frontImage!, height: 100),
                SizedBox(height: 16),

                Text('Foto trasera de la credencial'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera, false),
                      child: Text('Cámara'),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery, false),
                      child: Text('Galería'),
                    ),
                  ],
                ),
                if (_backImage != null) Image.file(_backImage!, height: 100),
                SizedBox(height: 16),

                // Botón para guardar
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final formData = _formKey.currentState!.value;

                      // Crear el modelo de la credencial
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

                      // Enviar los datos al servidor
                      try {
                        await ApiService.addIneCredential(
                          ineCredential.toJson(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Credencial agregada exitosamente'),
                          ),
                        );
                        Navigator.pop(
                          context,
                        ); // Regresar a la pantalla principal
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al agregar la credencial'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
