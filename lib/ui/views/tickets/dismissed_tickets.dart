import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// removed unused import 'package:intl/intl.dart'
import 'package:squareone_admin/ui/component/drawer_filter.dart';
import 'package:squareone_admin/ui/component/in_progress_tile.dart';
import 'package:squareone_admin/ui/views/tickets/tickets_controller.dart';

import '../../component/buttons.dart';
import '../../component/colors.dart';
import 'details/gate_pass_detail.dart';
import 'details/non_retail_activity.dart';
import 'details/security.dart';

class DismissedTicketsList extends StatefulWidget {
  const DismissedTicketsList({super.key});

  @override
  State<DismissedTicketsList> createState() => _DismissedTicketsListState();
}

class _DismissedTicketsListState extends State<DismissedTicketsList> {
  final TicketController controller = Get.put(TicketController());

  final int pageSize = 10;

  DocumentSnapshot? _lastDocument;
  int _currentPage = 1;

  Stream<QuerySnapshot> _getPageStream() {
    Query<Object>? query = controller.depart.value == 'Operations' ||
            controller.depart.value == 'Admin' ||
            controller.depart.value == 'Security' ||
            controller.depart.value == 'CR'
        ? controller.filter.value == '' && controller.formattedDate.value == ''
            ? FirebaseFirestore.instance
                .collection('Tickets')
                .limit(10)
                .where('Status', isEqualTo: 'Dissmissed')
            : controller.filter.value == '' &&
                    controller.formattedDate.value != ''
                ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Dissmissed')
                    .where('Date', isEqualTo: controller.formattedDate.value)
                : controller.filter.value != '' &&
                        controller.formattedDate.value == ''
                    ? FirebaseFirestore.instance
                        .collection('Tickets')
                        .limit(10)
                        .where('Status', isEqualTo: 'Dissmissed')
                        .where('Outlet', isEqualTo: controller.filter.value)
                    : controller.filter.value != "" &&
                            controller.formattedDate.value != ""
                        ? FirebaseFirestore.instance
                            .collection('Tickets')
                            .limit(10)
                            .where('Status', isEqualTo: 'Dissmissed')
                            .where('Outlet', isEqualTo: controller.filter.value)
                            .where('Date',
                                isEqualTo: controller.formattedDate.value)
                        : FirebaseFirestore.instance
                            .collection('Tickets')
                            .limit(10)
                            .where('Status', isEqualTo: 'Dissmissed')
        : controller.depart.value == 'Marketing' ||
                controller.depart.value == 'Maintainance'
            ? controller.filter.value == '' &&
                    controller.formattedDate.value == ''
                ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .limit(10)
                    .where('Status', isEqualTo: 'Dissmissed')
                    .where('Department', isEqualTo: controller.depart.value)
                : controller.filter.value == '' && controller.formattedDate.value != ''
                    ? FirebaseFirestore.instance.collection('Tickets').limit(10).where('Status', isEqualTo: 'Dissmissed').where('Department', isEqualTo: controller.depart.value).where('Date', isEqualTo: controller.formattedDate.value)
                    : controller.filter.value != '' && controller.formattedDate.value == ''
                        ? FirebaseFirestore.instance.collection('Tickets').limit(10).where('Status', isEqualTo: 'Dissmissed').where('Department', isEqualTo: controller.depart.value).where('Outlet', isEqualTo: controller.filter.value)
                        : controller.filter.value != "" && controller.formattedDate.value != ""
                            ? FirebaseFirestore.instance.collection('Tickets').limit(10).where('Status', isEqualTo: 'Dissmissed').where('Outlet', isEqualTo: controller.filter.value).where('Department', isEqualTo: controller.depart.value).where('Date', isEqualTo: controller.formattedDate.value)
                            : FirebaseFirestore.instance.collection('Tickets').limit(10).where('Status', isEqualTo: 'Dissmissed').where('Department', isEqualTo: controller.depart.value)
            : controller.depart.value == 'Food Court'
                ? controller.filter.value == '' && controller.formattedDate.value == ''
                    ? FirebaseFirestore.instance.collection('Tickets').limit(10).where('Status', isEqualTo: 'Dissmissed').where("Ticket By", isEqualTo: "Food Court Outlet")
                    : controller.filter.value == '' && controller.formattedDate.value != ''
                        ? FirebaseFirestore.instance.collection('Tickets').limit(10).where('Status', isEqualTo: 'Dissmissed').where('Date', isEqualTo: controller.formattedDate.value).where("Ticket By", isEqualTo: "Food Court Outlet")
                        : controller.filter.value != '' && controller.formattedDate.value == ''
                            ? FirebaseFirestore.instance.collection('Tickets').limit(10).where('Status', isEqualTo: 'Dissmissed').where('Outlet', isEqualTo: controller.filter.value).where("Ticket By", isEqualTo: "Food Court Outlet")
                            : controller.filter.value != "" && controller.formattedDate.value != ""
                                ? FirebaseFirestore.instance.collection('Tickets').limit(10).where('Status', isEqualTo: 'Dissmissed').where('Outlet', isEqualTo: controller.filter.value).where('Date', isEqualTo: controller.formattedDate.value).where("Ticket By", isEqualTo: "Food Court Outlet")
                                : FirebaseFirestore.instance.collection('Tickets').limit(10).where('Status', isEqualTo: 'Dissmissed')
                : FirebaseFirestore.instance.collection('Tickets').limit(10).where('Status', isEqualTo: 'Dissmissed');

    if (_lastDocument != null && 10 > 1) {
      query = query.startAfterDocument(_lastDocument!);
    }

    return query.snapshots();
  }

  void moveToNextPage() async {
    final currentPageStream = await _getPageStream().first;

    if (currentPageStream.docs.isNotEmpty) {
      _lastDocument = currentPageStream.docs.last;
      setState(() {
        _currentPage++;
      });
    }
  }

  void moveToPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _lastDocument = null;
      });
    }
  }

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
                leading: ButtonBack(
                  height: height,
                  width: width,
                ),
                title: Text(
                  controller.filter.value == '' &&
                          controller.formattedDate.value == ''
                      ? "Dismissed Tickets"
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
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                          stream: _getPageStream(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
                            if (!asyncSnapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: redColor,
                                ),
                              );
                            }
                            return ListView(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              children: [
                                ...List.generate(
                                  asyncSnapshot.data!.docs.length,
                                  (index) {
                                    switch (asyncSnapshot.data!.docs[index]
                                        ['header']) {
                                      case 'Gate-Pass-Outwards(Retail Outlet)':
                                        return GestureDetector(
                                          onTap: () =>
                                              Get.to(() => GateInwardDetails(
                                                    ticketId: asyncSnapshot
                                                            .data!.docs[index]
                                                        ['Ticket Number'],
                                                  )),
                                          child: ClosedTickets(
                                            outletName: asyncSnapshot
                                                .data!.docs[index]['Outlet'],
                                            head: 'Dismissed',
                                            text: asyncSnapshot
                                                .data!.docs[index]['header'],
                                            width: width,
                                            height: height,
                                            header: 'Quantity: ',
                                            headerText:
                                                '${asyncSnapshot.data!.docs[index]['Quantity']} PC',
                                          ),
                                        );
                                      case 'Gate-Pass-Inward(Retail Outlet)':
                                        return GestureDetector(
                                          onTap: () =>
                                              Get.to(() => GateInwardDetails(
                                                    ticketId: asyncSnapshot
                                                            .data!.docs[index]
                                                        ['Ticket Number'],
                                                  )),
                                          child: ClosedTickets(
                                            outletName: asyncSnapshot
                                                .data!.docs[index]['Outlet'],
                                            head: 'Dismissed',
                                            text: asyncSnapshot
                                                .data!.docs[index]['header'],
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
                                                            .data!.docs[index]
                                                        ['Ticket Number'],
                                                  ),
                                                ),
                                            child: ClosedTickets(
                                              outletName: asyncSnapshot
                                                  .data!.docs[index]['Outlet'],
                                              head: 'Dismissed',
                                              text: asyncSnapshot
                                                  .data!.docs[index]['header'],
                                              width: width,
                                              height: height,
                                              header: 'Activity: ',
                                              headerText: asyncSnapshot.data!
                                                  .docs[index]['Activity'],
                                            ));
                                      case 'Security(Retail Outlet)':
                                        return GestureDetector(
                                          onTap: () => Get.to(
                                              () => SecurityTicektDetails(
                                                    ticketId: asyncSnapshot
                                                            .data!.docs[index]
                                                        ['Ticket Number'],
                                                  )),
                                          child: ClosedTickets(
                                              outletName: asyncSnapshot
                                                  .data!.docs[index]['Outlet'],
                                              head: 'Dismissed',
                                              text: asyncSnapshot
                                                  .data!.docs[index]['header'],
                                              width: width,
                                              height: height,
                                              header: 'Activity: ',
                                              headerText: asyncSnapshot.data!
                                                  .docs[index]['Activity']),
                                        );
                                      case 'Maintainance(Retail Outlet)':
                                        return GestureDetector(
                                          onTap: () => Get.to(
                                              () => SecurityTicektDetails(
                                                    ticketId: asyncSnapshot
                                                            .data!.docs[index]
                                                        ['Ticket Number'],
                                                  )),
                                          child: ClosedTickets(
                                              outletName: asyncSnapshot
                                                  .data!.docs[index]['Outlet'],
                                              head: 'Dismissed',
                                              text: asyncSnapshot
                                                  .data!.docs[index]['header'],
                                              width: width,
                                              height: height,
                                              header: 'Activity: ',
                                              headerText: asyncSnapshot.data!
                                                  .docs[index]['Activity']),
                                        );
                                      case 'Gate-Pass-Outwards(Food Court Outlet)':
                                        return GestureDetector(
                                          onTap: () =>
                                              Get.to(() => GateInwardDetails(
                                                    ticketId: asyncSnapshot
                                                            .data!.docs[index]
                                                        ['Ticket Number'],
                                                  )),
                                          child: ClosedTickets(
                                            outletName: asyncSnapshot
                                                .data!.docs[index]['Outlet'],
                                            head: 'Dismissed',
                                            text: asyncSnapshot
                                                .data!.docs[index]['header'],
                                            width: width,
                                            height: height,
                                            header: 'Quantity: ',
                                            headerText:
                                                '${asyncSnapshot.data!.docs[index]['Quantity']} PC',
                                          ),
                                        );
                                      case 'Gate-Pass-Inward(Food Court Outlet)':
                                        return GestureDetector(
                                          onTap: () =>
                                              Get.to(() => GateInwardDetails(
                                                    ticketId: asyncSnapshot
                                                            .data!.docs[index]
                                                        ['Ticket Number'],
                                                  )),
                                          child: ClosedTickets(
                                            outletName: asyncSnapshot
                                                .data!.docs[index]['Outlet'],
                                            head: 'Dismissed',
                                            text: asyncSnapshot
                                                .data!.docs[index]['header'],
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
                                                            .data!.docs[index]
                                                        ['Ticket Number'],
                                                  ),
                                                ),
                                            child: ClosedTickets(
                                              outletName: asyncSnapshot
                                                  .data!.docs[index]['Outlet'],
                                              head: 'Dismissed',
                                              text: asyncSnapshot
                                                  .data!.docs[index]['header'],
                                              width: width,
                                              height: height,
                                              header: 'Activity: ',
                                              headerText: asyncSnapshot.data!
                                                  .docs[index]['Activity'],
                                            ));
                                      case 'Security(Food Court Outlet)':
                                        return GestureDetector(
                                          onTap: () => Get.to(
                                              () => SecurityTicektDetails(
                                                    ticketId: asyncSnapshot
                                                            .data!.docs[index]
                                                        ['Ticket Number'],
                                                  )),
                                          child: ClosedTickets(
                                              outletName: asyncSnapshot
                                                  .data!.docs[index]['Outlet'],
                                              head: 'Dismissed',
                                              text: asyncSnapshot
                                                  .data!.docs[index]['header'],
                                              width: width,
                                              height: height,
                                              header: 'Activity: ',
                                              headerText: asyncSnapshot.data!
                                                  .docs[index]['Activity']),
                                        );
                                      case 'Maintainance(Food Court Outlet)':
                                        return GestureDetector(
                                          onTap: () => Get.to(
                                              () => SecurityTicektDetails(
                                                    ticketId: asyncSnapshot
                                                            .data!.docs[index]
                                                        ['Ticket Number'],
                                                  )),
                                          child: ClosedTickets(
                                              outletName: asyncSnapshot
                                                  .data!.docs[index]['Outlet'],
                                              head: 'Dismissed',
                                              text: asyncSnapshot
                                                  .data!.docs[index]['header'],
                                              width: width,
                                              height: height,
                                              header: 'Activity: ',
                                              headerText: asyncSnapshot.data!
                                                  .docs[index]['Activity']),
                                        );
                                      default:
                                        return const SizedBox();
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: moveToPreviousPage,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Previous Page',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: moveToNextPage,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Next Page',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // GestureDetector(
                                      //   onTap: moveToPreviousPage,
                                      //   child: Container(
                                      //     margin: const EdgeInsets.only(left: 10),
                                      //     child: Text(
                                      //       'Previous',
                                      //       style: const TextStyle(
                                      //         color: Colors.black,
                                      //         fontWeight: FontWeight.w500,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   width: 10,
                                      // ),
                                      // GestureDetector(
                                      //   onTap: moveToNextPage,
                                      //   child: Container(
                                      //     margin: const EdgeInsets.only(left: 10),
                                      //     child: Text(
                                      //       'Next',
                                      //       style: const TextStyle(
                                      //         color: Colors.black,
                                      //         fontWeight: FontWeight.w500,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ));
        });
  }
}
