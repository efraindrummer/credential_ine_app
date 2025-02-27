import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre de usuario
              FormBuilderTextField(
                name: 'username',
                decoration: InputDecoration(labelText: 'Nombre de usuario'),
                validator: Validators.requiredValidator,
              ),
              SizedBox(height: 16),

              // Contraseña
              FormBuilderTextField(
                name: 'password',
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                //validator: Validators.passwordValidator,
              ),
              SizedBox(height: 16),

              // Confirmar contraseña
              FormBuilderTextField(
                name: 'confirm_password',
                decoration: InputDecoration(labelText: 'Confirmar contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value !=
                      _formKey.currentState?.fields['password']?.value) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Botón para registrar
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    final formData = _formKey.currentState!.value;

                    // Registrar al usuario
                    try {
                      final success = await AuthService.register(
                        formData['username'], // Este valor se enviará como 'user_name'
                        formData['password'], // Este valor se enviará como 'user_password'
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Registro exitoso')),
                        );
                        Navigator.pop(
                          context,
                        ); // Regresar a la pantalla de login
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al registrar el usuario'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al registrar el usuario'),
                        ),
                      );
                    }
                  }
                },

                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
