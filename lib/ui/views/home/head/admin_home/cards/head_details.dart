import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/views/home/head/admin_home/cards/cards_controller.dart';



class HeadDetails extends StatelessWidget {
  final DocumentSnapshot employee; // Renamed from ticket → employee

  const HeadDetails({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final controller = Get.find<CardsController>();

    // Employee ID from the employee map (which is passed from onShiftEmployees)
    final String employeeId = employee['id'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: ButtonBack(height: height, width: width),
        title: const Text(
          'Head Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: employeeId.isNotEmpty
            ? FirebaseFirestore.instance.collection('personnel').doc(employeeId).get()
            : Future.value(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: redColor));
          }

          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Employee data not found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final hodData = snapshot.data!.data() as Map<String, dynamic>;

          final String hodName = hodData['name'] ?? employee['name'] ?? 'Unknown';
          final String hodEmail = hodData['email'] ?? 'N/A';
          final String hodPassword = hodData['password'] ?? 'N/A';
          final String hodPhone = hodData['phone'] ?? 'N/A';
          final String hodRole = hodData['role'] ?? 'employee';
          final String hodStatus = hodData['status'] ?? 'Offline';
          final bool isOnShift = controller.checkEmployeeOnlineStatus(hodData['shifts'] ?? []);

          String shiftTime = 'No shift today';
          final shifts = hodData['shifts'] as List<dynamic>? ?? [];
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
                            hodName,
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
                    _detailRow('Email', hodEmail),
                    _detailRow('Phone', hodPhone),

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
                    _detailRow('Role', hodRole),
                    _detailRow('Current Status', hodStatus),
                    _detailRow('Department', controller.departmentName.value),

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