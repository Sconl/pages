import 'package:flutter/material.dart';

/// QPStructure
/// Canonical structural contract for any navigable unit inside a Space.
///
/// Enforces a 3-section hierarchy:
/// - section_core    → Primary value
/// - section_context → Supporting narrative
/// - section_connect → Actions, links, next steps, extensions
abstract class QPStructure extends StatelessWidget {
  const QPStructure({super.key});

  /// Primary value section
  Widget buildSectionCore(BuildContext context);

  /// Supporting narrative / contextual information
  Widget buildSectionContext(BuildContext context);

  /// Connection layer:
  /// - CTAs
  /// - Related content
  /// - Meta actions
  /// - Forward navigation
  Widget buildSectionConnect(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionCore(context),
          buildSectionContext(context),
          buildSectionConnect(context),
        ],
      ),
    );
  }
}