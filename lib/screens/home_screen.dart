import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:ine_credential_app/models/ine_credential_model.dart';
import 'package:ine_credential_app/screens/ine_detail_screen.dart';
import 'package:ine_credential_app/screens/add_ine_screen.dart'; // Importa AddIneScreen
import '../services/api_service.dart';

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras; // Recibe las cámaras como parámetro
  const HomeScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Credenciales INE')),
      body: FutureBuilder(
        future: ApiService.fetchIneCredentials(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }

          // Convertir los datos JSON en una lista de IneCredentialModel
          final credentials =
              (snapshot.data as List<dynamic>)
                  .map((json) => IneCredentialModel.fromJson(json))
                  .toList();

          return ListView.builder(
            itemCount: credentials.length,
            itemBuilder: (context, index) {
              final credential = credentials[index];
              return ListTile(
                title: Text(credential.fullName),
                subtitle: Text(credential.curp),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IneDetailScreen(credential: credential),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddIneScreen(cameras: cameras),
            ),
          );
        },
        tooltip: 'Agregar nueva credencial',
        child: const Icon(Icons.add),
      ),
    );
  }
}
