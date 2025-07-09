import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';

/// Utility class for downloading images in Flutter Web
class DownloadUtils {
  /// Download PNG image from Uint8List bytes
  /// 
  /// [pngBytes] - PNG image data as Uint8List
  /// [filename] - Name of the file to download (e.g., 'example.png')
  static void downloadPngFromBytes(Uint8List pngBytes, String filename) {
    try {
      // Create blob with PNG MIME type
      final blob = html.Blob([pngBytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Create anchor element and trigger download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      
      // Clean up the blob URL to prevent memory leaks
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Download failed: $e');
    }
  }

  /// Download PNG image from base64 string
  /// 
  /// [base64String] - PNG image data as base64 string (without data:image/png;base64, prefix)
  /// [filename] - Name of the file to download (e.g., 'example.png')
  static void downloadPngFromBase64(String base64String, String filename) {
    try {
      // Decode base64 to bytes
      final bytes = base64Decode(base64String);
      
      // Use the bytes download function
      downloadPngFromBytes(bytes, filename);
    } catch (e) {
      print('Download failed: $e');
    }
  }

  /// Download PNG image from URL (fetches the image first)
  /// 
  /// [imageUrl] - URL of the PNG image to download
  /// [filename] - Name of the file to download (e.g., 'example.png')
  static Future<void> downloadPngFromUrl(String imageUrl, String filename) async {
    try {
      // Fetch the image as bytes
      final response = await html.HttpRequest.request(
        imageUrl,
        responseType: 'arraybuffer',
      );
      
      final bytes = response.response as ByteBuffer;
      final uint8List = bytes.asUint8List();
      
      // Use the bytes download function
      downloadPngFromBytes(uint8List, filename);
    } catch (e) {
      print('Download failed: $e');
    }
  }
} 