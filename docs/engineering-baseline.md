# Engineering baseline

The repository uses Flutter 3.44.0 and Dart 3.12.0. Pull requests and pushes to
`main` must pass the following checks:

1. `dart format --output=none --set-exit-if-changed lib test integration_test`
2. `flutter analyze --fatal-infos --fatal-warnings`
3. Drift migration tests, including every staged upgrade through schema v9
4. `flutter test --concurrency=1`
5. `flutter build apk --debug`

Database schema changes must include a new file in `drift_schemas/app/`, updated
generated migration fixtures in `test/drift/app/generated/`, and a passing
staged migration test. Never edit an older schema snapshot to represent a newer
database version.

The CI definition is in `.github/workflows/ci.yml`.
