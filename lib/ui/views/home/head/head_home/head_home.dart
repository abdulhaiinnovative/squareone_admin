import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/in_progress_tile.dart';
import 'package:squareone_admin/ui/views/forms/add_depart_employee/add_depart_employee_view.dart';
import 'package:squareone_admin/ui/views/forms/add_depart_member/add_depart_member_view.dart';
import 'package:squareone_admin/ui/views/forms/add_outlet/add_outlet_view.dart';
import 'package:squareone_admin/ui/views/home/head/head_home/head_assign_ticket_view.dart';
import 'package:squareone_admin/ui/views/home/head/onshift/onshift_employee_detail.dart';
import 'package:squareone_admin/ui/views/home/home_controller.dart';

import 'package:squareone_admin/ui/views/forms/shift_management/shift_management_view.dart';
import 'package:squareone_admin/ui/views/home/role_based_system_example_page.dart';
import 'package:squareone_admin/ui/views/team_availability_dashboard.dart';
import 'package:squareone_admin/ui/views/tickets/head_ticket/head_ticket_detail.dart';
import 'package:squareone_admin/ui/views/tickets/head_ticket/head_view_tickets.dart';
import 'package:squareone_admin/ui/views/tickets/view_ticekts.dart';
import 'package:squareone_admin/ui/views/forms/shift_management/users_list_view.dart';
import '../../../../component/buttons.dart';
import '../../../../component/colors.dart';
import '../../../../component/department_tile.dart';
import '../../../auth/auth_controller.dart';
import '../../../../component/assign_new_task_card.dart';
import '../../../../component/metric_card.dart';
import '../../../../component/section_title.dart';

import 'assign_ticket_view.dart';
import 'head_home_controller.dart';

class HeadHome extends StatefulWidget {
  const HeadHome({super.key});

  @override
  State<HeadHome> createState() => _HeadHomeState();
}

class _HeadHomeState extends State<HeadHome> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    log(context.height.toString());

    return GetBuilder<HeadHomeController>(
      init: Get.put<HeadHomeController>(HeadHomeController()),
      builder: (controller) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchHeadInfo();
              await controller.fetchDepartmentEmployees();
              await controller.fetchTaskStatistics();
            },
            child: SingleChildScrollView(
              child: Container(

                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Header Background
                    Column(
                      children: [
                        Container(
                          width: width,
                          height: height / 7,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/home/DSC_8735.png'),
                                  fit: BoxFit.cover)),
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: context.height * 0.03),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Obx(
                                          () => Text(
                                        'Hi ${controller.headName.value}! Welcome to Square1',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: height < 1000 ? 15 : 22,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Main Content Area
                    Column(
                      children: [
                        Container(
                          height: height * 0.1,
                          margin: EdgeInsets.only(
                            top: height * 0.12,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    // Scrollable Content
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [

                        SizedBox(
                          height: height * 0.08,
                        ),

                        // ========== DASHBOARD METRICS ==========
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionTitle('Department Overview'),
                              const SizedBox(height: 12),
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                childAspectRatio: height < 700
                                    ? 1.2
                                    : height < 900
                                    ? 1.1
                                    : height < 1000
                                    ? 1.3
                                    : 1.5,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                children: [
                                  // Active Tasks Card
                                  MetricCard(
                                    onTap: () {
                                      Get.to(() => HeadViewTickets(),
                                          arguments: {'title': 'Active Tickets'});
                                    },
                                    title: 'Active Tickets',
                                    count: controller.activeTasksCount,
                                    icon: Icons.assignment,
                                    color: Color(0xFF27BB4A),
                                    width: width,
                                    height: height,
                                    subtitle: 'Total Tickets',
                                  ),
                                  // Pending Approvals Card
                                  MetricCard(
                                    onTap: () {
                                      Get.to(() => HeadViewTickets(),
                                          arguments: {'title': 'Pending Approval'});
                                    },
                                    title: 'Pending Approvals',
                                    count: controller.pendingApprovalsCount,
                                    icon: Icons.check_circle,
                                    color: Color(0xFFC12934),
                                    width: width,
                                    height: height,
                                    subtitle: 'Total Tickets',
                                  ),
                                  // Completed Tasks Card
                                  MetricCard(
                                    onTap: ()  {
                                      Get.to(() => HeadViewTickets(),
                                          arguments: {'title': 'Completed'});
                                    },
                                    title: 'Completed',
                                    count: controller.completedTasksCount,
                                    icon: Icons.done_all,
                                    color: Color(0xFF4CAF50),
                                    width: width,
                                    height: height,
                                    subtitle: 'Total Tickets',
                                  ),
                                  // On Shift Employees Card
                                  MetricCard(
                                    onTap: () {
                                      Get.to(() => TeamAvailabilityDashboard());
                                    },
                                    title: 'On Shift',
                                    count: controller.onShiftEmployeesCount,
                                    icon: Icons.people,
                                    color: Color(0xFF2196F3),
                                    width: width,
                                    height: height,
                                    subtitle: 'Total Tickets',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ========== ASSIGN TASK BUTTON ==========
                        AssignNewTaskCard(
                          controller: controller,
                          height: height,
                          width: width,
                          title: 'Assign New Ticket',
                          subTitle: 'Create and assign tickets',
                          function: () => Get.to(
                                  () => HeadAssignTicketView(controller: controller)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AssignNewTaskCard(
                              controller: controller,
                              height: height,
                              width: width,
                              title: 'Add Employee',
                              subTitle: null,
                              function: () =>
                                  Get.to(() =>  AddDepartEmployeeView()),
                            ),
                          ],
                        ),

                        // ========== ACTIVE TASKS SECTION ==========
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Title
                              SectionTitle('Active Tickets'),

                              const SizedBox(height: 5),

                              /// Content - Show 1 task (or all if expanded)
                              Obx(
                                    () {
                                  final displayCount =
                                  controller.expandTasks.value
                                      ? controller.activeTasks.length
                                      : (controller.activeTasks.length > 1
                                      ? 1
                                      : controller.activeTasks.length);

                                  return controller.activeTasks.isEmpty
                                      ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'No active tasks',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                      : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    itemCount: displayCount,
                                    separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      var task =
                                      controller.activeTasks[index];
                                      final ticket = controller.assignedTasks[index];
                                      return GestureDetector(
                                          onTap: (){
                                            Get.to(() => HeadTicketDetail(ticket: ticket));
                                          },
                                          child: _buildActiveTaskCard(task));
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 5),
                              /// Expand/Collapse Button
                              Obx(() {
                                if (controller.activeTasks.length > 1) {
                                  return Center(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        controller.expandTasks.value =
                                        !controller.expandTasks.value;
                                      },
                                      icon: Icon(
                                        controller.expandTasks.value
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 18,
                                      ),
                                      label: Text(
                                        controller.expandTasks.value
                                            ? 'Show Less'
                                            : 'More (${controller.activeTasks.length})',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        shadowColor: Colors.black.withOpacity(0.65),
                                        backgroundColor: redColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),


                            ],
                          ),
                        ),

                        // ========== EMPLOYEE AVAILABILITY SECTION ==========
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Title
                              SectionTitle('On Shift'),

                              const SizedBox(height: 5),

                              Obx(
                                    () {
                                  // Sirf employees filter
                                  final employees = controller.onShiftEmployees
                                      .where((e) => e['role'] == 'employee')
                                      .toList();

                                  final displayCount = controller.expandEmployees.value
                                      ? employees.length
                                      : (employees.length > 1 ? 1 : employees.length);

                                  return employees.isEmpty
                                      ? Container(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'No employees on shift currently',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                      : ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: displayCount,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      var employee = employees[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Get.to(() => OnshiftEmployeeDetail(employee: employee));
                                        },
                                        child: _buildEmployeeCard(employee),
                                      );
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 5),
                              /// Expand/Collapse Button
                              Obx(() {
                                // Sirf employee role wale count ke liye filter
                                final employees = controller.onShiftEmployees
                                    .where((e) => e['role'] == 'employee')
                                    .toList();

                                if (employees.length > 1) {
                                  return Center(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        controller.expandEmployees.value = !controller.expandEmployees.value;
                                      },
                                      icon: Icon(
                                        controller.expandEmployees.value
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 18,
                                      ),
                                      label: Text(
                                        controller.expandEmployees.value
                                            ? 'Show Less'
                                            : 'View All (${employees.length})', // ← filtered length
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        shadowColor: Colors.black.withOpacity(0.65),
                                        backgroundColor: redColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),

                            ],
                          ),
                        ),

                        // ========== QUICK ACTIONS ==========


                        SizedBox(height: 30),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  /// Build pending approval card
  Widget _buildPendingApprovalCard(
      BuildContext context, Map task, HeadHomeController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                        task['title'] ?? 'No Title',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Assigned to: ${task['assignee'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFC12934).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFC12934),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApprovalDialog(
                      context,
                      task['id'],
                      controller,
                      'approve',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF27BB4A),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text('Approve',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApprovalDialog(
                      context,
                      task['id'],
                      controller,
                      'reject',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC12934),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text('Reject',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build active task card
  Widget _buildActiveTaskCard(Map task) {
    // Determine status color (you already have this helper)
    Color statusColor = _getStatusColor(task['status'] ?? 'Unknown');

    // Status background & text color logic (matching your HeadTicketTile)
    Color statusBgColor;
    Color statusTextColor;

    if ((task['status'] ?? '') == 'Assigned') {
      statusBgColor = Colors.orange.withOpacity(0.2);
      statusTextColor = Colors.orange;
    } else if ((task['status'] ?? '') == 'Completed') {
      statusBgColor = greenColor.withOpacity(0.15);
      statusTextColor = textGreenColor;
    } else {
      // Default for In Progress, Open, etc.
      statusBgColor = statusColor.withOpacity(0.15);
      statusTextColor = statusColor;
    }

    return SizedBox(
      width: double.infinity, // or use MediaQuery width / 1.1 if needed
      child: Card(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.65),
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Ticket icon + Title + Employee Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const TicketButton(), // your ticket icon button
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ticket Title
                        Text(
                          task['title'] ?? 'No Title',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Assigned to (Employee Name)
                        Row(
                          children: [
                            const Text(
                              "to: ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                task['assignedTo'] ?? 'Unassigned',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 16),
                  Container(
                    alignment: Alignment.center,
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.77), // yahin color change karo
                      shape: BoxShape.circle,
                    ),
                  ),

                ],
              ),



              // Status Badge (right aligned)

            ],
          ),
        ),
      ),
    );
  }

  /// Build employee card
  Widget _buildEmployeeCard(Map employee) {
    return Card(
      // margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.65),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: redColor,
              child: Text(
                (employee['name'] ?? 'U')[0].toUpperCase(),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee['name'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Shift: ${employee['shifts']?[0]?['start_time'] ?? 'N/A'} - ${employee['shifts']?[0]?['end_time'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.77), // yahin color change karo
                shape: BoxShape.circle,
              ),
            )

          ],
        ),
      ),
    );
  }

  // ========== DIALOG FUNCTIONS ==========



  void _showApprovalDialog(BuildContext context, String taskId,
      HeadHomeController controller, String action) {
    if (action == 'approve') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Approve Task'),
          content: Text('Are you sure you want to approve this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.approveTask(taskId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF27BB4A),
              ),
              child: Text('Approve', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      TextEditingController reasonController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Reject Task'),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Reason for rejection',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.isEmpty) {
                  Get.snackbar('Error', 'Please provide a reason');
                  return;
                }
                await controller.rejectTask(taskId, reasonController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC12934),
              ),
              child: Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  // ========== COLOR HELPER FUNCTIONS ==========

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Color(0xFF2196F3);
      case 'Assigned':
        return Color(0xFFFFC107);
      case 'In Progress':
        return Color(0xFFFFA726);
      case 'Completed':
        return Color(0xFF27BB4A);
      default:
        return Color(0xFF9E9E9E);
    }
  }
}
