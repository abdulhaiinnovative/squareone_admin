import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../component/buttons.dart';
import '../../../../component/colors.dart';
import 'head_home_controller.dart';
import '../../../../component/text_feilds.dart';
import '../../../../component/dropdown_feild.dart';

class HeadAssignTicketView extends StatefulWidget {
  final HeadHomeController controller;

  const HeadAssignTicketView({super.key, required this.controller});

  @override
  State<HeadAssignTicketView> createState() => _HeadAssignTicketViewState();
}

class _HeadAssignTicketViewState extends State<HeadAssignTicketView> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  String? selectedEmployeeId;
  String? selectedEmployeeName;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();

    // Head ke department ke employees fetch karo
    if (widget.controller.departmentEmployees.isEmpty) {
      widget.controller.fetchDepartmentEmployees(
          departmentId: widget.controller.departmentName.value);
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
                    /// Employee dropdown (Head ke department ke employees)
                    Obx(() {

                      final employees = widget.controller.onShiftEmployees
                          .where((e) => e['role'] == 'employee')
                          .toList();

                      if (employees.isEmpty) {
                        return const Text("No employees available in your department");
                      }

                      return dropDown(
                        'Assign To Employee',
                        items: employees
                            .map((employee) => DropdownMenuItem<String>(
                          value: employee['id'].toString(),
                          child: Text(employee['name'] ?? 'Unknown'),
                        ))
                            .toList(),
                        value: selectedEmployeeId,
                        onChanged: (value) {
                          if (value == null) return;
                          final emp =
                          employees.firstWhere((e) => e['id'].toString() == value);
                          setState(() {
                            selectedEmployeeId = value;
                            selectedEmployeeName = emp['name'];
                          });
                        },
                      );
                    }),


                    const SizedBox(height: 20),

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
                            department:
                            widget.controller.departmentName.value,
                          );

                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        text: 'Assign Ticket',
                      ),
                    ),
                    const SizedBox(height: 20),
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
