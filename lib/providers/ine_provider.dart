import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/inde_credential_model.dart';

class IneProvider with ChangeNotifier {
  List<IneCredentialModel> _credentials = [];

  List<IneCredentialModel> get credentials => _credentials;

  Future<void> fetchIneCredentials() async {
    final data = await ApiService.fetchIneCredentials();
    _credentials =
        data.map((item) => IneCredentialModel.fromJson(item)).toList();
    notifyListeners();
  }

  Future<void> addIneCredential(IneCredentialModel credential) async {
    await ApiService.addIneCredential(credential.toJson());
    _credentials.add(credential);
    notifyListeners();
  }
}
