// lib/spaces/space_discovery/discovery_views/discovery_widgets/widget_discovery_space_tile.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Created to resolve missing file error referenced by
//             section_discovery_recent.dart. Single saved-space list row.
// ─────────────────────────────────────────────────────────────────────────────
//
// A single row in the recent spaces list inside SectionDiscoveryRecent.
//
// Shows:
//   - Tenant icon (from CDN URL in SavedTenantSpace.iconUrl)
//     SVG logos use SvgPicture.network via flutter_svg.
//     PNG/WebP logos use Image.network.
//     No iconUrl → fallback to initial letter avatar.
//   - Tenant display name
//   - "Last visited" relative date label
//   - Chevron to indicate tappability

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:qspace_pages/core/style/app_style.dart';
import 'package:qspace_pages/spaces/space_discovery/discovery_model/model_discovery_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WidgetDiscoverySpaceTile
// ─────────────────────────────────────────────────────────────────────────────

class WidgetDiscoverySpaceTile extends StatelessWidget {
  final SavedTenantSpace space;
  final VoidCallback onTap;

  const WidgetDiscoverySpaceTile({
    super.key,
    required this.space,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading:        _buildIcon(),
      title:          Text(space.displayName, style: AppTypography.body),
      subtitle:       Text(
        _relativeDate(space.lastVisited),
        style: AppTypography.caption,
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }

  // ── Icon ─────────────────────────────────────────────────────────────────

  Widget _buildIcon() {
    final url = space.iconUrl;

    if (url == null || url.isEmpty) {
      return _LetterAvatar(displayName: space.displayName);
    }

    if (url.toLowerCase().endsWith('.svg')) {
      return CircleAvatar(
        backgroundColor: AppColors.surface,
        child: ClipOval(
          child: SvgPicture.network(
            url,
            width:  40,
            height: 40,
            fit:    BoxFit.cover,
            placeholderBuilder: (_) => _LetterAvatar(displayName: space.displayName),
          ),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: AppColors.surface,
      child: ClipOval(
        child: Image.network(
          url,
          width:      40,
          height:     40,
          fit:        BoxFit.cover,
          errorBuilder: (_, _, _) =>
              _LetterAvatar(displayName: space.displayName),
        ),
      ),
    );
  }

  // ── Date formatting ───────────────────────────────────────────────────────

  String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LetterAvatar — fallback when no icon URL is available
// ─────────────────────────────────────────────────────────────────────────────

class _LetterAvatar extends StatelessWidget {
  final String displayName;
  const _LetterAvatar({required this.displayName});

  @override
  Widget build(BuildContext context) {
    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return CircleAvatar(
      backgroundColor: AppColors.surface,
      child: Text(initial, style: AppTypography.button),
    );
  }
}