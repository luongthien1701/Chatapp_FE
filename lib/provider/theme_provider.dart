import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Color _currentTheme = Color.fromARGB(255, 27, 123, 202);
  Color _lightTheme=const Color.fromARGB(255, 205, 210, 238);
  bool isDarkMode = false;
  Color get currentTheme => _currentTheme;
  Color get lightTheme => _lightTheme;
  void changeTheme()
  {
    if (isDarkMode)
    {
      _currentTheme = const Color.fromARGB(255, 27, 123, 202);
      isDarkMode=false;
    }
    else
    {
      _currentTheme = const Color.fromARGB(255, 21, 42, 99);
      isDarkMode=true;
    }
    notifyListeners();
  }
}