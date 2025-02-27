import 'package:flutter/material.dart';
import 'add_ine_screen.dart';
import 'ine_detail_screen.dart';
import '../providers/ine_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ineProvider = Provider.of<IneProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Credenciales INE')),
      body: FutureBuilder(
        future: ineProvider.fetchIneCredentials(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos'));
          }
          final credentials = ineProvider.credentials;
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
            MaterialPageRoute(builder: (_) => AddIneScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
