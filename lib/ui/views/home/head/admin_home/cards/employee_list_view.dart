import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/views/home/head/onshift/onshift_employee_detail.dart';
import 'package:squareone_admin/ui/views/tickets/head_ticket/head_ticket_tile.dart';
import '../../../../forms/add_depart_head_employee_from_admin/add_depart_head_employee_from_admin_view.dart';
import 'cards_controller.dart';

class EmployeeListView extends StatelessWidget {
  EmployeeListView({super.key});

  final CardsController controller = Get.put(CardsController());
  final String? passedTitle = Get.arguments?['title'] as String?;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final appBarTitle = passedTitle ?? 'Department Tickets';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: redColor),
        elevation: 0,
        leading: ButtonBack(height: screenHeight, width: screenWidth),
        title: Text(
          appBarTitle,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: redColor),
              );
            }

            List<Map<String, dynamic>> cardsToShow = [];
            String emptyMessage = "No found";

            if (appBarTitle == 'Departments') {
              cardsToShow = controller.departments;
              emptyMessage = "No Departments right now";
            } else if (appBarTitle == 'Department Heads') {
              cardsToShow = controller.headsList;
              emptyMessage = "No Department Heads right now";
            } else if (appBarTitle == 'Employees') {
              cardsToShow = controller.departmentEmployees;
              emptyMessage = "No Employees right now";
            } else if (appBarTitle == 'Completed') {
              cardsToShow = controller.completedTasks;
              emptyMessage = "No completed tickets right now";
            } else {
              cardsToShow = [
                ...controller.headsList,
                ...controller.headsList,
              ];
              emptyMessage = "No pending or assigned tickets right now";
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (appBarTitle == 'Departments') {
                  await controller.fetchDepartments();
                } else if (appBarTitle == 'Department Heads') {
                  await controller.fetchHeads();
                } else {
                  // For other screens, you can decide
                  await controller.fetchHeads();
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: cardsToShow.length,
                itemBuilder: (context, index) {
                  final head = cardsToShow[index];

                  return HeadTicketTile(
                    text: head['name'] ?? 'No Name',
                    width: screenWidth,
                    height: screenHeight,
                    employeeName: head['department'] ?? 'No Department',
                    status: "Head",
                    onTap: () {
                      Get.to(() => OnshiftEmployeeDetail(employee: head));
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
              onTap: (){
                Get.to(() =>
                const AddDepartHeadEmployeeFromAdminView());
              },
                child: AddButton(height: screenHeight, width: screenWidth)),
          ),
        ],
      ),
    );
  }
}
