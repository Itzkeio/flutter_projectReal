import 'package:flutter/material.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
void toggleTheme() {
  themeModeNotifier.value =
      themeModeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}