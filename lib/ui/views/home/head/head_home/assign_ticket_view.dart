import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/dropdown_feild.dart';
import 'package:squareone_admin/ui/component/text_feilds.dart';
import 'package:squareone_admin/ui/views/forms/add_depart_head_employee_from_admin/add_depart_head_employee_from_admin_controller.dart';
import '../../../../component/buttons.dart';
import '../../../../component/colors.dart';
import 'head_home_controller.dart';


class AssignTicketView extends StatefulWidget {
  final HeadHomeController controller;

  const AssignTicketView({super.key, required this.controller});

  @override
  State<AssignTicketView> createState() => _AssignTicketViewState();
}

class _AssignTicketViewState extends State<AssignTicketView> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  String? selectedEmployeeId;
  String? selectedEmployeeName;

  String? selectedDepartment;



  final AddDepartHeadEmployeeFromAdminController departmentController = Get.put(
    AddDepartHeadEmployeeFromAdminController(),
  );

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();

    // Fetch initial employees
    if (widget.controller.departmentEmployees.isEmpty) {
      widget.controller.fetchDepartmentEmployees(departmentId: 'General');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            /// Header image
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
                  'Assign Ticket',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            /// Form
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    textField('Ticket Title', titleController),
                    textField('Description', descriptionController),

                    /// 👇 Department dropdown reactive
                    Obx(() {
                      return dropDown(
                        'Department',
                        items: departmentController.departmentsList
                            .map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        ))
                            .toList(),
                        value: selectedDepartment,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedDepartment = value; // ← Update the local state
                            });

                            departmentController.selectedDepartment.value = value;

                            // Fetch employees for selected department
                            widget.controller.fetchDepartmentEmployees(departmentId: value);
                          }
                        },
                      );
                    }),


                    /// Employee dropdown
                    Obx(() {
                      return dropDown(
                        'Assign To Employee',
                        items: widget.controller.onShiftEmployees
                            .map((employee) => DropdownMenuItem<String>(
                          value: employee['id'].toString(),
                          child: Text(employee['name'] ?? 'Unknown'),
                        ))
                            .toList(),
                        value: selectedEmployeeId,
                        onChanged: (value) {
                          if (value == null) return;
                          final emp = widget.controller.onShiftEmployees
                              .firstWhere((e) => e['id'].toString() == value);
                          setState(() {
                            selectedEmployeeId = value;
                            selectedEmployeeName = emp['name'];
                          });
                        },
                      );
                    }),

                    /// Assign Button
                    Obx(
                          () => widget.controller.isLoading.value
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: redColor,
                        ),
                      )
                          : LoginButton(
                        width: width + 100,
                        height: height,
                        function: () async {
                          if (titleController.text.isEmpty ||
                              descriptionController.text.isEmpty ||
                              selectedEmployeeId == null) {
                            Get.snackbar(
                              'Error',
                              'All fields are required',
                              backgroundColor: redColor,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          await widget.controller.assignTaskToEmployee(
                            taskTitle: titleController.text,
                            taskDescription: descriptionController.text,
                            employeeId: selectedEmployeeId!,
                            employeeName: selectedEmployeeName!,
                            department: selectedDepartment
                          );

                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        text: 'Assign Ticket',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

