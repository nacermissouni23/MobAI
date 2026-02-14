/// API configuration constants.
class ApiConfig {
  /// Base URL for the backend API.
  /// Change this to your deployed backend URL in production.
  /// Use 10.0.2.2 for Android emulator (maps to host localhost).
  static const String baseUrl = 'http://10.80.22.28:8000/api';

  /// Connection timeout in seconds.
  static const int connectTimeout = 15;

  /// Receive timeout in seconds.
  static const int receiveTimeout = 30;

  /// Auth endpoints
  static const String loginUrl = '$baseUrl/auth/login';
  static const String registerUrl = '$baseUrl/auth/register';
  static const String meUrl = '$baseUrl/auth/me';

  /// Entity endpoints
  static const String usersUrl = '$baseUrl/users';
  static const String productsUrl = '$baseUrl/products';
  static const String emplacementsUrl = '$baseUrl/emplacements';
  static const String chariotsUrl = '$baseUrl/chariots';
  static const String ordersUrl = '$baseUrl/orders';
  static const String operationsUrl = '$baseUrl/operations';
  static const String inventoryUrl = '$baseUrl/inventory';
  static const String reportsUrl = '$baseUrl/reports';
  static const String orderLogsUrl = '$baseUrl/order-logs';

  /// Sync endpoints
  static const String syncUpdatesUrl = '$baseUrl/sync/updates';
  static const String syncBatchUrl = '$baseUrl/sync/batch';
  static const String syncFullUrl = '$baseUrl/sync/full-sync';
  static const String syncStatusUrl = '$baseUrl/sync/status';
}
