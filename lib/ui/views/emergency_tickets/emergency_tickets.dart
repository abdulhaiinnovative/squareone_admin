import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import '../../component/buttons.dart';
import '../../component/drawer_filter.dart';
import '../../component/in_progress_tile.dart';
import '../tickets/details/gate_pass_detail.dart';
import '../tickets/tickets_controller.dart';

class EmergencyTickets extends StatelessWidget {
  const EmergencyTickets({super.key, required this.urgent});
  final bool urgent;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return GetX<TicketController>(
        init: Get.put<TicketController>(TicketController()),
        builder: (controller) {
          return Scaffold(
              backgroundColor: Colors.white,
              endDrawer: FilterDrawer(
                width: width,
                height: height,
                urgentTicket: urgent,
              ),
              appBar: AppBar(
                iconTheme: const IconThemeData(color: redColor),
                elevation: 0,
                leading: ButtonBack(
                  height: height,
                  width: width,
                ),
                title: Text(
                  controller.filter.value == ''
                      ? 'Urgent Tickets'
                      : '${controller.filter.value}\'s Tickets',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ),
                automaticallyImplyLeading: true,
                backgroundColor: Colors.white,
              ),
              body: StreamBuilder(
                  stream: controller.filter.value == ""
                      ? FirebaseFirestore.instance
                          .collection('Emergency Tickets')
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('Emergency Tickets')
                          .where('Outlet Name',
                              isEqualTo: controller.filter.value)
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
                                  onTap: () => Get.to(() => GateInwardDetails(
                                        ticketId: asyncSnapshot
                                            .data!.docs[index]['Ticket Number'],
                                      )),
                                  child: ClosedTickets(
                                    outletName: asyncSnapshot.data!.docs[index]
                                        ['Outlet'],
                                    head: 'Quantity',
                                    text: asyncSnapshot.data!.docs[index]
                                        ['header'],
                                    width: width,
                                    height: height,
                                    header: 'Quantity: ',
                                    headerText:
                                        '${asyncSnapshot.data!.docs[index]['Quantity']} PC',
                                  ));
                            });
                  }));
        });
  }
}
