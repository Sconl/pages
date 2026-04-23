// lib/spaces/space_admin/admin_portals/brand_portal/shell_brand_root.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Brand portal shell — renders sections from
//             layout_brand_registry.dart. Owns the draft-changes banner, action
//             bar (Preview / Generate Snippet / Discard), and the snippet dialog.
//             Replaces screen_admin_brand.dart. All section-level state (controllers
//             etc.) lives inside the individual section widgets.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/style/app_style.dart';
import '../../../../core/admin/admin_brand_draft.dart';
import '../../../../core/admin/admin_config.dart';
import '../../admin_views/admin_widgets/admin_preview_panel.dart';
import 'layout_brand_config.dart';
import 'layout_brand_registry.dart';

class ShellBrandRoot extends StatelessWidget {
  const ShellBrandRoot({super.key});

  Future<void> _handleDiscard(BuildContext context, AdminBrandDraft draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceLit,
        title: Text('Discard Changes?', style: AppTypography.h4),
        content: Text(
          'All unsaved edits will be lost and the brand will revert '
          'to the last published state.',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep Editing', style: AppTypography.bodySmall),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Discard', style: AppTypography.button),
          ),
        ],
      ),
    );
    if (confirmed == true) draft.discardDraft();
  }

  void _handleGenerateSnippet(BuildContext context, AdminBrandDraft draft) {
    showDialog(
      context: context,
      builder: (_) => _SnippetDialog(snippet: draft.generateConfigSnippet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft    = AdminBrandDraftScope.of(context);
    final editable = QAdminConfigScope.of(context).accessFor('brand').editable;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kBrandPagePad),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kBrandMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(kBrandTitle, style: AppTypography.h2),
                const SizedBox(height: 6),
                Text(kBrandSubtitle, style: AppTypography.bodySmall),
                const SizedBox(height: 16),

                // Info note
                _InfoBanner(message: kBrandEditNote),
                const SizedBox(height: 12),

                // Unsaved changes banner — only when draft diverges from live
                if (draft.hasDraftChanges && editable)
                  _DraftChangesBanner(
                    onPreview:  () => AdminPanelControllerScope.of(context).open(),
                    onGenerate: () => _handleGenerateSnippet(context, draft),
                    onDiscard:  () => _handleDiscard(context, draft),
                  ),
                if (draft.hasDraftChanges && editable) const SizedBox(height: 12),

                const SizedBox(height: kBrandSectionGap - 12),

                // Sections from registry
                ...kBrandSections.expand((entry) => [
                  Text(entry.label.toUpperCase(), style: AppTypography.overline),
                  const SizedBox(height: 12),
                  entry.section,
                  const SizedBox(height: kBrandSectionGap),
                ]),

                // Action bar
                if (editable)
                  _ActionBar(
                    hasDraftChanges: draft.hasDraftChanges,
                    onPreview:  () => AdminPanelControllerScope.of(context).open(),
                    onGenerate: () => _handleGenerateSnippet(context, draft),
                    onDiscard:  () => _handleDiscard(context, draft),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _DraftChangesBanner
// ─────────────────────────────────────────────────────────────────────────────

class _DraftChangesBanner extends StatelessWidget {
  final VoidCallback onPreview;
  final VoidCallback onGenerate;
  final VoidCallback onDiscard;
  const _DraftChangesBanner({
    required this.onPreview,
    required this.onGenerate,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_outlined, size: 14, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              kBrandUnsavedMsg,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary, height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _BannerAction(label: 'Preview',  icon: Icons.preview_outlined,  onTap: onPreview),
          const SizedBox(width: 6),
          _BannerAction(label: 'Generate', icon: Icons.code_outlined,     onTap: onGenerate),
          const SizedBox(width: 6),
          _BannerAction(label: 'Discard',  icon: Icons.undo_outlined,     onTap: onDiscard, isDestructive: true),
        ],
      ),
    );
  }
}

class _BannerAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  const _BannerAction({
    required this.label, required this.icon, required this.onTap, this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.caption.copyWith(
              color: color, fontWeight: FontWeight.w600, fontSize: 10,
            )),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _ActionBar
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final bool hasDraftChanges;
  final VoidCallback onPreview;
  final VoidCallback onGenerate;
  final VoidCallback onDiscard;
  const _ActionBar({
    required this.hasDraftChanges,
    required this.onPreview,
    required this.onGenerate,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: kBrandActionBtnH,
            child: OutlinedButton.icon(
              onPressed: onPreview,
              icon: const Icon(Icons.preview_outlined, size: 16),
              label: const Text('Preview'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
              ),
            ),
          ),
        ),
        if (hasDraftChanges) ...[
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: kBrandActionBtnH,
              child: DecoratedBox(
                decoration: AppDecorations.primaryButton,
                child: ElevatedButton.icon(
                  onPressed: onGenerate,
                  icon: const Icon(Icons.code_outlined, size: 16, color: Colors.white),
                  label: Text('Generate Snippet', style: AppTypography.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: kBrandActionBtnH,
            child: OutlinedButton.icon(
              onPressed: onDiscard,
              icon: Icon(Icons.undo_outlined, size: 16, color: AppColors.error),
              label: Text('Discard',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
              ),
            ),
          ),
        ],
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _SnippetDialog
// ─────────────────────────────────────────────────────────────────────────────

class _SnippetDialog extends StatelessWidget {
  final String snippet;
  const _SnippetDialog({required this.snippet});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceLit,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
      title: Row(
        children: [
          Icon(Icons.code_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text('brand_config.dart Snippet', style: AppTypography.h4),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: AppRadius.smBR,
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 13, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Paste into brand_config.dart, replacing the CONFIG BLOCK. '
                      'In production (Cycle 3), this writes to overlay.json instead.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary, fontSize: 10, height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 340),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.smBR,
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  snippet,
                  style: TextStyle(
                    fontFamily: BrandCopy.fontAccent,
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: AppTypography.bodySmall),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: snippet));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Snippet copied to clipboard.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
              backgroundColor: AppColors.surfaceLit,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
            ));
          },
          icon: const Icon(Icons.copy_outlined, size: 14),
          label: Text('Copy to Clipboard', style: AppTypography.button),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
          ),
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _InfoBanner — shared helper
// ─────────────────────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
        borderRadius: AppRadius.cardBR,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary, height: 1.5,
          ))),
        ],
      ),
    );
  }
}