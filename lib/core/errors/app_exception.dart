class AppException implements Exception {
  const AppException(this.code);

  final String code;

  @override
  String toString() => code;
}
