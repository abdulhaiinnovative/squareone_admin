import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:squareone_admin/ui/component/in_progress_tile.dart';
import 'package:squareone_admin/ui/views/tickets/tickets_controller.dart';

import '../../component/buttons.dart';
import '../../component/colors.dart';
import '../../component/drawer_filter.dart';
import 'details/gate_pass_detail.dart';
import 'details/non_retail_activity.dart';
import 'details/security.dart';

class ClosedTicketsView extends StatelessWidget {
  const ClosedTicketsView({super.key});
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
            width: width,
            height: height,
            urgentTicket: false,
          ),
          appBar: AppBar(
            iconTheme: const IconThemeData(color: redColor),
            elevation: 0,
            leading: ButtonBack(height: height, width: width),
            title: Text(
              controller.filter.value == '' &&
                      controller.formattedDate.value == ''
                  ? "Closed Tickets"
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
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
          ),
          body: StreamBuilder(
            stream: (() {
              // Get today's date in the format dd-MM-yyyy
              String todayDate = DateFormat(
                'dd-MM-yyyy',
              ).format(DateTime.now());

              return controller.depart.value == 'Operations' ||
                      controller.depart.value == 'Admin' ||
                      controller.depart.value == 'Security' ||
                      controller.depart.value == 'CR'
                  ? controller.filter.value == '' &&
                            controller.formattedDate.value == ''
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where('Date', isEqualTo: todayDate)
                              
                              .snapshots()
                        : controller.filter.value == '' &&
                              controller.formattedDate.value != ''
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                'Date',
                                isEqualTo: controller.formattedDate.value,
                              )
                              
                              .snapshots()
                        : controller.filter.value != '' &&
                              controller.formattedDate.value == ''
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                'Outlet',
                                isEqualTo: controller.filter.value,
                              )
                              .where('Date', isEqualTo: todayDate)
                              
                              .snapshots()
                        : controller.filter.value != "" &&
                              controller.formattedDate.value != ""
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                'Outlet',
                                isEqualTo: controller.filter.value,
                              )
                              .where(
                                'Date',
                                isEqualTo: controller.formattedDate.value,
                              )
                              
                              .snapshots()
                        : FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where('Date', isEqualTo: todayDate)
                              
                              .snapshots()
                  : controller.depart.value == 'Marketing' ||
                        controller.depart.value == 'Maintainance'
                  ? controller.filter.value == '' &&
                            controller.formattedDate.value == ''
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                'Department',
                                isEqualTo: controller.depart.value,
                              )
                              .where('Date', isEqualTo: todayDate)
                              
                              .snapshots()
                        : controller.filter.value == '' &&
                              controller.formattedDate.value != ''
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                'Department',
                                isEqualTo: controller.depart.value,
                              )
                              .where(
                                'Date',
                                isEqualTo: controller.formattedDate.value,
                              )
                              
                              .snapshots()
                        : controller.filter.value != '' &&
                              controller.formattedDate.value == ''
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                'Department',
                                isEqualTo: controller.depart.value,
                              )
                              .where(
                                'Outlet',
                                isEqualTo: controller.filter.value,
                              )
                              .where('Date', isEqualTo: todayDate)
                              
                              .snapshots()
                        : controller.filter.value != "" &&
                              controller.formattedDate.value != ""
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                'Outlet',
                                isEqualTo: controller.filter.value,
                              )
                              .where(
                                'Department',
                                isEqualTo: controller.depart.value,
                              )
                              .where(
                                'Date',
                                isEqualTo: controller.formattedDate.value,
                              )
                              
                              .snapshots()
                        : FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                'Department',
                                isEqualTo: controller.depart.value,
                              )
                              .where('Date', isEqualTo: todayDate)
                              
                              .snapshots()
                  : controller.depart.value == 'Food Court'
                  ? controller.filter.value == '' &&
                            controller.formattedDate.value == ''
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                "Ticket By",
                                isEqualTo: "Food Court Outlet",
                              )
                              .where('Date', isEqualTo: todayDate)
                              
                              .snapshots()
                        : controller.filter.value == '' &&
                              controller.formattedDate.value != ''
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                'Date',
                                isEqualTo: controller.formattedDate.value,
                              )
                              .where(
                                "Ticket By",
                                isEqualTo: "Food Court Outlet",
                              )
                              
                              .snapshots()
                        : controller.filter.value != '' &&
                              controller.formattedDate.value == ''
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                'Outlet',
                                isEqualTo: controller.filter.value,
                              )
                              .where(
                                "Ticket By",
                                isEqualTo: "Food Court Outlet",
                              )
                              .where('Date', isEqualTo: todayDate)
                              
                              .snapshots()
                        : controller.filter.value != "" &&
                              controller.formattedDate.value != ""
                        ? FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where(
                                'Outlet',
                                isEqualTo: controller.filter.value,
                              )
                              .where(
                                'Date',
                                isEqualTo: controller.formattedDate.value,
                              )
                              .where(
                                "Ticket By",
                                isEqualTo: "Food Court Outlet",
                              )
                              
                              .snapshots()
                        : FirebaseFirestore.instance
                              .collection('Tickets')
                              .where('Status', isEqualTo: 'Closed')
                              .where('Date', isEqualTo: todayDate)
                              
                              .snapshots()
                  : null;
            })(),
            builder: (context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
              return !asyncSnapshot.hasData
                  ? const Center(
                      child: CircularProgressIndicator(color: redColor),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: asyncSnapshot.data!.docs.length,
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10,
                      ),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        switch (asyncSnapshot.data!.docs[index]['header']) {
                          case 'Gate-Pass-Outwards(Retail Outlet)':
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => GateInwardDetails(
                                  ticketId: asyncSnapshot
                                      .data!
                                      .docs[index]['Ticket Number'],
                                ),
                              ),
                              child: ClosedTickets(
                                outletName:
                                    asyncSnapshot.data!.docs[index]['Outlet'],
                                head: 'Closed',
                                text: asyncSnapshot.data!.docs[index]['header'],
                                width: width,
                                height: height,
                                header: 'Quantity: ',
                                headerText:
                                    '${asyncSnapshot.data!.docs[index]['Quantity']} PC',
                              ),
                            );
                          case 'Gate-Pass-Inward(Retail Outlet)':
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => GateInwardDetails(
                                  ticketId: asyncSnapshot
                                      .data!
                                      .docs[index]['Ticket Number'],
                                ),
                              ),
                              child: ClosedTickets(
                                outletName:
                                    asyncSnapshot.data!.docs[index]['Outlet'],
                                head: 'Closed',
                                text: asyncSnapshot.data!.docs[index]['header'],
                                width: width,
                                height: height,
                                header: 'Quantity: ',
                                headerText:
                                    '${asyncSnapshot.data!.docs[index]['Quantity']} PC',
                              ),
                            );
                          case 'Non-Retail-Hour-Activity(Retail Outlet)':
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => NonRentalActivity(
                                  ticketId: asyncSnapshot
                                      .data!
                                      .docs[index]['Ticket Number'],
                                  // .docs[index]['Approval Time']
                                ),
                              ),
                              child: ClosedTickets(
                                outletName:
                                    asyncSnapshot.data!.docs[index]['Outlet'],
                                head: 'Closed',
                                text: asyncSnapshot.data!.docs[index]['header'],
                                width: width,
                                height: height,
                                header: 'Activity: ',
                                headerText:
                                    asyncSnapshot.data!.docs[index]['Activity'],
                              ),
                            );
                          case 'Security(Retail Outlet)':
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => SecurityTicektDetails(
                                  ticketId: asyncSnapshot
                                      .data!
                                      .docs[index]['Ticket Number'],
                                ),
                              ),
                              child: ClosedTickets(
                                outletName:
                                    asyncSnapshot.data!.docs[index]['Outlet'],
                                head: 'Closed',
                                text: asyncSnapshot.data!.docs[index]['header'],
                                width: width,
                                height: height,
                                header: 'Activity: ',
                                headerText:
                                    asyncSnapshot.data!.docs[index]['Activity'],
                              ),
                            );
                          case 'Maintainance(Retail Outlet)':
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => SecurityTicektDetails(
                                  ticketId: asyncSnapshot
                                      .data!
                                      .docs[index]['Ticket Number'],
                                ),
                              ),
                              child: ClosedTickets(
                                outletName:
                                    asyncSnapshot.data!.docs[index]['Outlet'],
                                head: 'Closed',
                                text: asyncSnapshot.data!.docs[index]['header'],
                                width: width,
                                height: height,
                                header: 'Activity: ',
                                headerText:
                                    asyncSnapshot.data!.docs[index]['Activity'],
                              ),
                            );
                          case 'Gate-Pass-Outwards(Food Court Outlet)':
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => GateInwardDetails(
                                  ticketId: asyncSnapshot
                                      .data!
                                      .docs[index]['Ticket Number'],
                                ),
                              ),
                              child: ClosedTickets(
                                outletName:
                                    asyncSnapshot.data!.docs[index]['Outlet'],
                                head: 'Closed',
                                text: asyncSnapshot.data!.docs[index]['header'],
                                width: width,
                                height: height,
                                header: 'Quantity: ',
                                headerText:
                                    '${asyncSnapshot.data!.docs[index]['Quantity']} PC',
                              ),
                            );
                          case 'Gate-Pass-Inward(Food Court Outlet)':
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => GateInwardDetails(
                                  ticketId: asyncSnapshot
                                      .data!
                                      .docs[index]['Ticket Number'],
                                ),
                              ),
                              child: ClosedTickets(
                                outletName:
                                    asyncSnapshot.data!.docs[index]['Outlet'],
                                head: 'Closed',
                                text: asyncSnapshot.data!.docs[index]['header'],
                                width: width,
                                height: height,
                                header: 'Quantity: ',
                                headerText:
                                    '${asyncSnapshot.data!.docs[index]['Quantity']} PC',
                              ),
                            );
                          case 'Non-Retail-Hour-Activity(Food Court Outlet)':
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => NonRentalActivity(
                                  ticketId: asyncSnapshot
                                      .data!
                                      .docs[index]['Ticket Number'],
                                ),
                              ),
                              child: ClosedTickets(
                                outletName:
                                    asyncSnapshot.data!.docs[index]['Outlet'],
                                head: 'Closed',
                                text: asyncSnapshot.data!.docs[index]['header'],
                                width: width,
                                height: height,
                                header: 'Activity: ',
                                headerText:
                                    asyncSnapshot.data!.docs[index]['Activity'],
                              ),
                            );
                          case 'Security(Food Court Outlet)':
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => SecurityTicektDetails(
                                  ticketId: asyncSnapshot
                                      .data!
                                      .docs[index]['Ticket Number'],
                                ),
                              ),
                              child: ClosedTickets(
                                outletName:
                                    asyncSnapshot.data!.docs[index]['Outlet'],
                                head: 'Closed',
                                text: asyncSnapshot.data!.docs[index]['header'],
                                width: width,
                                height: height,
                                header: 'Activity: ',
                                headerText:
                                    asyncSnapshot.data!.docs[index]['Activity'],
                              ),
                            );
                          case 'Maintainance(Food Court Outlet)':
                            return GestureDetector(
                              onTap: () => Get.to(
                                () => SecurityTicektDetails(
                                  ticketId: asyncSnapshot
                                      .data!
                                      .docs[index]['Ticket Number'],
                                ),
                              ),
                              child: ClosedTickets(
                                outletName:
                                    asyncSnapshot.data!.docs[index]['Outlet'],
                                head: 'Closed',
                                text: asyncSnapshot.data!.docs[index]['header'],
                                width: width,
                                height: height,
                                header: 'Activity: ',
                                headerText:
                                    asyncSnapshot.data!.docs[index]['Activity'],
                              ),
                            );
                        }

                        return const Center(
                          child: CircularProgressIndicator(color: redColor),
                        );
                      },
                    );
            },
          ),
        );
      },
    );
  }
}
