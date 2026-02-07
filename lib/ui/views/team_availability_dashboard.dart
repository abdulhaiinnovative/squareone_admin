import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/component/section_title.dart';
import 'package:squareone_admin/ui/views/home/head/head_home_controller.dart';

class TeamAvailabilityDashboard extends StatelessWidget {
  const TeamAvailabilityDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// 🔹 HEADER IMAGE
          Column(
            children: [
              Container(
                width: width,
                height: height / 4,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/home/DSC_8735.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  alignment: Alignment.centerLeft,
                  color: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.only(left: 24),
                  child: const Text(
                    'Team Availability',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// 🔹 WHITE CONTENT CONTAINER
          Container(
            margin: EdgeInsets.only(top: height * 0.2),
            width: width,
            height: height / 1.3,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: GetBuilder<HeadHomeController>(
              builder: (controller) {
                // Filter employees: must have role = "employee"
                final onShiftUsers = controller.onShiftEmployees
                    .where((emp) => (emp['role'] ?? '').toString().toLowerCase() == 'employee')
                    .toList();
                final allUsers = controller.departmentEmployees
                    .where((emp) => (emp['role'] ?? '').toString().toLowerCase() == 'employee')
                    .toList();

                final offShiftUsers = allUsers
                    .where((emp) => !onShiftUsers
                    .any((on) => on['id'] == emp['id']))
                    .toList();

                return SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔹 SUMMARY CARDS
                      Row(
                        children: [
                          _summaryCard(
                              'On Shift', onShiftUsers.length, redColor),
                          const SizedBox(width: 12),
                          _summaryCard(
                              'Off Shift', offShiftUsers.length, Colors.grey),
                          const SizedBox(width: 12),
                          _summaryCard(
                              'Total', allUsers.length, Colors.orange),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// 🔹 ON SHIFT
                      if (onShiftUsers.isNotEmpty) ...[
                        SectionTitle('On Shift (${onShiftUsers.length})'),
                        const SizedBox(height: 8),
                        ...onShiftUsers.map(
                              (e) => _employeeTile(e, true),
                        ),
                        const SizedBox(height: 24),
                      ],

                      /// 🔹 OFF SHIFT
                      if (offShiftUsers.isNotEmpty) ...[
                        SectionTitle('Off Shift (${offShiftUsers.length})'),
                        const SizedBox(height: 8),
                        ...offShiftUsers.map(
                              (e) => _employeeTile(e, false),
                        ),
                      ],

                      if (allUsers.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No employees found'),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 SUMMARY CARD
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

  /// 🔹 EMPLOYEE TILE
  Widget _employeeTile(Map<String, dynamic> emp, bool onShift) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          onShift ? redColor.withOpacity(0.2) : Colors.grey.shade300,
          child: Icon(
            onShift ? Icons.check_circle : Icons.schedule,
            color: onShift ? redColor: Colors.grey,
          ),
        ),
        title: Text(
          emp['name'] ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          emp['email'] ?? '',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: onShift
                ? redColor.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            onShift ? 'On Duty' : 'Off Duty',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: onShift ? redColor : Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
