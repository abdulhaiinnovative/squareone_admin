import 'package:flutter/material.dart';
import 'package:squareone_admin/ui/views/home/head/models/user_model.dart';
import 'availability_badge.dart';

/// A card widget to display user information with role and availability status
class UserCard extends StatelessWidget {
  final User user;
  final bool isOnline;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;

  const UserCard({
    Key? key,
    required this.user,
    required this.isOnline,
    this.onTap,
    this.onEditTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AvailabilityBadge(isOnline: isOnline),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      user.isHead() ? 'Department Head' : 'Employee',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: user.isHead()
                        ? Colors.purple.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: user.isHead() ? Colors.purple : Colors.blue,
                    ),
                  ),
                  if (onEditTap != null)
                    GestureDetector(
                      onTap: onEditTap,
                      child: Icon(
                        Icons.edit,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Phone: ${user.phone}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
