import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/views/home/head/admin_home/cards/department_list_tile.dart';
import 'package:squareone_admin/ui/views/home/head/onshift/onshift_employee_detail.dart';
import 'package:squareone_admin/ui/views/tickets/head_ticket/head_ticket_tile.dart';
import '../../../../forms/add_depart/add_depart_view.dart';
import 'cards_controller.dart';

class DepartmentListView extends StatelessWidget {
  DepartmentListView({super.key});

  final CardsController controller = Get.put(CardsController());
  final String? passedTitle = Get.arguments?['title'] as String?;



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    return RefreshIndicator(
      onRefresh: () async{
        await controller.fetchDepartments();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: redColor),
          elevation: 0,
          leading: ButtonBack(height: screenHeight, width: screenWidth),
          title:  Text(
            'Departments',
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
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.departments.length,
                itemBuilder: (context, index) {
                  final depart = controller.departments[index];

                  return DepartmentListTile(
                    text: depart['name'] ?? 'No Name',
                    width: screenWidth,
                    height: screenHeight,
                    status: "depart" ?? 'no',
                    onTap: () {

                      Get.to(() => OnshiftEmployeeDetail(employee: depart));
                    },
                  );
                },
              );
            }),
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                  onTap: (){
                    Get.to(() =>
                    const AddDepartView());
                  },
                  child: AddButton(height: screenHeight, width: screenWidth)),
            ),
          ],
        )
      ),
    );
  }
}
