import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/component/details_function.dart';

import '../head_home/head_home_controller.dart';


class OnshiftEmployeeDetail extends StatelessWidget {
  final Map<String, dynamic> employee; // Renamed from ticket → employee

  const OnshiftEmployeeDetail({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final controller = Get.find<HeadHomeController>();

    // Employee ID from the employee map (which is passed from onShiftEmployees)
    final String employeeId = employee['id'] ?? '';
    final String empDepartment = employee['department'] ?? 'N/A';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: ButtonBack(height: height, width: width),
        title: const Text(
          'Employee Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: employeeId.isNotEmpty
            ? FirebaseFirestore.instance.collection('personnel').doc(employeeId).get()
            : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: redColor));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading employee data'));
          }

          final doc = snapshot.data;
          if (doc == null || !doc.exists) {
            return Center(
              child: Text(
                'Employee data not found',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          final employeeData = doc.data() as Map<String, dynamic>;

          final String empName = employeeData['name'] ?? employee['name'] ?? 'Unknown';
          final String empEmail = employeeData['email'] ?? 'N/A';
          final String empPassword = employeeData['password'] ?? 'N/A';
          final String empPhone = employeeData['phone'] ?? 'N/A';
          final String empRole = employeeData['role'] ?? 'employee';
          final String empStatus = employeeData['status'] ?? 'Offline';
          final bool isOnShift = controller.checkEmployeeOnlineStatus(employeeData['shifts'] ?? []);

          String shiftTime = 'No shift today';
          final shifts = employeeData['shifts'] as List<dynamic>? ?? [];
          final todayShift = shifts.firstWhere(
                (shift) {
              if (shift is! Map<String, dynamic>) return false;
              final shiftDate = shift['date'] as String?;
              final now = DateTime.now();
              final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
              return shiftDate == today;
            },
            orElse: () => null,
          );

          if (todayShift != null && todayShift is Map<String, dynamic>) {
            final start = todayShift['start_time'] ?? 'N/A';
            final end = todayShift['end_time'] ?? 'N/A';
            shiftTime = '$start - $end';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Card(
              elevation: 8,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔹 Employee Name + Shift Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            empName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isOnShift
                                ? redColor.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isOnShift ? redColor : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOnShift ? 'On Shift' : 'Off Shift',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isOnShift ? redColor : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(),

                    /// 🔹 Contact Information
                    _sectionTitle('Contact Information'),
                    _detailRow('Email', empEmail),
                    _detailRow('Password', empPassword),
                    _detailRow('Phone', empPhone),

                    const SizedBox(height: 12),
                    const Divider(),

                    /// 🔹 Shift Information
                    _sectionTitle('Shift Details'),
                    _detailRow('Today\'s Shift', shiftTime),
                    _detailRow('On Shift Now', isOnShift ? 'Yes' : 'No'),
                    if (shifts.isNotEmpty)
                      _detailRow('Total Shifts', '${shifts.length} scheduled'),

                    const SizedBox(height: 12),
                    const Divider(),

                    /// 🔹 Employee Meta
                    _sectionTitle('Employee Info'),
                    _detailRow('Role', empRole),
                    _detailRow('Current Status', isOnShift ? 'Online' : 'Offline'),

          _detailRow('Department', empDepartment),


          const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );

        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _detailRow(String head, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              head,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

}