import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/component/in_progress_tile.dart';
import 'package:squareone_admin/ui/views/tickets/head_ticket/head_ticket_detail.dart';
import 'package:squareone_admin/ui/views/tickets/head_ticket/head_ticket_tile.dart';

import '../../home/head/head_home/head_home_controller.dart';


class HeadViewTickets extends StatelessWidget {
  HeadViewTickets({super.key});

  final String? passedTitle = Get.arguments?['title'] as String?;
  final HeadHomeController controller = Get.find<HeadHomeController>();

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
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: redColor));
        }

        List<Map<String, dynamic>> ticketsToShow = [];
        String emptyMessage = "No tickets found";

        if (appBarTitle == 'Active Tickets') {
          ticketsToShow = controller.assignedTasks;
          emptyMessage = "No assigned tickets right now";
        } else if (appBarTitle == 'Pending Approval') {
          ticketsToShow = controller.pendingApprovals;
          emptyMessage = "No pending approvals right now";
        } else if (appBarTitle == 'Completed') {
          ticketsToShow = controller.completedTasks;
          emptyMessage = "No completed tickets right now";
        }else {
          ticketsToShow = [
            ...controller.assignedTasks,
            ...controller.pendingApprovals,
          ];
          emptyMessage = "No pending or assigned tickets right now";
        }

        if (ticketsToShow.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                emptyMessage,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchTaskStatistics();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ticketsToShow.length, // ✅ FIX
              itemBuilder: (context, index) {
                final ticket = ticketsToShow[index]; // ✅ FIX

                return HeadTicketTile(
                  text: ticket['title'] ?? 'No Title',
                  width: screenWidth,
                  height: screenHeight,

                  employeeName: ticket['assignedTo'] ?? 'Unassigned',
                  status: ticket['status'] ?? 'Assigned',
                  onTap: () {
                    Get.to(() => HeadTicketDetail(ticket: ticket));
                  },
                );
              },
            ),
          ),
        );

      }),
    );
  }
}