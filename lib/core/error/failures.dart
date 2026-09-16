/// Represents failures that can occur in the application
abstract class Failure implements Exception {
  final String message;
  final String? code;

  Failure({required this.message, this.code});

  @override
  String toString() => 'Failure($code): $message';
}

class AuthFailure extends Failure {
  AuthFailure({required super.message, super.code});

  factory AuthFailure.invalidEmail() => AuthFailure(
    message: 'The email address is not valid',
    code: 'invalid_email',
  );

  factory AuthFailure.userNotFound() => AuthFailure(
    message: 'No user found with this email',
    code: 'user_not_found',
  );

  factory AuthFailure.wrongPassword() =>
      AuthFailure(message: 'The password is incorrect', code: 'wrong_password');

  factory AuthFailure.emailAlreadyInUse() => AuthFailure(
    message: 'An account already exists with this email',
    code: 'email_already_in_use',
  );

  factory AuthFailure.weakPassword() =>
      AuthFailure(message: 'The password is too weak', code: 'weak_password');

  factory AuthFailure.unknown({String? message}) => AuthFailure(
    message: message ?? 'An authentication error occurred',
    code: 'unknown',
  );

  factory AuthFailure.networkError() => AuthFailure(
    message: 'Network error. Please check your connection.',
    code: 'network_error',
  );

  factory AuthFailure.sessionExpired() => AuthFailure(
    message: 'Your session has expired. Please sign in again.',
    code: 'session_expired',
  );
}

class FirestoreFailure extends Failure {
  FirestoreFailure({required super.message, super.code});

  factory FirestoreFailure.permissionDenied() => FirestoreFailure(
    message: 'You do not have permission to access this data',
    code: 'permission_denied',
  );

  factory FirestoreFailure.notFound() => FirestoreFailure(
    message: 'The requested data was not found',
    code: 'not_found',
  );

  factory FirestoreFailure.networkError() => FirestoreFailure(
    message: 'Network error. Please check your connection.',
    code: 'network_error',
  );

  factory FirestoreFailure.unknown({String? message}) => FirestoreFailure(
    message: message ?? 'A database error occurred',
    code: 'unknown',
  );

  factory FirestoreFailure.invalidData() => FirestoreFailure(
    message: 'The data format is invalid',
    code: 'invalid_data',
  );
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  ValidationFailure({required super.message, this.fieldErrors, super.code});

  factory ValidationFailure.emptyField(String fieldName) => ValidationFailure(
    message: '$fieldName cannot be empty',
    code: 'empty_field',
    fieldErrors: {fieldName: 'This field is required'},
  );

  factory ValidationFailure.invalidFormat(String fieldName) =>
      ValidationFailure(
        message: '$fieldName has an invalid format',
        code: 'invalid_format',
        fieldErrors: {fieldName: 'Please enter a valid format'},
      );
}

class GeneralFailure extends Failure {
  GeneralFailure({required super.message, super.code});

  factory GeneralFailure.unknown({String? message}) => GeneralFailure(
    message: message ?? 'An unknown error occurred',
    code: 'unknown',
  );
}
