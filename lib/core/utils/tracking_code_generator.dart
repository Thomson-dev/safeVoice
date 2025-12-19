class TrackingCodeGenerator {
  static String generate() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (DateTime.now().microsecond % 10000).toString().padLeft(4, '0');
    final code = '${timestamp.toString().substring(timestamp.toString().length - 6)}$random';
    return code.toUpperCase();
  }
}
