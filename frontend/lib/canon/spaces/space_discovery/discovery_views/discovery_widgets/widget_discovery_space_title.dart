// frontend/lib/spaces/space_discovery/discovery_views/discovery_widgets/widget_discovery_space_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qspace_pages/core/style/app_style.dart';
import 'package:qspace_pages/canon/spaces/space_discovery/discovery_model/model_discovery_session.dart';

/// A single row in the recent spaces list.
/// Shows the tenant's icon (from CDN), display name, and last visited date.
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
      leading: _buildIcon(),
      title: Text(space.displayName, style: AppTypography.body),
      subtitle: Text(
        _formatDate(space.lastVisited),
        style: AppTypography.caption,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Widget _buildIcon() {
    final iconUrl = space.iconUrl;
    if (iconUrl == null) {
      return CircleAvatar(
        backgroundColor: AppColors.surface,
        child: Text(
          space.displayName.isNotEmpty
              ? space.displayName[0].toUpperCase()
              : '?',
          style: AppTypography.button,
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: AppColors.surface,
      child: ClipOval(
        child: iconUrl.endsWith('.svg')
            ? SvgPicture.network(iconUrl, width: 40, height: 40)
            : Image.network(iconUrl, width: 40, height: 40, fit: BoxFit.cover),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}