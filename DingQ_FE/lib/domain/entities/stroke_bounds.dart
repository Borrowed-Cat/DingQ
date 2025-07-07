import 'package:flutter/material.dart';
import 'stroke.dart';

/// Utility class for calculating bounds of multiple strokes
class StrokeBounds {
  /// Calculate bounds for all strokes and return total area
  static Rect? calculateBounds(List<Stroke> strokes) {
    if (strokes.isEmpty) return null;
    
    Rect? totalBounds;
    
    for (final stroke in strokes) {
      final strokeBounds = stroke.getBounds();
      if (strokeBounds != null) {
        if (totalBounds == null) {
          totalBounds = strokeBounds;
        } else {
          totalBounds = totalBounds.expandToInclude(strokeBounds);
        }
      }
    }
    
    return totalBounds;
  }
  
  /// Return bounds information as string (for debugging)
  static String getBoundsInfo(Rect bounds) {
    return 'Bounds: L=${bounds.left.toStringAsFixed(2)}, '
           'T=${bounds.top.toStringAsFixed(2)}, '
           'R=${bounds.right.toStringAsFixed(2)}, '
           'B=${bounds.bottom.toStringAsFixed(2)}, '
           'W=${bounds.width.toStringAsFixed(2)}, '
           'H=${bounds.height.toStringAsFixed(2)}';
  }
} 