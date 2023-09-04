import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

ThemeData lightTheme = FlexThemeData.light(
  scheme: FlexScheme.amber,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 7,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 10,
    blendOnColors: false,
    useTextTheme: true,
  ),
  keyColors: const FlexKeyColors(),
  tones: FlexTones.soft(Brightness.light),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
);
ThemeData darkTheme = FlexThemeData.dark(
  scheme: FlexScheme.amber,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 13,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 20,
    useTextTheme: true,
  ),
  keyColors: const FlexKeyColors(),
  tones: FlexTones.soft(Brightness.dark),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
);
