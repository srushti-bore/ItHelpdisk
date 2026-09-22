import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'new':
        return AppColors.statusNew;
      case 'in_assessment':
      case 'assigned':
        return AppColors.statusInProgress;
      case 'awaiting_requester':
      case 'awaiting_approval':
      case 'pending':
        return AppColors.statusAwaiting;
      case 'resolved':
        return AppColors.statusResolved;
      case 'closed':
        return AppColors.statusClosed;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.statusNew;
    }
  }

  String _getLabel() {
    switch (status.toLowerCase()) {
      case 'in_assessment':
        return 'In assessment';
      case 'awaiting_requester':
        return 'Awaiting requester';
      case 'awaiting_approval':
        return 'Awaiting approval';
      case 'assigned':
        return 'Assigned';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      case 'cancelled':
        return 'Cancelled';
      case 'new':
        return 'New';
      default:
        return status.replaceAll('_', ' ').toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
