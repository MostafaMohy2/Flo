abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AiFailure extends Failure {
  const AiFailure(super.message);
}

class OcrFailure extends Failure {
  const OcrFailure(super.message);
}
