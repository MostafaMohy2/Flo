import 'package:flutter/material.dart';
import 'app_palette.dart';

extension AppPaletteX on BuildContext {
  /// Falls back to the light palette if the extension isn't in scope
  /// (e.g. inside DevicePreview's wrapper context).
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? const AppPalette.light();
}
