/// Safe failure codes: database exceptions can contain private SQL parameters.
enum AnalyticsQueryFailure implements Exception {
  invalidRange,
  invalidMeasurement,
  unavailable,
}
