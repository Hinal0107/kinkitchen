class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No Internet connection. Please check your network.']) : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error. Please try again later.']) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  const ValidationFailure(super.message, {this.errors});
}
