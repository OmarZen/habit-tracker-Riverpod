import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeProvider extends StateNotifier<ThemeMode> {
  ThemeProvider() : super(ThemeMode.dark);

  ThemeMode _themeMode = ThemeMode.dark;

  int _lightThemeIndex = 0;
  int _darkThemeIndex = 0;

  // List of available themes
  final List<FlexColorScheme> _themesDark = [
    FlexColorScheme.dark(scheme: FlexScheme.bahamaBlue),
    FlexColorScheme.dark(scheme: FlexScheme.deepBlue),
    FlexColorScheme.dark(scheme: FlexScheme.mandyRed),
    FlexColorScheme.dark(scheme: FlexScheme.blue),
    FlexColorScheme.dark(scheme: FlexScheme.indigo),
    FlexColorScheme.dark(scheme: FlexScheme.mallardGreen),
  ];

  final List<FlexColorScheme> _themesLight = [
    FlexColorScheme.light(scheme: FlexScheme.bahamaBlue),
    FlexColorScheme.light(scheme: FlexScheme.deepBlue),
    FlexColorScheme.light(scheme: FlexScheme.mandyRed),
    FlexColorScheme.light(scheme: FlexScheme.blue),
    FlexColorScheme.light(scheme: FlexScheme.indigo),
    FlexColorScheme.light(scheme: FlexScheme.mallardGreen),
  ];

  final List<String> _themeNames = [
    "Bahama Blue",
    "Deep Blue",
    "Mandy Red",
    "Blue",
    "Indigo",
    "Mallard Green",
  ];

  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => _themesLight[_lightThemeIndex].toTheme;

  ThemeData get darkTheme => _themesDark[_darkThemeIndex].toTheme;

  int get lightThemeIndex => _lightThemeIndex;
  int get darkThemeIndex => _darkThemeIndex;

  // Method to return the current list of themes based on the mode
  List<String> get currentThemeNames => _themeMode == ThemeMode.light
      ? _themeNames
      : _themeNames; // Same names for now but could differ

  // Get the current theme index based on the mode
  int get currentThemeIndex {
    return _themeMode == ThemeMode.light ? _lightThemeIndex : _darkThemeIndex;
  }

  ThemeMode get currentThemeMode => _themeMode;

  void toggleThemeMode() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = _themeMode; // Trigger rebuild
  }

  void setCurrentTheme(int index) {
    if (_themeMode == ThemeMode.light) {
      if (index >= 0 && index < _themesLight.length) {
        _lightThemeIndex = index;
        _themeMode = ThemeMode.light;
        state = ThemeMode.light; // Trigger state change
      }
    } else {
      if (index >= 0 && index < _themesDark.length) {
        _darkThemeIndex = index;
        _themeMode = ThemeMode.dark;
        state = ThemeMode.dark; // Trigger state change
      }
    }
    state = _themeMode; // Trigger rebuild
  }
}

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeMode>(
  (ref) => ThemeProvider(),
);
