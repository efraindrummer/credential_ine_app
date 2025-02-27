class UserModel {
  final int? id;
  final String username;
  final String password;

  UserModel({this.id, required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}
