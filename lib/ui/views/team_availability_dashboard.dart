import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/component/section_title.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'home/head/head_home/head_home_controller.dart';
import 'home/head/onshift/onshift_employee_detail.dart';

class TeamAvailabilityDashboard extends StatelessWidget {
  TeamAvailabilityDashboard({Key? key}) : super(key: key);

  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final controller = Get.find<HeadHomeController>();

    // Load staff if empty
    if (controller.departmentEmployees.isEmpty && !controller.isLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        controller.isLoading.value = true;

        final role = controller.currentUserRole.value.toLowerCase();

        if (role == 'admin') {
          await controller.fetchDepartmentStaff(); // heads + employees
        } else if (role == 'head') {
          await controller.fetchDepartmentEmployees(); // only employees of same dept
        }

        controller.isLoading.value = false;
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: redColor),
        elevation: 0,
        leading: ButtonBack(height: height, width: width),
        title: Obx(() {
          if (isSearching.value) {
            return TextField(
              controller: searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by name, email, role, or shift...',
                border: InputBorder.none,
              ),
              onChanged: (value) => searchQuery.value = value.trim().toLowerCase(),
            );
          } else {
            return const Text(
              'Team Availability',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            );
          }
        }),
        backgroundColor: Colors.white,
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(
                  isSearching.value ? Icons.close : Icons.search,
                  color: redColor,fontWeight: FontWeight.bold),
              onPressed: () {
                if (isSearching.value) {
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
          GetBuilder<HeadHomeController>(
            init: controller,
            builder: (controller) {
              final staffList = controller.departmentEmployees;

              // Apply search filtering
              final filteredStaff = staffList.where((emp) {
                if (searchQuery.value.isEmpty) return true;

                final query = searchQuery.value;
                final name = (emp['name'] ?? '').toString().toLowerCase();
                final email = (emp['email'] ?? '').toString().toLowerCase();
                final role = (emp['role'] ?? '').toString().toLowerCase();
                final shiftStatus = (emp['availability'] == true ? 'on' : 'off');

                return name.contains(query) ||
                    email.contains(query) ||
                    role.contains(query) ||
                    shiftStatus.contains(query);
              }).toList();

              final onShiftUsers =
              filteredStaff.where((e) => e['availability'] == true).toList();
              final offShiftUsers =
              filteredStaff.where((e) => e['availability'] != true).toList();

              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (filteredStaff.isEmpty) {
                return const Center(child: Text('No staff members found'));
              }

              return SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SUMMARY CARDS
                    Row(
                      children: [
                        _summaryCard('On Shift', onShiftUsers.length, redColor),
                        const SizedBox(width: 12),
                        _summaryCard('Off Shift', offShiftUsers.length, Colors.grey),
                        const SizedBox(width: 12),
                        _summaryCard('Total', filteredStaff.length, Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ON SHIFT
                    if (onShiftUsers.isNotEmpty) ...[
                      SectionTitle('On Shift (${onShiftUsers.length})'),
                      const SizedBox(height: 8),
                      ...onShiftUsers.map(
                            (emp) => GestureDetector(
                          onTap: () {
                            Get.to(() => OnshiftEmployeeDetail(employee: emp));
                          },
                          child: _employeeTicketStyleTile(emp, true),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // OFF SHIFT
                    if (offShiftUsers.isNotEmpty) ...[
                      SectionTitle('Off Shift (${offShiftUsers.length})'),
                      const SizedBox(height: 8),
                      ...offShiftUsers.map(
                            (emp) => GestureDetector(
                          onTap: () {
                            Get.to(() => OnshiftEmployeeDetail(employee: emp));
                          },
                          child: _employeeTicketStyleTile(emp, false),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _employeeTicketStyleTile(Map<String, dynamic> emp, bool onShift) {
    final statusColor = onShift ? redColor : Colors.grey;

    return SizedBox(
      width: double.infinity,
      child: Card(
        surfaceTintColor: Colors.transparent,
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.65),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  onShift ? Icons.check_circle : Icons.schedule,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      emp['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
