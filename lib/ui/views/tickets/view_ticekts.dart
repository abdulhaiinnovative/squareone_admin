import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/in_progress_tile.dart';
import 'package:squareone_admin/ui/views/tickets/tickets_controller.dart';
import '../../component/buttons.dart';
import '../../component/colors.dart';
import '../../component/drawer_filter.dart';
import 'details/gate_pass_detail.dart';
import 'details/non_retail_activity.dart';
import 'details/security.dart';

class ViewTickets extends StatelessWidget {
  ViewTickets({super.key, this.status = "Open"});

  final data = Get.arguments;
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
                  controller.filter.value == '' &&
                          controller.formattedDate.value == ''
                      ? data[0]
                      : controller.filter.value != '' &&
                              controller.formattedDate.value == ''
                          ? "${controller.filter.value}\'s Tickets"
                          : controller.filter.value == '' &&
                                  controller.formattedDate.value != ''
                              ? "${controller.formattedDate.value}\'s Tickets"
                              : controller.filter.value != '' &&
                                      controller.formattedDate.value != ''
                                  ? "${controller.filter.value}(${controller.formattedDate.value})"
                                  : "",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ),
                automaticallyImplyLeading: true,
                backgroundColor: Colors.white,
              ),
              body: StreamBuilder(
                  stream: controller.filter.value == '' &&
                          controller.formattedDate.value == ''
                      ? FirebaseFirestore.instance
                          .collection('Tickets')
                          .where('Status', isEqualTo: status)
                          .where('header', isEqualTo: data[1])
                          .snapshots()
                      : controller.filter.value != '' &&
                              controller.formattedDate.value == ''
                          ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: status)
                              .where('header', isEqualTo: data[1])
                              .where('Outlet',
                                  isEqualTo: controller.filter.value)
                              .snapshots()
                          : controller.filter.value == '' &&
                                  controller.formattedDate.value != ''
                              ? FirebaseFirestore.instance
                                  .collection('Tickets')
                                  .where('Status', isEqualTo: status)
                                  .where('header', isEqualTo: data[1])
                                  .where('Date',
                                      isEqualTo: controller.formattedDate.value)
                                  .snapshots()
                              : FirebaseFirestore.instance
                                  .collection('Tickets')
                                  .where('Status', isEqualTo: status)
                                  .where('header', isEqualTo: data[1])
                                  .where('Outlet',
                                      isEqualTo: controller.filter.value)
                                  .where('Date',
                                      isEqualTo: controller.formattedDate.value)
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
                              print(asyncSnapshot.data!.docs.length);
                              // print(asyncSnapshot.data!.docs[index]['header']);
                              switch (asyncSnapshot.data!.docs[index]
                                  ['header']) {
                                case 'Gate-Pass-Outwards(Food Court Outlet)':
                                  return GestureDetector(
                                    onTap: () => Get.to(() => GateInwardDetails(
                                          inProgress: status == 'Approved'
                                              ? false
                                              : true,
                                          ticketId: asyncSnapshot.data!
                                              .docs[index]['Ticket Number'],
                                        )),
                                    child: InProgressTicketTile(
                                        outletName: asyncSnapshot
                                            .data!.docs[index]["Outlet"],
                                        status: status == "Approved"
                                            ? "Approved"
                                            : "Pending",
                                        text: asyncSnapshot.data!.docs[index]
                                            ['header'],
                                        width: width,
                                        height: height,
                                        header: 'Quantity: ',
                                        headerText:
                                            '${asyncSnapshot.data!.docs[index]['Quantity']} PC'),
                                  );
                                case 'Gate-Pass-Outwards(Retail Outlet)':
                                  return GestureDetector(
                                    onTap: () => Get.to(() => GateInwardDetails(
                                          inProgress: status == 'Approved'
                                              ? false
                                              : true,
                                          ticketId: asyncSnapshot.data!
                                              .docs[index]['Ticket Number'],
                                        )),
                                    child: InProgressTicketTile(
                                        outletName: asyncSnapshot
                                            .data!.docs[index]["Outlet"],
                                        status: status == "Approved"
                                            ? "Approved"
                                            : "Pending",
                                        text: asyncSnapshot.data!.docs[index]
                                            ['header'],
                                        width: width,
                                        height: height,
                                        header: 'Quantity: ',
                                        headerText:
                                            '${asyncSnapshot.data!.docs[index]['Quantity']} PC'),
                                  );
                                case 'Gate-Pass-Inward(Retail Outlet)':
                                  return GestureDetector(
                                    onTap: () => Get.to(() => GateInwardDetails(
                                          inProgress: status == 'Approved'
                                              ? false
                                              : true,
                                          ticketId: asyncSnapshot.data!
                                              .docs[index]['Ticket Number'],
                                        )),
                                    child: InProgressTicketTile(
                                        outletName: asyncSnapshot
                                            .data!.docs[index]["Outlet"],
                                        status: status == "Approved"
                                            ? "Approved"
                                            : "Pending",
                                        text: asyncSnapshot.data!.docs[index]
                                            ['header'],
                                        width: width,
                                        height: height,
                                        header: 'Quantity: ',
                                        headerText:
                                            '${asyncSnapshot.data!.docs[index]['Quantity']} PC'),
                                  );
                                case 'Gate-Pass-Inward(Food Court Outlet)':
                                  return GestureDetector(
                                    onTap: () => Get.to(() => GateInwardDetails(
                                          inProgress: status == 'Approved'
                                              ? false
                                              : true,
                                          ticketId: asyncSnapshot.data!
                                              .docs[index]['Ticket Number'],
                                        )),
                                    child: InProgressTicketTile(
                                        outletName: asyncSnapshot
                                            .data!.docs[index]["Outlet"],
                                        status: status == "Approved"
                                            ? "Approved"
                                            : "Pending",
                                        text: asyncSnapshot.data!.docs[index]
                                            ['header'],
                                        width: width,
                                        height: height,
                                        header: 'Quantity: ',
                                        headerText:
                                            '${asyncSnapshot.data!.docs[index]['Quantity']} PC'),
                                  );
                                case 'Non-Retail-Hour-Activity(Retail Outlet)':
                                  return GestureDetector(
                                      onTap: () => Get.to(
                                            () => NonRentalActivity(
                                              inProgress: status == 'Approved'
                                                  ? false
                                                  : true,
                                              ticketId: asyncSnapshot.data!
                                                  .docs[index]['Ticket Number'],
                                            ),
                                          ),
                                      child: InProgressTicketTile(
                                        outletName: asyncSnapshot
                                            .data!.docs[index]["Outlet"],
                                        status: status == "Approved"
                                            ? "Approved"
                                            : "Pending",
                                        text: asyncSnapshot.data!.docs[index]
                                            ['header'],
                                        width: width,
                                        height: height,
                                        header: 'Activity: ',
                                        headerText: asyncSnapshot
                                            .data!.docs[index]['Activity'],
                                      ));

                                case 'Non-Retail-Hour-Activity(Food Court Outlet)':
                                  return GestureDetector(
                                      onTap: () => Get.to(
                                            () => NonRentalActivity(
                                              inProgress: status == 'Approved'
                                                  ? false
                                                  : true,
                                              ticketId: asyncSnapshot.data!
                                                  .docs[index]['Ticket Number'],
                                            ),
                                          ),
                                      child: InProgressTicketTile(
                                        outletName: asyncSnapshot
                                            .data!.docs[index]["Outlet"],
                                        status: status == "Approved"
                                            ? "Approved"
                                            : "Pending",
                                        text: asyncSnapshot.data!.docs[index]
                                            ['header'],
                                        width: width,
                                        height: height,
                                        header: 'Activity: ',
                                        headerText: asyncSnapshot
                                            .data!.docs[index]['Activity'],
                                      ));

                                case 'Maintainance(Retail Outlet)':
                                  return GestureDetector(
                                    onTap: () =>
                                        Get.to(() => SecurityTicektDetails(
                                              inProgress: status == 'Approved'
                                                  ? false
                                                  : true,
                                              ticketId: asyncSnapshot.data!
                                                  .docs[index]['Ticket Number'],
                                            )),
                                    child: InProgressTicketTile(
                                        outletName: asyncSnapshot
                                            .data!.docs[index]["Outlet"],
                                        status: status == "Approved"
                                            ? "Approved"
                                            : "Pending",
                                        text: asyncSnapshot.data!.docs[index]
                                            ['header'],
                                        width: width,
                                        height: height,
                                        header: 'Activity: ',
                                        headerText: asyncSnapshot
                                            .data!.docs[index]['Activity']),
                                  );
                                case 'Maintainance(Food Court Outlet)':
                                  return GestureDetector(
                                    onTap: () =>
                                        Get.to(() => SecurityTicektDetails(
                                              inProgress: status == 'Approved'
                                                  ? false
                                                  : true,
                                              ticketId: asyncSnapshot.data!
                                                  .docs[index]['Ticket Number'],
                                            )),
                                    child: InProgressTicketTile(
                                        outletName: asyncSnapshot
                                            .data!.docs[index]["Outlet"],
                                        status: status == "Approved"
                                            ? "Approved"
                                            : "Pending",
                                        text: asyncSnapshot.data!.docs[index]
                                            ['header'],
                                        width: width,
                                        height: height,
                                        header: 'Activity: ',
                                        headerText: asyncSnapshot
                                            .data!.docs[index]['Activity']),
                                  );
                              }

                              return const Center(
                                child: CircularProgressIndicator(
                                  color: redColor,
                                ),
                              );
                            });
                  }));
        });
  }
}
