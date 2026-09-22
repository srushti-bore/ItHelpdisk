import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  Color _getColor() {
    switch (priority.toUpperCase()) {
      case 'P1':
        return AppColors.priorityP1;
      case 'P2':
        return AppColors.priorityP2;
      case 'P3':
        return AppColors.priorityP3;
      case 'P4':
        return AppColors.priorityP4;
      default:
        return AppColors.priorityP3;
    }
  }

  String _getLabel() {
    switch (priority.toUpperCase()) {
      case 'P1':
        return 'P1 critical';
      case 'P2':
        return 'P2 high';
      case 'P3':
        return 'P3 medium';
      case 'P4':
        return 'P4 low';
      default:
        return priority.toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            _getLabel(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
