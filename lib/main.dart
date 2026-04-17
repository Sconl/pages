import 'package:flutter/material.dart';

import 'core/style/app_style.dart';
import 'experience/spaces/space_admin/shell_admin/qspace_admin_shell.dart';

void main() {
  // Root entry point for the app.
  runApp(const QPagesApp());
}

class QPagesApp extends StatelessWidget {
  const QPagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BrandScope(
      // Central brand configuration for app-wide colors, typography, and copy.
      config: kBrandDefault,
      child: MaterialApp(
        // Uses branded app name instead of a hardcoded title.
        title: BrandCopy.appName,

        // Keep the app clean and production-ready.
        debugShowCheckedModeBanner: false,

        // Use your shared dark theme system.
        theme: AppTheme.dark,

        // Default landing shell for the admin space.
        home: const QAdminShell(),
      ),
    );
  }
}