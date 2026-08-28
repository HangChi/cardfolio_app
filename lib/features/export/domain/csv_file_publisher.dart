abstract interface class CsvFilePublisher {
  Future<String?> choosePath(String suggestedName);

  Future<bool> writeAndPublish(String path, String contents);
}
