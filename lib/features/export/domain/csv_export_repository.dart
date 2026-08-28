import 'csv_export.dart';

abstract interface class CsvExportRepository {
  Future<List<CardCsvRow>> loadRows();
}
