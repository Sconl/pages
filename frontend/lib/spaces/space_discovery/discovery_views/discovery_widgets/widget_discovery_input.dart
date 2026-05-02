// frontend/lib/spaces/space_discovery/discovery_views/discovery_widgets/widget_discovery_input.dart

import 'package:flutter/material.dart';
import 'package:qspace_pages/core/style/app_style.dart';

/// Styled URL input field for the discovery search section.
/// Follows the app_style single-import rule.
class WidgetDiscoveryInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;

  const WidgetDiscoveryInput({
    super.key,
    required this.controller,
    this.errorText,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:      controller,
      onSubmitted:     onSubmitted,
      textInputAction: TextInputAction.go,
      keyboardType:    TextInputType.url,
      autocorrect:     false,
      style:           AppTypography.input,
      decoration: InputDecoration(
        hintText:    'yourorg.qpages.io',
        hintStyle:   AppTypography.input.copyWith(color: AppColors.textHint),
        errorText:   errorText,
        prefixIcon:  const Icon(Icons.link_rounded),
        filled:      true,
        fillColor:   AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   BorderSide(color: AppColors.borderFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   BorderSide(color: AppColors.borderError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide:   BorderSide(color: AppColors.borderError, width: 2),
        ),
      ),
    );
  }
}