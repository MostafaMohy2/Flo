import 'package:flutter/material.dart';
import 'app_palette.dart';

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
