import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/controllers/user_controller.dart';
import 'package:squareone_admin/ui/views/forms/shift_management/shift_controller.dart';
import '../component/user_card.dart';

/// A view to display all users (heads and employees) with their availability status
class UsersListView extends StatelessWidget {
  const UsersListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
        elevation: 0,
      ),
      body: GetBuilder<UserController>(
        builder: (userController) {
          return GetBuilder<ShiftController>(
            builder: (shiftController) {
              return userController.allUsers.isEmpty
                  ? const Center(
                      child: Text('No users found'),
                    )
                  : ListView.builder(
                      itemCount: userController.allUsers.length,
                      itemBuilder: (context, index) {
                        final user = userController.allUsers[index];
                        final isOnline = shiftController
                            .userAvailability[user.id]
                            .obs
                            .value ??
                          false;

                        return UserCard(
                          user: user,
                          isOnline: isOnline,
                          onTap: () {
                            // Show user details
                            _showUserDetails(context, user);
                          },
                          onEditTap: () {
                            // Navigate to edit user screen
                            Get.toNamed(
                              '/edit-user',
                              arguments: user,
                            );
                          },
                        );
                      },
                    );
            },
          );
        },
      ),
    );
  }

  void _showUserDetails(BuildContext context, dynamic user) {
    Get.dialog(
      AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Phone: ${user.phone}'),
            Text('Role: ${user.isHead() ? 'Department Head' : 'Employee'}'),
            if (user.departmentId != null)
              Text('Department: ${user.departmentId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
