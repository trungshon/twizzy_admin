import '../constants/app_constants.dart';

class MediaUtils {
  static String getMediaUrl(
    String? url, {
    bool isVideo = false,
  }) {
    if (url == null || url.isEmpty) return '';
    String finalUrl = url;
    // Replace emulator IP with localhost for web
    if (finalUrl.contains('10.0.2.2')) {
      finalUrl = finalUrl.replaceAll('10.0.2.2', 'localhost');
    }
    if (finalUrl.startsWith('http')) return finalUrl;
    if (finalUrl.startsWith('/')) {
      return '${AppConstants.baseUrl}$finalUrl';
    }
    final String path = isVideo ? 'video-stream' : 'image';
    return '${AppConstants.baseUrl}/static/$path/$finalUrl';
  }
}
