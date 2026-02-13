import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/views/home/head/head_home/head_home_controller.dart';
import 'package:squareone_admin/ui/views/home/head/onshift/onshift_employee_detail.dart';
import 'package:squareone_admin/ui/views/tickets/head_ticket/head_ticket_tile.dart';
import '../../../forms/add_depart_employee/add_depart_employee_view.dart';
import 'assign_ticket_view.dart';

class WorkerView extends StatelessWidget {
  WorkerView({super.key});

  final HeadHomeController headController = Get.find<HeadHomeController>();


  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Obx(() {
          if (isSearching.value) {
            return TextField(
              controller: searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by name, email, or role...',
                border: InputBorder.none,
              ),
              onChanged: (value) => searchQuery.value = value.trim().toLowerCase(),
            );
          } else {
            return const Text(
              'Employees',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            );
          }
        }),
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(isSearching.value ? Icons.close : Icons.search, color: redColor,fontWeight: FontWeight.bold,),
              onPressed: () {
                if (isSearching.value) {
                  // Close search
                  searchQuery.value = '';
                  searchController.clear();
                }
                isSearching.value = !isSearching.value;
              },
            );
          }),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (headController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: redColor),
              );
            }

            final filteredEmployees = headController.departmentEmployees
                .where((e) => (e['role'] ?? '').toString().toLowerCase() == 'employee')
                .where((e) {
              final query = searchQuery.value;
              if (query.isEmpty) return true;

              final name = (e['name'] ?? '').toString().toLowerCase();
              final email = (e['email'] ?? '').toString().toLowerCase();
              final role = (e['role'] ?? '').toString().toLowerCase();

              return name.contains(query) ||
                  email.contains(query) ||
                  role.contains(query);
            })
                .toList();

            return RefreshIndicator(
              onRefresh: () async {
                await headController.departmentEmployees();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = filteredEmployees[index];

                  return HeadTicketTile(
                    text: employee['name'] ?? 'No Name',
                    width: screenWidth,
                    height: screenHeight,
                    employeeName: employee['department'] ?? 'No Department',
                    status: employee['role'],
                    onTap: () {
                      final employeeId = employee['id'] ?? '';
                      if (employeeId.isNotEmpty) {
                        Get.to(() => OnshiftEmployeeDetail(employee: {'id': employeeId}));
                      } else {
                        Get.snackbar('Error', 'Employee ID not available');
                      }
                    },
                  );
                },
              ),
            );
          }),

          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                // Check the current user's role
                final role = headController.currentUserRole.value.toLowerCase();

                if (role == 'admin') {
                  // Navigate to AssignTicketView for admin
                  Get.to(() => AssignTicketView(controller: headController));
                } else if (role == 'head') {
                  // Navigate to AddDepartEmployeeView for head
                  Get.to(() => const AddDepartEmployeeView());
                } else {
                  // Optional: show a message if role is something else
                  Get.snackbar('Access Denied', 'You do not have permission for this action');
                }
              },
              child: AddButton(height: screenHeight, width: screenWidth),
            ),
          ),
        ],
      ),
    );
  }
}
