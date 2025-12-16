class DbAuthException implements Exception {}

class DbNoInternetException implements Exception {}

class DbUnknownException implements Exception {
  final String message;
  DbUnknownException(this.message);
}
