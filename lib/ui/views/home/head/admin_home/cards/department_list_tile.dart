import 'package:flutter/material.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';


class DepartmentListTile extends StatelessWidget {
  const DepartmentListTile({
    Key? key,
    required this.text,
    required this.width,
    required this.height,
     this.employeeName,
    required this.status,
    this.onTap,
  }) : super(key: key);

  final VoidCallback? onTap;
  final double width;
  final double height;
  final String text;
  final String? employeeName;
  final String status;

  @override
  Widget build(BuildContext context) {
    final String normalizedStatus = status.trim().toLowerCase();

    Color badgeBgColor;
    Color badgeTextColor;

    switch (normalizedStatus) {
      case 'assigned':
        badgeBgColor = Colors.orange.withOpacity(0.15);
        badgeTextColor = Colors.orange;
        break;
      case 'pending':
        badgeBgColor = redColor.withOpacity(0.15);
        badgeTextColor = redColor;
        break;
      case 'in progress':
        badgeBgColor = Colors.blue.withOpacity(0.15);
        badgeTextColor = Colors.blue;
        break;
      case 'completed':
        badgeBgColor = greenColor.withOpacity(0.15);
        badgeTextColor = greenColor;
        break;
      default:
        badgeBgColor = Colors.grey.withOpacity(0.15);
        badgeTextColor = Colors.grey;
    }

    final displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Unknown';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TicketButton(),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  ],
                ),
              ),

              /// Status Badge
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



