import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:squareone_admin/ui/views/forms/shift_management/shift_controller.dart';

import 'package:squareone_admin/ui/widgets/employee_availability_widgets.dart';

import 'head/user_controller.dart';

/// Example page showing how to use all role-based system features
class RoleBasedSystemExamplePage extends StatefulWidget {
  const RoleBasedSystemExamplePage({Key? key}) : super(key: key);

  @override
  State<RoleBasedSystemExamplePage> createState() =>
      _RoleBasedSystemExamplePageState();
}

class _RoleBasedSystemExamplePageState
    extends State<RoleBasedSystemExamplePage> {
  final UserController userController = Get.find<UserController>();
  final ShiftController shiftController = Get.find<ShiftController>();

  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role-Based System'),
        backgroundColor: const Color(0xFFB71C1C),
      ),
      body: IndexedStack(
        index: selectedTabIndex,
        children: [
          // Tab 1: Employees List
          _buildEmployeesTab(),

          // Tab 2: Online Users
          _buildOnlineUsersTab(),

          // Tab 3: User Management
          _buildUserManagementTab(),

          // Tab 4: Statistics
          _buildStatisticsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTabIndex,
        onTap: (index) => setState(() => selectedTabIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Employees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.online_prediction),
            label: 'Online',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  /// Tab 1: Display all employees with availability status
  Widget _buildEmployeesTab() {
    return Obx(() {
      if (userController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final employees = userController.employees;
      if (employees.isEmpty) {
        return const Center(
          child: Text('No employees found'),
        );
      }

      return ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          final status =
              shiftController.getUserAvailabilityStatus(employee.id);
          final isOnline = status == 'Online';

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar with online indicator
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFB71C1C),
                        child: Text(
                          employee.name.characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: AvailabilityStatusIndicator(
                          userId: employee.id,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          employee.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: $status',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOnline ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('View Shift'),
                        onTap: () {
                          _showShiftDetails(context, employee.id);
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Create Shift'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => CreateShiftDialog(
                              userId: employee.id,
                              userName: employee.name,
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Edit Employee'),
                        onTap: () {
                          // Implement edit functionality
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  /// Tab 2: Display currently online users
  Widget _buildOnlineUsersTab() {
    return Obx(() {
      final onlineUserIds = shiftController.getOnlineUsers();

      if (onlineUserIds.isEmpty) {
        return const Center(
          child: Text('No users online'),
        );
      }

      return ListView.builder(
        itemCount: onlineUserIds.length,
        itemBuilder: (context, index) {
          final userId = onlineUserIds[index];
          final user = userController.getUserById(userId);

          if (user == null) return const SizedBox.shrink();

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Text(
                  user.name.characters.first.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: const Chip(
                label: Text('Online'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
              onTap: () {
                _showUserDetails(context, user);
              },
            ),
          );
        },
      );
    });
  }

  /// Tab 3: User Management
  Widget _buildUserManagementTab() {
    return Obx(() {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Create New Head
          SectionHeader(title: 'Create New Head'),
          _buildCreateUserButton(
            context: context,
            role: 'head',
            label: 'Create New Head',
          ),
          const SizedBox(height: 24),

          // Create New Employee
          SectionHeader(title: 'Create New Employee'),
          _buildCreateUserButton(
            context: context,
            role: 'employee',
            label: 'Create New Employee',
          ),
          const SizedBox(height: 24),

          // User Statistics
          SectionHeader(title: 'User Statistics'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  StatRow(
                    label: 'Total Users',
                    value: userController.allUsers.length.toString(),
                  ),
                  const Divider(),
                  StatRow(
                    label: 'Total Heads',
                    value: userController.heads.length.toString(),
                  ),
                  const Divider(),
                  StatRow(
                    label: 'Total Employees',
                    value: userController.employees.length.toString(),
                  ),
                  const Divider(),
                  StatRow(
                    label: 'Online Now',
                    value: shiftController.getOnlineUsers().length.toString(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Tab 4: Statistics
  Widget _buildStatisticsTab() {
    return Obx(() {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Roles Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Distribution',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StatRow(
                    label: 'Heads',
                    value: userController.heads.length.toString(),
                  ),
                  const Divider(),
                  StatRow(
                    label: 'Employees',
                    value: userController.employees.length.toString(),
                  ),
                  const Divider(),
                  StatRow(
                    label: 'Total',
                    value: userController.allUsers.length.toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Shift Statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shift Statistics',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StatRow(
                    label: 'Total Shifts',
                    value: shiftController.allShifts.length.toString(),
                  ),
                  const Divider(),
                  StatRow(
                    label: "Today's Shifts",
                    value: shiftController.todayShifts.length.toString(),
                  ),
                  const Divider(),
                  StatRow(
                    label: 'Online Users',
                    value:
                        shiftController.getOnlineUsers().length.toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Department Statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Departments',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StatRow(
                    label: 'Total',
                    value: 'abcd',
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Helper method to build create user button
  Widget _buildCreateUserButton({
    required BuildContext context,
    required String role,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        _showCreateUserDialog(context, role);
      },
      icon: const Icon(Icons.person_add),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB71C1C),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  /// Show create user dialog
  void _showCreateUserDialog(BuildContext context, String role) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New ${role.toTitleCase()}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter full name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await userController.createUser(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
                role: role,
                password: passwordController.text,
              );

              if (success) {
                Get.back();
                Get.snackbar('Success', '$role created successfully');
              } else {
                Get.snackbar('Error', userController.errorMessage.value);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
            ),
            child: const Text(
              'Create',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Show shift details
  void _showShiftDetails(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Today\'s Shift'),
        content: ShiftDetailsCard(userId: userId),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show user details
  void _showUserDetails(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Phone: ${user.phone}'),
            Text('Role: ${user.role}'),
            Text('Status: ${user.status}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Helper widgets

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFFB71C1C),
        ),
      ),
    );
  }
}

class StatRow extends StatelessWidget {
  final String label;
  final String value;

  const StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFFB71C1C),
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
