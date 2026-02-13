import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/colors.dart';
import 'package:squareone_admin/ui/component/details_function.dart';

class HeadTicketDetail extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const HeadTicketDetail({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final String title = ticket['title'] ?? 'No Title';
    final String id = ticket['id'] ?? 'No Title';
    final String description = ticket['description'] ?? 'No description provided';
    final String department = ticket['department'] ?? 'Not Found';
    final String status = ticket['status'] ?? 'Unknown';
    final String employeeName = ticket['assignedTo'] ?? 'Unassigned';
    final String employeeRole = ticket['assignedToRole'] ?? 'Unassigned';
    final String assignBy = ticket['assignedBy'] ?? 'Unassigned';
    final String assignByRole = ticket['assignedByRole'] ?? 'Role';
    final String dueDate = ticket['dueDate'] ?? 'No due date';
    final String priority = ticket['priority'] ?? 'Normal';
    final String assignedAt = ticket['assignedAt'] ?? 'N/A';

    // Status color logic (same as your GateInwardDetails)
    Color statusColor = _getStatusColor(status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: ButtonBack(height: height, width: width),
        title: const Text(
          'Ticket Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Card(
                elevation: 8,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔹 Title + Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(),

                      /// 🔹 Assignment Info
                      _sectionTitle('Assignment'),
                      _detailRow('Assigned To', employeeName + ' (${employeeRole})'),
                          _detailRow('Assigned By', assignBy + ' (${assignByRole})' ?? 'N/A'),


                      _detailRow('Assigned At', assignedAt),

                      const SizedBox(height: 12),
                      const Divider(),

                      /// 🔹 Task Info
                      _sectionTitle('Task Details'),
                      _detailRow('Priority', priority),
                      // _detailRow('id', id),
                      _detailRow('Due Date', dueDate),
                      _detailRow('Description', description),
                      _detailRow(
                        'Completed At',
                        ticket['completion']?['completed_at'] ?? 'Not completed',
                      ),

                      const SizedBox(height: 12),
                      const Divider(),

                      /// 🔹 Attachments & Remarks
                      _sectionTitle('Additional'),
                      _detailRow(
                        'Images',
                        ticket['images'] != null && ticket['images'].isNotEmpty
                            ? '${ticket['images'].length} image(s)'
                            : 'No images',
                      ),
                      _detailRow(
                        'Remarks',
                        ticket['remarks'] ?? 'No remarks',
                        multiLine: true,
                      ),

                      const SizedBox(height: 12),
                      const Divider(),

                      /// 🔹 Department
                      _sectionTitle('Department'),
                      _detailRow(
                        'Department',
                        department,
                      ),
                      _detailRow(
                        'Subtickets',
                        ticket['subtickets'] != null && ticket['subtickets'].isNotEmpty
                            ? '${ticket['subtickets'].length} subticket(s)'
                            : 'No subtickets',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// 🔹 Bottom Action Buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: LoginButton(
                    width: width,
                    height: height,
                    text: 'Approve',
                    color:  Color(0xFF054153),
                    function: () {
                      Get.snackbar('Success', 'Ticket approved');
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LoginButton(
                    width: width,
                    height: height,
                    text: 'Reject',
                    color: redColor,
                    function: () {
                      Get.snackbar('Rejected', 'Ticket rejected');
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _detailRow(String head, String value, {bool multiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment:
        multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              head,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String head, String text, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$head: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isMultiLine ? Colors.black54 : Colors.black87,
                height: isMultiLine ? 1.4 : 1,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'assigned':
        return Color(0xFFFE860D);
      case 'in progress':
        return Colors.blue;
      case 'approved':
      case 'urgent approved':
      case 'completed':
        return const Color(0xFF12CA37);
      case 'dismissed':
        return const Color.fromARGB(255, 41, 96, 179);
      default:
        return Colors.grey;
    }
  }
}