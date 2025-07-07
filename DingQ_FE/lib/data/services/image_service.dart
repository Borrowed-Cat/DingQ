import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'api_service.dart';

/// Image service for Flutter Web
class ImageService {
  /// Margin size (pixels)
  static const double margin = 80.0;

  /// Send canvas area to API (crop by stroke bounds + add margin)
  static Future<void> sendCanvasToApi(
    GlobalKey canvasKey,
    Rect bounds, {
    Function(Map<String, dynamic>)? onResponse,
  }) async {
    try {
      print('=== Image Generation ===');
      print('Canvas Bounds: $bounds');
      
      // Find RenderRepaintBoundary
      final RenderRepaintBoundary? boundary = canvasKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        print('Error: RenderRepaintBoundary not found');
        return;
      }

      // Calculate bounds with margin
      final Rect boundsWithMargin = Rect.fromLTRB(
        bounds.left - margin,
        bounds.top - margin,
        bounds.right + margin,
        bounds.bottom + margin,
      );
      
      print('Bounds with margin: $boundsWithMargin');

      // Generate full image
      print('Generating full image...');
      final ui.Image fullImage = await boundary.toImage(pixelRatio: 1.0);
      print('Full image size: ${fullImage.width}x${fullImage.height}');

      // Crop by stroke bounds + margin
      print('Cropping image...');
      final ui.Image croppedImage = await cropImage(fullImage, boundsWithMargin);
      print('Cropped image size: ${croppedImage.width}x${croppedImage.height}');

      // Convert to ByteData
      print('Converting to PNG...');
      final ByteData? byteData = await croppedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (byteData == null) {
        print('Error: Failed to convert image to ByteData');
        return;
      }

      // Convert to Uint8List
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      print('PNG size: ${pngBytes.length} bytes');
      
      // Check PNG header (should start with 0x89, 0x50, 0x4E, 0x47)
      if (pngBytes.length >= 4) {
        final header = pngBytes.take(4).toList();
        print('PNG header: ${header.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
        if (header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47) {
          print('✓ Valid PNG header detected');
        } else {
          print('✗ Invalid PNG header');
        }
      }
      
      print('===================');

      // Send to API
      await ApiService.searchSimilarImages(pngBytes, onResponse: onResponse);
      
    } catch (e) {
      print('Error sending image to API: $e');
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