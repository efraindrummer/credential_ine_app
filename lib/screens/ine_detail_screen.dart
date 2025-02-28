import 'package:flutter/material.dart';
import '../models/ine_credential_model.dart';

class IneDetailScreen extends StatelessWidget {
  final IneCredentialModel credential;

  const IneDetailScreen({super.key, required this.credential});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles de la Credencial del INE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre completo
            Text(
              'Nombre completo: ${credential.fullName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // CURP
            Text('CURP: ${credential.curp}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),

            // Fecha de nacimiento
            Text(
              'Fecha de nacimiento: ${credential.birthDate}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Género
            Text(
              'Género: ${credential.gender == 'M' ? 'Masculino' : 'Femenino'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Entidad federativa
            Text(
              'Entidad federativa: ${credential.federalEntity}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Clave de elector
            Text(
              'Clave de elector: ${credential.voterKey}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Código OCR
            Text(
              'Código OCR: ${credential.ocrCode}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Fecha de vigencia
            Text(
              'Fecha de vigencia: ${credential.expirationDate}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Dirección
            Text(
              'Dirección:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Calle: ${credential.street}', style: TextStyle(fontSize: 16)),
            Text(
              'Número: ${credential.houseNumber}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Colonia: ${credential.neighborhood}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Municipio: ${credential.municipality}',
              style: TextStyle(fontSize: 16),
            ),
            Text('Estado: ${credential.state}', style: TextStyle(fontSize: 16)),
            Text(
              'Código postal: ${credential.zipCode}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Fotografías
            if (credential.photoUrlInverse != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foto frontal:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Image.network(
                    credential.photoUrlInverse!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),
                ],
              ),

            if (credential.photoUrlReverse != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foto trasera:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Image.network(
                    credential.photoUrlReverse!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
