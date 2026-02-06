import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squareone_admin/controllers/user_controller.dart';
import 'package:squareone_admin/ui/views/forms/shift_management/shift_controller.dart';
import 'package:squareone_admin/helpers/availability_helper.dart';

/// Example widget showing how to display employees with availability status
class EmployeeListWithAvailability extends StatelessWidget {
  const EmployeeListWithAvailability({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final shiftController = Get.find<ShiftController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees Status'),
        backgroundColor: const Color(0xFFB71C1C),
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userController.employees.isEmpty) {
          return const Center(
            child: Text('No employees found'),
          );
        }

        return ListView.builder(
          itemCount: userController.employees.length,
          itemBuilder: (context, index) {
            final employee = userController.employees[index];
            final status = shiftController.getUserAvailabilityStatus(employee.id);
            final isOnline = status == 'Online';

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isOnline ? Colors.green : Colors.red,
                  child: Text(
                    employee.name.characters.first.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(employee.name),
                subtitle: Text(employee.email),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isOnline ? Colors.green[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isOnline ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to employee details
                },
              ),
            );
          },
        );
      }),
    );
  }
}

/// Example widget showing how to create a new shift
class CreateShiftDialog extends StatefulWidget {
  final String userId;
  final String userName;

  const CreateShiftDialog({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<CreateShiftDialog> createState() => _CreateShiftDialogState();
}

class _CreateShiftDialogState extends State<CreateShiftDialog> {
  late DateTime selectedDate;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  String selectedTimezone = 'Asia/Karachi';
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    startTime = const TimeOfDay(hour: 9, minute: 0);
    endTime = const TimeOfDay(hour: 17, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    final shiftController = Get.find<ShiftController>();

    return AlertDialog(
      title: Text('Create Shift for ${widget.userName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Picker
            ListTile(
              title: const Text('Date'),
              subtitle: Text(
                '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),
            const Divider(),

            // Start Time Picker
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(startTime.format(context)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: startTime,
                );
                if (picked != null) {
                  setState(() => startTime = picked);
                }
              },
            ),
            const Divider(),

            // End Time Picker
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(endTime.format(context)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: endTime,
                );
                if (picked != null) {
                  setState(() => endTime = picked);
                }
              },
            ),
            const Divider(),

            // Timezone Dropdown
            DropdownButton<String>(
              value: selectedTimezone,
              isExpanded: true,
              items: [
                'Asia/Karachi',
                'Asia/Dubai',
                'UTC',
                'America/New_York',
                'America/Los_Angeles',
                'Europe/London',
              ]
                  .map((tz) => DropdownMenuItem(
                        value: tz,
                        child: Text(tz),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedTimezone = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Notes TextField
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter shift notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await shiftController.createShift(
              userId: widget.userId,
              date: selectedDate,
              startTime:
                  '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
              endTime:
                  '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
              timezone: selectedTimezone,
              notes: notesController.text.isNotEmpty ? notesController.text : null,
            );

            if (success) {
              Get.back();
              Get.snackbar(
                'Success',
                'Shift created successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            } else {
              Get.snackbar(
                'Error',
                shiftController.errorMessage.value,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
          ),
          child: const Text(
            'Create Shift',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}

/// Example widget showing user availability status indicator
class AvailabilityStatusIndicator extends StatelessWidget {
  final String userId;
  final double size;

  const AvailabilityStatusIndicator({
    Key? key,
    required this.userId,
    this.size = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shiftController = Get.find<ShiftController>();

    return Obx(() {
      final isOnline = shiftController.isUserAvailable(userId);
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOnline ? Colors.green : Colors.red,
          boxShadow: isOnline
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
      );
    });
  }
}

/// Example widget showing shift details
class ShiftDetailsCard extends StatelessWidget {
  final String userId;

  const ShiftDetailsCard({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shiftController = Get.find<ShiftController>();

    return FutureBuilder(
      future: shiftController.getUserCurrentShift(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No shift scheduled for today'),
            ),
          );
        }

        final shift = snapshot.data!;
        final status = shiftController.getUserAvailabilityStatus(userId);
        final isOnline = status == 'Online';

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      shift.date.toString().split(' ')[0],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isOnline ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${AvailabilityHelper.formatTime(shift.startTime)} - ${AvailabilityHelper.formatTime(shift.endTime)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.language, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      shift.timezone,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (shift.notes != null && shift.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.note, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shift.notes!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
