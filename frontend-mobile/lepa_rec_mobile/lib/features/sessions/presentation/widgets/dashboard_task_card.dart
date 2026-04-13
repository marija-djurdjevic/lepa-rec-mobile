import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// This widget is currently unused. Dashboard builds task cards inline.
// Kept for potential future reuse.
@Deprecated('Dashboard builds task cards inline; keep only for future reuse.')
class DashboardTaskCard extends StatelessWidget {
  final String title;
  final String? description;
  final String type;
  final VoidCallback onTap;

  const DashboardTaskCard({
    super.key,
    required this.title,
    this.description,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6B9B6E), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: _buildTaskIcon()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B9B6E),
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF6B9B6E),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskIcon() {
    switch (type.toLowerCase()) {
      case 'reflection':
        return const Icon(
          Icons.lightbulb_outline,
          color: Color(0xFF6B9B6E),
          size: 24,
        );
      case 'journal':
        return const Icon(
          Icons.description_outlined,
          color: Color(0xFF6B9B6E),
          size: 24,
        );
      case 'scenario':
        return const Icon(
          Icons.psychology_outlined,
          color: Color(0xFF6B9B6E),
          size: 24,
        );
      default:
        return const Icon(
          Icons.check_box_outline_blank,
          color: Color(0xFF6B9B6E),
          size: 24,
        );
    }
  }
}
