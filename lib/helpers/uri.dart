class UriHelper {
  static bool isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAbsolutePath) {
      return false;
    }
    return true;
  }
}
