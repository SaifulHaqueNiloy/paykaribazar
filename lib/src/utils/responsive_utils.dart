import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1024;
  
  static double getSidebarWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) return w * 0.75;
    if (w < 1200) return 260.0;
    return 300.0;
  }
}
