import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/ui/component/buttons.dart';
import 'package:squareone_admin/ui/component/text_feilds.dart';
import 'package:squareone_admin/ui/views/outlets/carton_report_controller.dart';

class CartonReport extends StatefulWidget {
  final String outletName;
  const CartonReport({super.key, required this.outletName});

  @override
  State<CartonReport> createState() => _CartonReportState();
}

class _CartonReportState extends State<CartonReport> {
  final TextEditingController _inwardFromDateController =
      TextEditingController();
  final TextEditingController _inwardToDateController = TextEditingController();
  final TextEditingController _outwardFromDateController =
      TextEditingController();
  final TextEditingController _outwardToDateController =
      TextEditingController();

  @override
  void dispose() {
    _inwardFromDateController.dispose();
    _inwardToDateController.dispose();
    _outwardFromDateController.dispose();
    _outwardToDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Widget _buildDateSelectors(
      TextEditingController fromController,
      TextEditingController toController,
      VoidCallback onSubmit,
      BuildContext context,
      CartonReportController controller) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.04),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _selectDate(context, fromController),
            child: AbsorbPointer(
              child: textField(
                'From Date',
                fromController,
                height: 80,
                left: 16,
                right: 16,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _selectDate(context, toController),
            child: AbsorbPointer(
              child: textField(
                'To Date',
                toController,
                height: 80,
                left: 16,
                right: 16,
              ),
            ),
          ),
          const SizedBox(height: 50),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB71C1C),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ))
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: Color(0xFFB71C1C)),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text('cartons'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return GetBuilder<CartonReportController>(
      init: Get.put<CartonReportController>(
        CartonReportController(),
      ),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: ButtonBack(height: height, width: width),
            title: const Text(
              'Carton Report',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: const [
                      Tab(text: 'Gate-Pass-Inward'),
                      Tab(text: 'Gate-Pass-Outward'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            _buildDateSelectors(_inwardFromDateController,
                                _inwardToDateController, () {
                              if (_inwardFromDateController.text.isNotEmpty &&
                                  _inwardToDateController.text.isNotEmpty) {
                                controller.inwardCartonCount = 0;
                                controller.fetchInwardReport(
                                  _inwardFromDateController.text,
                                  _inwardToDateController.text,
                                  widget.outletName,
                                );
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Please select both dates',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            }, context, controller),
                            const SizedBox(height: 16),
                            Obx(() => controller.isLoading.value
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : controller.inwardCartonCount > 0
                                    ? _buildResultCard('Total Inward Cartons',
                                        controller.inwardCartonCount)
                                    : controller.inwardCartonCount == 0 &&
                                            _inwardFromDateController
                                                .text.isNotEmpty
                                        ? const Center(
                                            child: Text(
                                                'No cartons found for the selected date range'))
                                        : const SizedBox.shrink()),
                            Obx(() => Column(
                                  children: List.generate(
                                    controller.inwardReport.length,
                                    (index) {
                                      final report =
                                          controller.inwardReport[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: ListTile(
                                          title: Text(
                                              'Approved By ${report['Approved By']}'),
                                          subtitle: Text(
                                              'Date: ${controller.formatTimestamp(report['Approval Time'])}'),
                                          trailing: Text(
                                              'Cartons: ${report['Quantity'] ?? '0'}'),
                                          leading: const Icon(
                                              Icons.inventory_2_outlined,
                                              color: Color(0xFFB71C1C)),
                                        ),
                                      );
                                    },
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            _buildDateSelectors(_outwardFromDateController,
                                _outwardToDateController, () {
                              if (_outwardFromDateController.text.isNotEmpty &&
                                  _outwardToDateController.text.isNotEmpty) {
                                controller.outwardCartonCount = 0;
                                controller.fetchOutwardReport(
                                  _outwardFromDateController.text,
                                  _outwardToDateController.text,
                                  widget.outletName,
                                );
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Please select both dates',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            }, context, controller),
                            const SizedBox(height: 16),
                            Obx(() => controller.isLoading.value
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : controller.outwardCartonCount > 0
                                    ? _buildResultCard('Total Outward Cartons',
                                        controller.outwardCartonCount)
                                    : controller.outwardCartonCount == 0 &&
                                            _outwardFromDateController
                                                .text.isNotEmpty
                                        ? const Center(
                                            child: Text(
                                                'No cartons found for the selected date range'))
                                        : const SizedBox.shrink()),
                            Obx(
                              () => Column(
                                children: List.generate(
                                  controller.outwardReport.length,
                                  (index) {
                                    final report =
                                        controller.outwardReport[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: ListTile(
                                        title: Text(
                                            'Approved By ${report['Approved By']}'),
                                        subtitle: Text(
                                            'Approval Date: ${controller.formatTimestamp(report['Approval Time'])}'),
                                        trailing: Text(
                                            'Cartons: ${report['Quantity'] ?? '0'}'),
                                        leading: const Icon(
                                            Icons.inventory_2_outlined,
                                            color: Color(0xFFB71C1C)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
