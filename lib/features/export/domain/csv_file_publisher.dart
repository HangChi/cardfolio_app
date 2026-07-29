abstract interface class CsvFilePublisher {
  Future<String?> choosePath(String suggestedName);

  Future<bool> publish(String path);
}
