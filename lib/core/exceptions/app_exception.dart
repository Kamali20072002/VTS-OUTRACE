class AppException implements Exception {
  final int statusCode;
  final String message;

  AppException(this.statusCode, this.message);

  @override
  String toString() => 'AppException($statusCode): $message';
}

class TimeoutException extends AppException {
  TimeoutException(super.statusCode, super.message);
}

class HttpException extends AppException {
  HttpException(super.statusCode, super.message);
}