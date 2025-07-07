import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Image service for Flutter Web
class ImageService {
  /// Margin size (pixels)
  static const double margin = 80.0;

  /// Save canvas area as PNG (crop by stroke bounds + add margin)
  static Future<String?> saveCanvasAsPng(
    GlobalKey canvasKey,
    Rect bounds,
  ) async {
    try {
      // Find RenderRepaintBoundary
      final RenderRepaintBoundary? boundary = canvasKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        return null;
      }

      // Calculate bounds with margin
      final Rect boundsWithMargin = Rect.fromLTRB(
        bounds.left - margin,
        bounds.top - margin,
        bounds.right + margin,
        bounds.bottom + margin,
      );

      // Generate full image
      final ui.Image fullImage = await boundary.toImage(pixelRatio: 1.0);

      // Crop by stroke bounds + margin
      final ui.Image croppedImage = await cropImage(fullImage, boundsWithMargin);

      // Convert to ByteData
      final ByteData? byteData = await croppedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (byteData == null) {
        return null;
      }

      // Convert to Uint8List
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // Create Blob
      final html.Blob blob = html.Blob([pngBytes]);
      
      // Generate filename with timestamp
      final String fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      
      // Create download link
      final String url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      
      // Revoke URL
      html.Url.revokeObjectUrl(url);
      
      return fileName;
    } catch (e) {
      return null;
    }
  }

  /// Crop ui.Image by bounds area and return new ui.Image
  static Future<ui.Image> cropImage(ui.Image src, Rect bounds) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();
    final srcRect = bounds;
    final dstRect = Rect.fromLTWH(0, 0, bounds.width, bounds.height);
    canvas.drawImageRect(src, srcRect, dstRect, paint);
    final picture = recorder.endRecording();
    return await picture.toImage(
      bounds.width.ceil(),
      bounds.height.ceil(),
    );
  }
} 