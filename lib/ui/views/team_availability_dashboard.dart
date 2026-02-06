import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/views/home/head/user_controller.dart';
import 'package:squareone_admin/ui/views/forms/shift_management/shift_controller.dart';
import '../component/user_card.dart';
import '../component/availability_badge.dart';

/// A dashboard view showing team availability and status
class TeamAvailabilityDashboard extends StatelessWidget {
  const TeamAvailabilityDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Availability'),
        elevation: 0,
      ),
      body: GetBuilder<UserController>(
        builder: (userController) {
          return GetBuilder<ShiftController>(
            builder: (shiftController) {
              // Separate users into online and offline
              final List<dynamic> onlineUsers = [];
              final List<dynamic> offlineUsers = [];

              for (var user in userController.allUsers) {
                final isOnline = shiftController.userAvailability[user.id] ?? false;
                if (isOnline) {
                  onlineUsers.add(user);
                } else {
                  offlineUsers.add(user);
                }
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Summary Cards
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Online',
                              onlineUsers.length.toString(),
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Offline',
                              offlineUsers.length.toString(),
                              Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Users',
                              userController.allUsers.length.toString(),
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Online Users Section
                    if (onlineUsers.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Online (${onlineUsers.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: onlineUsers.length,
                        itemBuilder: (context, index) {
                          final user = onlineUsers[index];
                          return UserCard(
                            user: user,
                            isOnline: true,
                          );
                        },
                      ),
                    ],

                    // Offline Users Section
                    if (offlineUsers.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Offline (${offlineUsers.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: offlineUsers.length,
                        itemBuilder: (context, index) {
                          final user = offlineUsers[index];
                          return UserCard(
                            user: user,
                            isOnline: false,
                          );
                        },
                      ),
                    ],

                    if (userController.allUsers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No users found'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
