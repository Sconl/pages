import 'package:flutter/material.dart';
import 'experience/spaces/space_value/views/view_engine_status.dart';

void main() {
  runApp(const QSpacePagesApp());
}

class QSpacePagesApp extends StatelessWidget {
  const QSpacePagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QSpace Pages',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ViewEngineStatus(),
    );
  }
}