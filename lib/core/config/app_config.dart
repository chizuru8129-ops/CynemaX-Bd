/// CynemaX Bd — App Configuration
/// Developer: Shouko Nishimiya
///
/// Central config for API endpoints, branding, and app metadata.
/// Update [apiBaseUrl] if Railway URL changes.

class AppConfig {
  AppConfig._();

  // ─── Branding ───────────────────────────────────────────────
  static const String appName        = 'CynemaX Bd';
  static const String developerName  = 'Shouko Nishimiya';
  static const String appVersion     = '1.5.0';
  static const String appDescription = 'Movies & TV Series — BD Edition';

  // ─── API Endpoints ──────────────────────────────────────────
  /// Primary backend hosted on Railway
  static const String apiBaseUrl = 'https://web-production-61c05b.up.railway.app';

  // Common endpoint paths
  static const String sourcesEndpoint  = '$apiBaseUrl/sources';
  static const String searchEndpoint   = '$apiBaseUrl/search';
  static const String detailsEndpoint  = '$apiBaseUrl/details';
  static const String streamEndpoint   = '$apiBaseUrl/stream';
  static const String trendingEndpoint = '$apiBaseUrl/trending';
  static const String latestEndpoint   = '$apiBaseUrl/latest';

  // ─── Request Config ─────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const Map<String, String> defaultHeaders = {
    'Content-Type'  : 'application/json',
    'Accept'        : 'application/json',
    'X-App-Name'    : appName,
    'X-App-Version' : appVersion,
  };

  // ─── Netlify / Web Build ─────────────────────────────────────
  /// For Flutter web build deployed on Netlify.
  /// The app fetches from Railway API — CORS must be enabled on Railway side.
  static const bool isWebBuild = bool.fromEnvironment('WEB_BUILD', defaultValue: false);
}
