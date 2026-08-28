import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cards/data/card_providers.dart';
import '../domain/csv_file_publisher.dart';
import '../domain/csv_export_repository.dart';
import 'database_csv_export_repository.dart';
import 'platform/file_picker_csv_publisher.dart';

final Provider<CsvExportRepository> csvExportRepositoryProvider =
    Provider<CsvExportRepository>(
      (ref) => DatabaseCsvExportRepository(ref.watch(appDatabaseProvider)),
    );

final Provider<CsvFilePublisher> csvFilePublisherProvider =
    Provider<CsvFilePublisher>((ref) => FilePickerCsvPublisher());
