import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Consistent inset burgundy page header used throughout the parent portal.
class LenyoraPageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  const LenyoraPageHeader({
    super.key,
    required this.title,
    this.subtitle = 'CAPS Aligned Curriculum & Outcomes',
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 88,
        margin: const EdgeInsets.fromLTRB(6, 8, 6, 2),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.maroon,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: onBack ?? () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).maybePop();
                }
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
