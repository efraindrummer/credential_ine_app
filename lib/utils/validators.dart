class Validators {
  // Validador genérico para campos requeridos
  static String? requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }

  // Validador para el nombre completo
  static String? fullNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre completo es requerido';
    }
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚÑ\s]+$').hasMatch(value)) {
      return 'Solo se permiten letras y espacios';
    }
    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  // Validador para CURP
  static String? curpValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El CURP es requerido';
    }
    if (value.length != 18) {
      return 'El CURP debe tener 18 caracteres';
    }
    if (!RegExp(r'^[A-Z]{4}\d{6}[A-Z]{6}\d{2}$').hasMatch(value)) {
      return 'El formato del CURP es inválido';
    }
    return null;
  }

  // Validador para fecha de nacimiento o vigencia (usado con DateTime)
  static String? dateValidator(DateTime? value) {
    if (value == null) {
      return 'La fecha es requerida';
    }
    return null;
  }

  // Validador para género
  static String? genderValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El género es requerido';
    }
    if (!['M', 'F'].contains(value)) {
      return 'El género debe ser "M" o "F"';
    }
    return null;
  }

  // Validador para entidad federativa
  static String? federalEntityValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'La entidad federativa es requerida';
    }
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚÑ\s]+$').hasMatch(value)) {
      return 'Solo se permiten letras y espacios';
    }
    return null;
  }

  // Validador para clave de elector
  static String? voterKeyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'La clave de elector es requerida';
    }
    if (!RegExp(r'^[A-Z]{6}\d{8}[A-Z]$').hasMatch(value)) {
      return 'El formato de la clave de elector es inválido';
    }
    return null;
  }

  // Validador para código OCR
  static String? ocrCodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El código OCR es requerido';
    }
    if (!RegExp(r'^\d{10,13}$').hasMatch(value)) {
      return 'El código OCR debe ser un número de 10 a 13 dígitos';
    }
    return null;
  }

  // Validador para calle
  static String? streetValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'La calle es requerida';
    }
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚÑ0-9\s]+$').hasMatch(value)) {
      return 'Solo se permiten letras, números y espacios';
    }
    return null;
  }

  // Validador para número de casa
  static String? houseNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número es requerido';
    }
    if (!RegExp(r'^\d+[A-Za-z]?$').hasMatch(value)) {
      return 'Debe ser un número, opcionalmente seguido de una letra';
    }
    return null;
  }

  // Validador para colonia
  static String? neighborhoodValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'La colonia es requerida';
    }
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚÑ\s]+$').hasMatch(value)) {
      return 'Solo se permiten letras y espacios';
    }
    return null;
  }

  // Validador para municipio
  static String? municipalityValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El municipio es requerido';
    }
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚÑ\s]+$').hasMatch(value)) {
      return 'Solo se permiten letras y espacios';
    }
    return null;
  }

  // Validador para estado
  static String? stateValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El estado es requerido';
    }
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚÑ\s]+$').hasMatch(value)) {
      return 'Solo se permiten letras y espacios';
    }
    return null;
  }

  // Validador para código postal
  static String? zipCodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El código postal es requerido';
    }
    if (value.length != 5) {
      return 'El código postal debe tener 5 dígitos';
    }
    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      return 'Debe ser un número de 5 dígitos';
    }
    return null;
  }
}
