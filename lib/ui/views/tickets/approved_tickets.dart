import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:squareone_admin/ui/component/in_progress_tile.dart';
import 'package:squareone_admin/ui/views/tickets/details/security.dart';
import 'package:squareone_admin/ui/views/tickets/tickets_controller.dart';
import '../../component/buttons.dart';
import '../../component/colors.dart';
import '../../component/drawer_filter.dart';
import 'details/gate_pass_detail.dart';
import 'details/non_retail_activity.dart';

class ApproveTicketList extends StatefulWidget {
  const ApproveTicketList({super.key});

  @override
  _ApproveTicketListState createState() => _ApproveTicketListState();
}

class _ApproveTicketListState extends State<ApproveTicketList> {
  final TicketController controller = Get.put(TicketController());

  final int pageSize = 10;

  DocumentSnapshot? _lastDocument;
  int _currentPage = 1;

  Stream<QuerySnapshot> _getPageStream() {
    // Get today's date in the format dd-MM-yyyy
    String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    Query<Object>? query =
        controller.depart.value == 'Operations' ||
            controller.depart.value == 'Admin' ||
            controller.depart.value == 'Security' ||
            controller.depart.value == 'CR'
        ? controller.filter.value == '' && controller.formattedDate.value == ''
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Date', isEqualTo: todayDate)
                    .limit(10)
              : controller.filter.value == '' &&
                    controller.formattedDate.value != ''
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Date', isEqualTo: controller.formattedDate.value)
                    .limit(10)
              : controller.filter.value != '' &&
                    controller.formattedDate.value == ''
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Outlet', isEqualTo: controller.filter.value)
                    .where('Date', isEqualTo: todayDate)
                    .limit(10)
              : controller.filter.value != "" &&
                    controller.formattedDate.value != ""
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Outlet', isEqualTo: controller.filter.value)
                    .where('Date', isEqualTo: controller.formattedDate.value)
                    .limit(10)
              : FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Date', isEqualTo: todayDate)
                    .limit(10)
        : controller.depart.value == 'Marketing' ||
              controller.depart.value == 'Maintainance'
        ? controller.filter.value == '' && controller.formattedDate.value == ''
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Department', isEqualTo: controller.depart.value)
                    .where('Date', isEqualTo: todayDate)
                    .limit(10)
              : controller.filter.value == '' &&
                    controller.formattedDate.value != ''
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Department', isEqualTo: controller.depart.value)
                    .where('Date', isEqualTo: controller.formattedDate.value)
                    .limit(10)
              : controller.filter.value != '' &&
                    controller.formattedDate.value == ''
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Department', isEqualTo: controller.depart.value)
                    .where('Outlet', isEqualTo: controller.filter.value)
                    .where('Date', isEqualTo: todayDate)
                    .limit(10)
              : controller.filter.value != "" &&
                    controller.formattedDate.value != ""
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Outlet', isEqualTo: controller.filter.value)
                    .where('Department', isEqualTo: controller.depart.value)
                    .where('Date', isEqualTo: controller.formattedDate.value)
                    .limit(10)
              : FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Department', isEqualTo: controller.depart.value)
                    .where('Date', isEqualTo: todayDate)
                    .limit(10)
        : controller.depart.value == 'Food Court'
        ? controller.filter.value == '' && controller.formattedDate.value == ''
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where("Ticket By", isEqualTo: "Food Court Outlet")
                    .where('Date', isEqualTo: todayDate)
                    .limit(10)
              : controller.filter.value == '' &&
                    controller.formattedDate.value != ''
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Date', isEqualTo: controller.formattedDate.value)
                    .where("Ticket By", isEqualTo: "Food Court Outlet")
                    .limit(10)
              : controller.filter.value != '' &&
                    controller.formattedDate.value == ''
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Outlet', isEqualTo: controller.filter.value)
                    .where("Ticket By", isEqualTo: "Food Court Outlet")
                    .where('Date', isEqualTo: todayDate)
                    .limit(10)
              : controller.filter.value != "" &&
                    controller.formattedDate.value != ""
              ? FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Outlet', isEqualTo: controller.filter.value)
                    .where('Date', isEqualTo: controller.formattedDate.value)
                    .where("Ticket By", isEqualTo: "Food Court Outlet")
                    .limit(10)
              : FirebaseFirestore.instance
                    .collection('Tickets')
                    .where('Status', isEqualTo: 'Approved')
                    .where('Date', isEqualTo: todayDate)
                    .limit(10)
        : FirebaseFirestore.instance
              .collection('Tickets')
              .where('Status', isEqualTo: 'Approved')
              .where('Date', isEqualTo: todayDate)
              .limit(10);

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
      init: controller,
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
                  ? "Approved Tickets"
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
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getPageStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: redColor),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No data available'));
                      }
                      final data = snapshot.data!.docs;
                      return ListView(
                        children: [
                          ...List.generate(data.length, (index) {
                            final ticket =
                                data[index].data() as Map<String, dynamic>;
                            switch (ticket['header']) {
                              case 'Gate-Pass-Outwards(Retail Outlet)':
                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => GateInwardDetails(
                                      ticketId: ticket['Ticket Number'],
                                    ),
                                  ),
                                  child: ClosedTickets(
                                    outletName: ticket['Outlet'],
                                    head: 'Approved',
                                    text: ticket['header'],
                                    width: width,
                                    height: height,
                                    header: 'Quantity: ',
                                    headerText: '${ticket['Quantity']} PC',
                                  ),
                                );
                              case 'Gate-Pass-Inward(Retail Outlet)':
                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => GateInwardDetails(
                                      ticketId: ticket['Ticket Number'],
                                    ),
                                  ),
                                  child: ClosedTickets(
                                    outletName: ticket['Outlet'],
                                    head: 'Approved',
                                    text: ticket['header'],
                                    width: width,
                                    height: height,
                                    header: 'Quantity: ',
                                    headerText: '${ticket['Quantity']} PC',
                                  ),
                                );
                              case 'Non-Retail-Hour-Activity(Retail Outlet)':
                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => NonRentalActivity(
                                      ticketId: ticket['Ticket Number'],
                                    ),
                                  ),
                                  child: ClosedTickets(
                                    outletName: ticket['Outlet'],
                                    head: 'Approved',
                                    text: ticket['header'],
                                    width: width,
                                    height: height,
                                    header: 'Activity: ',
                                    headerText: ticket['Activity'],
                                  ),
                                );
                              case 'Non-Retail-Hour-Activity(Food Court Outlet)':
                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => NonRentalActivity(
                                      ticketId: ticket['Ticket Number'],
                                    ),
                                  ),
                                  child: ClosedTickets(
                                    outletName: ticket['Outlet'],
                                    head: 'Approved',
                                    text: ticket['header'],
                                    width: width,
                                    height: height,
                                    header: 'Activity: ',
                                    headerText: ticket['Activity'],
                                  ),
                                );
                              case 'Gate-Pass-Outwards(Food Court Outlet)':
                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => GateInwardDetails(
                                      ticketId: ticket['Ticket Number'],
                                    ),
                                  ),
                                  child: ClosedTickets(
                                    outletName: ticket['Outlet'],
                                    head: 'Approved',
                                    text: ticket['header'],
                                    width: width,
                                    height: height,
                                    header: 'Quantity: ',
                                    headerText: '${ticket['Quantity']} PC',
                                  ),
                                );
                              case 'Gate-Pass-Inward(Food Court Outlet)':
                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => GateInwardDetails(
                                      ticketId: ticket['Ticket Number'],
                                    ),
                                  ),
                                  child: ClosedTickets(
                                    outletName: ticket['Outlet'],
                                    head: 'Approved',
                                    text: ticket['header'],
                                    width: width,
                                    height: height,
                                    header: 'Quantity: ',
                                    headerText: '${ticket['Quantity']} PC',
                                  ),
                                );
                              case 'Maintainance(Retail Outlet)':
                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => SecurityTicektDetails(
                                      ticketId: ticket['Ticket Number'],
                                    ),
                                  ),
                                  child: ClosedTickets(
                                    outletName: ticket['Outlet'],
                                    head: 'Approved',
                                    text: ticket['header'],
                                    width: width,
                                    height: height,
                                    header: 'Quantity: ',
                                    headerText: ticket['Activity'],
                                  ),
                                );
                              case 'Maintainance(Food Court Outlet)':
                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => SecurityTicektDetails(
                                      ticketId: ticket['Ticket Number'],
                                    ),
                                  ),
                                  child: ClosedTickets(
                                    outletName: ticket['Outlet'],
                                    head: 'Approved',
                                    text: ticket['header'],
                                    width: width,
                                    height: height,
                                    header: 'Quantity: ',
                                    headerText: ticket['Activity'],
                                  ),
                                );
                              default:
                                return SizedBox();
                            }
                          }),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: moveToPreviousPage,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
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
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: moveToNextPage,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
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
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
