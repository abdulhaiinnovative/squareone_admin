import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/in_progress_tile.dart';
import 'package:squareone_admin/ui/views/tickets/tickets_controller.dart';

import '../../../component/buttons.dart';
import '../../../component/colors.dart';
import '../../../component/drawer_filter.dart';
import '../details/non_retail_activity.dart';

class MarketingTickets extends StatelessWidget {
  const MarketingTickets({
    super.key,
    required this.status,
  });
  final String status;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GetX<TicketController>(
        init: Get.put<TicketController>(TicketController()),
        builder: (controller) {
          return Scaffold(
              backgroundColor: Colors.white,
              endDrawer: FilterDrawer(
                  width: width, urgentTicket: false, height: height),
              appBar: AppBar(
                iconTheme: const IconThemeData(color: redColor),
                elevation: 0,
                leading: ButtonBack(
                  height: height,
                  width: width,
                ),
                title: Text(
                  controller.filter.value == ''
                      ? 'Branding Activity'
                      : '${controller.filter.value}\'s Tickets',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ),
                automaticallyImplyLeading: true,
                backgroundColor: Colors.white,
              ),
              body: StreamBuilder(
                  stream: controller.filter.value == ''
                      ? FirebaseFirestore.instance
                          .collection('Tickets')
                          .where('Status', isEqualTo: status)
                          .where('Department', isEqualTo: 'Marketing')
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('Tickets')
                          .where('Status', isEqualTo: status)
                          .where('Department', isEqualTo: 'Marketing')
                          .where('Outlet', isEqualTo: controller.filter.value)
                          .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
                    return !asyncSnapshot.hasData
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: redColor,
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: asyncSnapshot.data!.docs.length,
                            padding: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () => Get.to(
                                        () => NonRentalActivity(
                                          ticketId: asyncSnapshot.data!
                                              .docs[index]['Ticket Number'],
                                        ),
                                      ),
                                  child: InProgressTicketTile(
                                    outletName: asyncSnapshot.data!.docs[index]
                                        ["Outlet"],
                                    text: asyncSnapshot.data!.docs[index]
                                        ['header'],
                                    width: width,
                                    height: height,
                                    header: 'Activity: ',
                                    headerText: asyncSnapshot.data!.docs[index]
                                        ['Activity'],
                                  ));
                            });
                  }));
        });
  }
}
