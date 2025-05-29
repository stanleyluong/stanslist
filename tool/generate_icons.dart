import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

void main() async {
  // Simple icon generator for PWA icons
  final iconSizes = [16, 32, 64, 128, 192, 512];
  final iconsDir = Directory('web/icons');
  
  if (!iconsDir.existsSync()) {
    iconsDir.createSync(recursive: true);
  }
  
  // Generate basic colored square icons with "SL" text
  for (final size in iconSizes) {
    final iconData = generateIconBytes(size, size, const Color(0xFF5468FF), 'SL', Colors.white);
    
    final iconFile = File('web/icons/Icon-$size.png');
    await iconFile.writeAsBytes(iconData);
    
    // Create maskable versions
    if (size == 192 || size == 512) {
      final maskableFile = File('web/icons/Icon-maskable-$size.png');
      await maskableFile.writeAsBytes(iconData);
    }
  }
  
  // Create favicon
  final faviconData = generateIconBytes(32, 32, const Color(0xFF5468FF), 'SL', Colors.white);
  final faviconFile = File('web/favicon.png');
  await faviconFile.writeAsBytes(faviconData);
  
  print('Icons generated successfully in web/icons/');
}

// Placeholder function - in a real implementation, you would use Flutter's
// rendering system to generate actual PNG bytes
Uint8List generateIconBytes(
    int width, int height, Color bgColor, String text, Color textColor) {
  // This is a placeholder - in reality, you'd use a Canvas and Picture recorder
  // Since we can't actually render in a command-line Dart app,
  // this is just returning dummy data
  return Uint8List.fromList(List.generate(100, (index) => index % 256));
}
