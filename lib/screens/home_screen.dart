import 'package:flutter/material.dart';
import 'package:ine_credential_app/screens/ine_detail_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Credenciales INE')),
      body: FutureBuilder(
        future: ApiService.fetchIneCredentials(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos'));
          }
          final credentials = snapshot.data as List<dynamic>;
          return ListView.builder(
            itemCount: credentials.length,
            itemBuilder: (context, index) {
              final credential = credentials[index];
              return ListTile(
                title: Text(credential['full_name']),
                subtitle: Text(credential['curp']),
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
    );
  }
}
