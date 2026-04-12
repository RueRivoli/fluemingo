class RateLimitExceededException implements Exception {
  final String functionName;

  const RateLimitExceededException({required this.functionName});

  @override
  String toString() =>
      'RateLimitExceededException(functionName: $functionName)';
}
