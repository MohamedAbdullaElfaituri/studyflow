class Validators {
  Validators._();

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'required';
    }
    return null;
  }

  static String? email(String? value) {
    if (requiredField(value) != null) {
      return 'required';
    }

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value!.trim())) {
      return 'invalid_email';
    }
    return null;
  }

  static String? minLength(String? value, int length) {
    if (requiredField(value) != null) {
      return 'required';
    }
    if (value!.trim().length < length) {
      return 'min_length';
    }
    return null;
  }
}
