class Validators {
  static String? requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }

  static String? curpValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El CURP es requerido';
    }
    if (value.length != 18) {
      return 'El CURP debe tener 18 caracteres';
    }
    return null;
  }

  static String? zipCodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El código postal es requerido';
    }
    if (value.length != 5) {
      return 'El código postal debe tener 5 dígitos';
    }
    return null;
  }
}
