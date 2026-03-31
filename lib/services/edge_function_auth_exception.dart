class EdgeFunctionReauthRequiredException implements Exception {
  final String functionName;
  final String reason;

  const EdgeFunctionReauthRequiredException({
    required this.functionName,
    required this.reason,
  });

  @override
  String toString() =>
      'EdgeFunctionReauthRequiredException(functionName: $functionName, reason: $reason)';
}
