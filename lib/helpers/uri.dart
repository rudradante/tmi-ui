class UriHelper {
  static bool isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null;
  }
}
