import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:squareone_admin/ui/views/forms/shift_management/shift_controller.dart';
import 'package:squareone_admin/ui/views/home/head/user_controller.dart';

/// Controller for managing shift creation and editing
class ShiftManagementController extends GetxController {
  final UserController userController = Get.find<UserController>();
  final ShiftController shiftController = Get.find<ShiftController>();

  final RxBool isLoading = false.obs;
  final RxString selectedUserId = ''.obs;
  final RxString selectedDate = ''.obs;
  final RxString selectedStartTime = ''.obs;
  final RxString selectedEndTime = ''.obs;
  final RxString selectedTimezone = 'Asia/Karachi'.obs;

  Future<void> createShift() async {
    if (selectedUserId.isEmpty ||
        selectedDate.isEmpty ||
        selectedStartTime.isEmpty ||
        selectedEndTime.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all shift fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      return;
    }

    isLoading.value = true;
    try {
      final DateTime parsedDate = DateTime.parse(selectedDate.value);
      await shiftController.createShift(
        userId: selectedUserId.value,
        date: parsedDate,
        startTime: selectedStartTime.value,
        endTime: selectedEndTime.value,
        timezone: selectedTimezone.value,
      );

      Get.snackbar(
        'Success',
        'Shift created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );

      _clearFields();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create shift: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearFields() {
    selectedUserId.value = '';
    selectedDate.value = '';
    selectedStartTime.value = '';
    selectedEndTime.value = '';
  }
}

/// A view to manage user shifts
class ShiftManagementView extends StatelessWidget {
  const ShiftManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Shifts'),
        elevation: 0,
      ),
      body: GetBuilder<ShiftManagementController>(
        init: ShiftManagementController(),
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Selection
                _buildSectionTitle('Select User'),
                const SizedBox(height: 8),
                Obx(
                  () => DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select an employee'),
                    value: controller.selectedUserId.isEmpty
                        ? null
                        : controller.selectedUserId.value,
                    items: controller.userController.employees
                        .map(
                          (user) => DropdownMenuItem<String>(
                            value: user.id,
                            child: Text(user.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedUserId.value = value;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Date Selection
                _buildSectionTitle('Select Shift Date'),
                const SizedBox(height: 8),
                Obx(
                  () => GestureDetector(
                    onTap: () => _pickDate(context, controller),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.selectedDate.isEmpty
                                ? 'Pick date'
                                : controller.selectedDate.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: controller.selectedDate.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Start Time
                _buildSectionTitle('Shift Start Time'),
                const SizedBox(height: 8),
                Obx(
                  () => GestureDetector(
                    onTap: () =>
                        _pickTime(context, controller, isStartTime: true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.selectedStartTime.isEmpty
                                ? 'Pick start time'
                                : controller.selectedStartTime.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: controller.selectedStartTime.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          const Icon(Icons.access_time, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // End Time
                _buildSectionTitle('Shift End Time'),
                const SizedBox(height: 8),
                Obx(
                  () => GestureDetector(
                    onTap: () =>
                        _pickTime(context, controller, isStartTime: false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.selectedEndTime.isEmpty
                                ? 'Pick end time'
                                : controller.selectedEndTime.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: controller.selectedEndTime.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          const Icon(Icons.access_time, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Timezone Selection
                _buildSectionTitle('Timezone'),
                const SizedBox(height: 8),
                Obx(
                  () => DropdownButton<String>(
                    isExpanded: true,
                    value: controller.selectedTimezone.value,
                    items: [
                      'Asia/Karachi',
                      'UTC',
                      'America/New_York',
                      'Europe/London',
                      'Asia/Dubai',
                    ]
                        .map((tz) => DropdownMenuItem<String>(
                              value: tz,
                              child: Text(tz),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedTimezone.value = value;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.createShift(),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text('Create Shift'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _pickDate(BuildContext context, ShiftManagementController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      controller.selectedDate.value =
          DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _pickTime(BuildContext context, ShiftManagementController controller,
      {required bool isStartTime}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: isStartTime ? 9 : 17,
        minute: 0,
      ),
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isStartTime) {
        controller.selectedStartTime.value = timeString;
      } else {
        controller.selectedEndTime.value = timeString;
      }
    }
  }
}
