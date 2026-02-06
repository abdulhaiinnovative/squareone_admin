import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/views/forms/add_depart_employee/add_depart_employee_view.dart';
import 'package:squareone_admin/ui/views/forms/add_depart_member/add_depart_member_view.dart';
import 'package:squareone_admin/ui/views/forms/add_outlet/add_outlet_view.dart';
import 'package:squareone_admin/ui/views/home/home_controller.dart';

import 'package:squareone_admin/ui/views/forms/shift_management/shift_management_view.dart';
import 'package:squareone_admin/ui/views/team_availability_dashboard.dart';
import 'package:squareone_admin/ui/views/tickets/view_ticekts.dart';
import 'package:squareone_admin/ui/views/forms/shift_management/users_list_view.dart';
import '../../../component/buttons.dart';
import '../../../component/colors.dart';
import '../../../component/department_tile.dart';
import '../../auth/auth_controller.dart';
import '../../../component/assign_new_task_card.dart';
import '../../../component/metric_card.dart';
import '../../../component/section_title.dart';
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
        return SingleChildScrollView(
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
                      height: height * 1.8,
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
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftManagementView()));
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
                                onTap: () async {
                                  await Get.find<LoginController>().logout();
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
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => TeamAvailabilityDashboard()));
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
                      title: 'Assign New Task',
                      subTitle: 'Create and assign tasks',
                      function: () => Get.to(() => const AddDepartmentView()),
                    ),
                    // ========== PENDING APPROVALS SECTION ==========
                    if (controller.pendingApprovals.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle('Pending Approvals'),
                            const SizedBox(height: 10),
                            Obx(
                              () => ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: controller.pendingApprovals.length,
                                itemBuilder: (context, index) {
                                  var task = controller.pendingApprovals[index];
                                  return _buildPendingApprovalCard(
                                    context,
                                    task,
                                    controller,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),



                    // ========== ACTIVE TASKS SECTION ==========
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Card(
                        elevation: 12,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Title
                              SectionTitle('Active Tasks'),

                              const SizedBox(height: 10),

                              /// Content
                              Obx(
                                    () => controller.activeTasks.isEmpty
                                    ? Container(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.activeTasks.length,
                                  separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    var task = controller.activeTasks[index];
                                    return _buildActiveTaskCard(task);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),


                    // ========== EMPLOYEE AVAILABILITY SECTION ==========
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Card(
                        elevation: 12,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Title
                              SectionTitle('Department Employees (On Shift)'),

                              const SizedBox(height: 10),

                              /// Content
                              Obx(
                                    () => controller.onShiftEmployees.isEmpty
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
                                  itemCount: controller.onShiftEmployees.length,
                                  separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    var employee =
                                    controller.onShiftEmployees[index];
                                    return _buildEmployeeCard(employee);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),


                    // ========== QUICK ACTIONS ==========
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AssignNewTaskCard(
                          controller: controller,
                          height: height,
                          width: width,
                          title: 'Add Employee',
                          subTitle: null, function: () => Get.to(() => const AddDepartEmployeeView()),
                        ),
                      ],

                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========== HELPER WIDGETS ==========

  /// Build metric card widget
  // Widget _buildMetricCard({
  //   required String title,
  //   required RxInt count,
  //   required IconData icon,
  //   required Color color,
  // }) {
  //   return Card(
  //     elevation: 8,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         gradient: LinearGradient(
  //           colors: [color, color.withOpacity(0.7)],
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Icon(icon, color: Colors.white, size: 28),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Obx(
  //                   () => Text(
  //                     count.value.toString(),
  //                     style: TextStyle(
  //                       fontSize: 24,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ),
  //                 Text(
  //                   title,
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: Colors.white70,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
    Color statusColor = _getStatusColor(task['status']);
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
                  child: Text(
                    task['title'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task['status'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned to: ${task['assignedTo'] ?? 'Unassigned'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Due: ${task['dueDate'] ?? 'No date'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task['priority']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task['priority'] ?? 'Normal',
                    style: TextStyle(
                      fontSize: 11,
                      color: _getPriorityColor(task['priority']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build employee card
  Widget _buildEmployeeCard(Map employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF27BB4A),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Shift: ${employee['shiftStart'] ?? 'N/A'} - ${employee['shiftEnd'] ?? 'N/A'}',
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
                color: Color(0xFF27BB4A).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'On Shift',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF27BB4A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ========== DIALOG FUNCTIONS ==========

  void _showAssignTaskDialog(
      BuildContext context, HeadHomeController controller) {
    TextEditingController taskTitleController = TextEditingController();
    TextEditingController dueDateController = TextEditingController();
    String selectedCategory = 'Gate Pass Inward';
    String selectedPriority = 'Normal';
    String selectedEmployeeId = '';
    String selectedEmployeeName = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Assign New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: taskTitleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: [
                    'Gate Pass Inward',
                    'Gate Pass Outward',
                    'Maintenance',
                    'Non-Retail Hour Activity',
                    'Food Court Activity',
                  ]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedCategory = value ?? '');
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  items: ['Low', 'Normal', 'High', 'Critical']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedPriority = value ?? '');
                  },
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value:
                        selectedEmployeeId.isEmpty ? null : selectedEmployeeId,
                    items: controller.onShiftEmployees
                        .map<DropdownMenuItem<String>>(
                            (emp) => DropdownMenuItem<String>(
                                  value: emp['id'].toString(),
                                  child: Text(emp['name'].toString()),
                                ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        var emp = controller.onShiftEmployees
                            .firstWhere((e) => e['id'] == value);
                        setState(() {
                          selectedEmployeeId = value;
                          selectedEmployeeName = emp['name'];
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Assign to Employee',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: dueDateController,
                  decoration: InputDecoration(
                    labelText: 'Due Date (optional)',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 30)),
                    );
                    if (picked != null) {
                      setState(() {
                        dueDateController.text =
                            picked.toString().split(' ')[0];
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        if (taskTitleController.text.isEmpty ||
                            selectedEmployeeId.isEmpty) {
                          Get.snackbar(
                              'Error', 'Please fill all required fields');
                          return;
                        }
                        await controller.assignTaskToEmployee(
                          taskTitle: taskTitleController.text,
                          category: selectedCategory,
                          employeeId: selectedEmployeeId,
                          employeeName: selectedEmployeeName,
                          dueDate: dueDateController.text.isNotEmpty
                              ? dueDateController.text
                              : null,
                          priority: selectedPriority,
                        );
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF27BB4A),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Assign', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Color(0xFF27BB4A);
      case 'Normal':
        return Color(0xFF2196F3);
      case 'High':
        return Color(0xFFFFA726);
      case 'Critical':
        return Color(0xFFC12934);
      default:
        return Color(0xFF9E9E9E);
    }
  }
}
void _showAssignTaskDialog(
    BuildContext context, HeadHomeController controller) {
  TextEditingController taskTitleController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  String selectedCategory = 'Gate Pass Inward';
  String selectedPriority = 'Normal';
  String selectedEmployeeId = '';
  String selectedEmployeeName = '';

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Assign New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskTitleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: [
                  'Gate Pass Inward',
                  'Gate Pass Outward',
                  'Maintenance',
                  'Non-Retail Hour Activity',
                  'Food Court Activity',
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedCategory = value ?? '');
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                items: ['Low', 'Normal', 'High', 'Critical']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedPriority = value ?? '');
                },
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              Obx(
                    () => DropdownButtonFormField<String>(
                  value:
                  selectedEmployeeId.isEmpty ? null : selectedEmployeeId,
                  items: controller.onShiftEmployees
                      .map<DropdownMenuItem<String>>(
                          (emp) => DropdownMenuItem<String>(
                        value: emp['id'].toString(),
                        child: Text(emp['name'].toString()),
                      ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      var emp = controller.onShiftEmployees
                          .firstWhere((e) => e['id'] == value);
                      setState(() {
                        selectedEmployeeId = value;
                        selectedEmployeeName = emp['name'];
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Assign to Employee',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(
                  labelText: 'Due Date (optional)',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() {
                      dueDateController.text =
                      picked.toString().split(' ')[0];
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          Obx(
                () => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () async {
                if (taskTitleController.text.isEmpty ||
                    selectedEmployeeId.isEmpty) {
                  Get.snackbar(
                      'Error', 'Please fill all required fields');
                  return;
                }
                await controller.assignTaskToEmployee(
                  taskTitle: taskTitleController.text,
                  category: selectedCategory,
                  employeeId: selectedEmployeeId,
                  employeeName: selectedEmployeeName,
                  dueDate: dueDateController.text.isNotEmpty
                      ? dueDateController.text
                      : null,
                  priority: selectedPriority,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF27BB4A),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text('Assign', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}

// void _showAddEmployeeDialog(BuildContext context, HeadHomeController controller) {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController shiftDateController = TextEditingController();
//   TextEditingController shiftStartController = TextEditingController();
//   TextEditingController shiftEndController = TextEditingController();
//
//   showDialog(
//     context: context,
//     builder: (context) => StatefulBuilder(
//       builder: (context, setState) => AlertDialog(
//         title: Text('Add New Employee'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Employee Name
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Employee Name',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//               ),
//               SizedBox(height: 15),
//
//               // Email
//               TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               SizedBox(height: 15),
//
//               // Phone Number
//               TextField(
//                 controller: phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.phone),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               SizedBox(height: 15),
//
//               // Password
//               TextField(
//                 controller: passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.lock),
//                 ),
//                 obscureText: true,
//               ),
//               SizedBox(height: 15),
//
//               // Shift Date
//               TextField(
//                 controller: shiftDateController,
//                 decoration: InputDecoration(
//                   labelText: 'Shift Date (YYYY-MM-DD)',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.calendar_today),
//                   hintText: '2026-01-23',
//                 ),
//                 readOnly: true,
//                 onTap: () async {
//                   DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime.now().add(Duration(days: 365)),
//                   );
//                   if (picked != null) {
//                     setState(() {
//                       shiftDateController.text =
//                           '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
//                     });
//                   }
//                 },
//               ),
//               SizedBox(height: 15),
//
//               // Shift Start Time
//               TextField(
//                 controller: shiftStartController,
//                 decoration: InputDecoration(
//                   labelText: 'Shift Start Time (HH:MM:SS)',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.schedule),
//                   hintText: '09:00:00',
//                 ),
//                 readOnly: true,
//                 onTap: () async {
//                   TimeOfDay? picked = await showTimePicker(
//                     context: context,
//                     initialTime: TimeOfDay.now(),
//                   );
//                   if (picked != null) {
//                     setState(() {
//                       shiftStartController.text =
//                           '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
//                     });
//                   }
//                 },
//               ),
//               SizedBox(height: 15),
//
//               // Shift End Time
//               TextField(
//                 controller: shiftEndController,
//                 decoration: InputDecoration(
//                   labelText: 'Shift End Time (HH:MM:SS)',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.schedule),
//                   hintText: '17:00:00',
//                 ),
//                 readOnly: true,
//                 onTap: () async {
//                   TimeOfDay? picked = await showTimePicker(
//                     context: context,
//                     initialTime: TimeOfDay.now(),
//                   );
//                   if (picked != null) {
//                     setState(() {
//                       shiftEndController.text =
//                           '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           Obx(
//             () => ElevatedButton(
//               onPressed: controller.isLoading.value
//                   ? null
//                   : () async {
//                       if (nameController.text.isEmpty ||
//                           emailController.text.isEmpty ||
//                           phoneController.text.isEmpty ||
//                           passwordController.text.isEmpty ||
//                           shiftDateController.text.isEmpty ||
//                           shiftStartController.text.isEmpty ||
//                           shiftEndController.text.isEmpty) {
//                         Get.snackbar(
//                           'Error',
//                           'Please fill all required fields',
//                         );
//                         return;
//                       }
//
//                       await controller.addEmployeeToFirebase(
//                         name: nameController.text,
//                         email: emailController.text,
//                         phone: phoneController.text,
//                         password: passwordController.text,
//                         shiftDate: shiftDateController.text,
//                         shiftStart: shiftStartController.text,
//                         shiftEnd: shiftEndController.text,
//                       );
//                       Navigator.pop(context);
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFF27BB4A),
//               ),
//               child: controller.isLoading.value
//                   ? SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : Text('Add Employee',
//                       style: TextStyle(color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }