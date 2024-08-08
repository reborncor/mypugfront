bool isValidUrl(String url) {
  try {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
