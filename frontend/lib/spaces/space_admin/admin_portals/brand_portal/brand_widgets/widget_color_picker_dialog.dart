// lib/spaces/space_admin/admin_portals/brand_portal/brand_widgets/widget_color_picker_dialog.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Hex text input + 24-swatch preset grid. Returns the
//             selected Color via Navigator.pop. Apply disabled on invalid hex.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/style/app_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

const List<Color> kColorPresets = [
  Color(0xFF9933FF), Color(0xFF6E1FF7), Color(0xFF4C00D9),
  Color(0xFFAD5CFF), Color(0xFFD4A0FF),
  Color(0xFF0F91D2), Color(0xFF1565C0), Color(0xFF0288D1),
  Color(0xFF4FC3F7), Color(0xFF0D47A1),
  Color(0xFF00897B), Color(0xFF2E7D32), Color(0xFF43A047),
  Color(0xFF00E676), Color(0xFF00BFA5),
  Color(0xFFE53935), Color(0xFFD81B60), Color(0xFFAD1457),
  Color(0xFFFF4081), Color(0xFFFF7043),
  Color(0xFFFAAF2E), Color(0xFFFBC02D), Color(0xFFFF8F00),
  Color(0xFF607D8B),
];

// ─────────────────────────────────────────────────────────────────────────────

class WidgetColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  const WidgetColorPickerDialog({super.key, required this.initialColor});

  @override
  State<WidgetColorPickerDialog> createState() => _WidgetColorPickerDialogState();
}

class _WidgetColorPickerDialogState extends State<WidgetColorPickerDialog> {

  late Color _selected;
  late TextEditingController _hexCtrl;
  String? _hexError;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor;
    _hexCtrl  = TextEditingController(text: _toHex(_selected));
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    super.dispose();
  }

  String _toHex(Color c) {
    final argb = c.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${argb.substring(2)}';
  }

  Color? _parseHex(String raw) {
    final clean = raw.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final v = int.tryParse('FF$clean', radix: 16);
      return v != null ? Color(v) : null;
    }
    if (clean.length == 8) {
      final v = int.tryParse(clean, radix: 16);
      return v != null ? Color(v) : null;
    }
    return null;
  }

  void _onHexChanged(String val) {
    final parsed = _parseHex(val);
    setState(() {
      if (parsed != null) { _selected = parsed; _hexError = null; }
      else { _hexError = 'Valid hex required (e.g. #9933FF)'; }
    });
  }

  void _selectPreset(Color c) {
    setState(() {
      _selected     = c;
      _hexCtrl.text = _toHex(c);
      _hexError     = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceLit,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
      title: Text('Pick a Color', style: AppTypography.h4),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live swatch
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: _selected,
                borderRadius: AppRadius.smBR,
                border: Border.all(color: _selected.withValues(alpha: 0.4)),
                boxShadow: [BoxShadow(color: _selected.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3))],
              ),
            ),
            const SizedBox(height: 14),

            // Hex input
            TextField(
              controller: _hexCtrl,
              onChanged: _onHexChanged,
              style: AppTypography.bodySmall.copyWith(fontFamily: BrandCopy.fontAccent),
              decoration: InputDecoration(
                labelText: 'Hex Code',
                labelStyle: AppTypography.caption,
                hintText: '#9933FF',
                errorText: _hexError,
                filled: true,
                fillColor: AppColors.surface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputBR,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputBR,
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputBR,
                  borderSide: BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),

            Text('Presets', style: AppTypography.overline),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kColorPresets.map((c) {
                final isActive = _selected == c;
                return GestureDetector(
                  onTap: () => _selectPreset(c),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isActive ? Colors.white : Colors.transparent,
                        width: isActive ? 2 : 0,
                      ),
                      boxShadow: isActive
                          ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 6)]
                          : null,
                    ),
                    child: isActive
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTypography.bodySmall),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selected,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
          ),
          onPressed: _hexError == null
              ? () => Navigator.pop(context, _selected)
              : null,
          child: Text('Apply', style: AppTypography.button),
        ),
      ],
    );
  }
}