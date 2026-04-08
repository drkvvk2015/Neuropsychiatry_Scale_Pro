import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double phone = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

class ResponsiveLayout {
  static bool isPhone(BuildContext context) => MediaQuery.sizeOf(context).width < AppBreakpoints.phone;
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppBreakpoints.phone && width < AppBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

  static int gridColumns(BuildContext context, {int phone = 1, int tablet = 2, int desktop = 3}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return phone;
  }
}

class ResponsivePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  const ResponsivePage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.maxWidth = 1400,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
