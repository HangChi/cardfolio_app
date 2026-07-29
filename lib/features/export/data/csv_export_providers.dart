import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/csv_file_publisher.dart';
import 'platform/file_picker_csv_publisher.dart';

final Provider<CsvFilePublisher> csvFilePublisherProvider =
    Provider<CsvFilePublisher>((ref) => FilePickerCsvPublisher());
