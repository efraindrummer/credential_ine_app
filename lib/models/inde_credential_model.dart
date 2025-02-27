class IneCredentialModel {
  final int? id;
  final String fullName;
  final String curp;
  final String birthDate;
  final String gender;
  final String federalEntity;
  final String voterKey;
  final String ocrCode;
  final String expirationDate;
  final String street;
  final String houseNumber;
  final String neighborhood;
  final String municipality;
  final String state;
  final String zipCode;
  final String? photoUrlInverse;
  final String? photoUrlReverse;

  IneCredentialModel({
    this.id,
    required this.fullName,
    required this.curp,
    required this.birthDate,
    required this.gender,
    required this.federalEntity,
    required this.voterKey,
    required this.ocrCode,
    required this.expirationDate,
    required this.street,
    required this.houseNumber,
    required this.neighborhood,
    required this.municipality,
    required this.state,
    required this.zipCode,
    this.photoUrlInverse,
    this.photoUrlReverse,
  });

  factory IneCredentialModel.fromJson(Map<String, dynamic> json) {
    return IneCredentialModel(
      id: json['id'],
      fullName: json['full_name'],
      curp: json['curp'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      federalEntity: json['federal_entity'],
      voterKey: json['voter_key'],
      ocrCode: json['ocr_code'],
      expirationDate: json['expiration_date'],
      street: json['street'],
      houseNumber: json['house_number'],
      neighborhood: json['neighborhood'],
      municipality: json['municipality'],
      state: json['state'],
      zipCode: json['zip_code'],
      photoUrlInverse: json['photo_url_inverse'],
      photoUrlReverse: json['photo_url_reverse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'curp': curp,
      'birth_date': birthDate,
      'gender': gender,
      'federal_entity': federalEntity,
      'voter_key': voterKey,
      'ocr_code': ocrCode,
      'expiration_date': expirationDate,
      'street': street,
      'house_number': houseNumber,
      'neighborhood': neighborhood,
      'municipality': municipality,
      'state': state,
      'zip_code': zipCode,
      'photo_url_inverse': photoUrlInverse,
      'photo_url_reverse': photoUrlReverse,
    };
  }
}
