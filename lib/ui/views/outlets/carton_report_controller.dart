import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartonReportController extends GetxController {
  var isLoading = false.obs;
  int inwardCartonCount = 0;
  int outwardCartonCount = 0;
  RxList<Map<String, dynamic>> inwardReport = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> outwardReport = <Map<String, dynamic>>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timestamp _dateStringToTimestamp(String dateString) {
    try {
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        throw FormatException('Invalid date format: $dateString');
      }

      DateTime dateTime = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      return Timestamp.fromDate(dateTime);
    } catch (e) {
      print('Error converting date string to timestamp: $e');
      return Timestamp.now();
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<void> fetchInwardReport(
      String fromDate, String toDate, String outletName) async {
    try {
      isLoading.value = true;
      inwardReport.clear();
      inwardCartonCount = 0;

      Timestamp fromTimestamp = _dateStringToTimestamp(fromDate);
      Timestamp toTimestamp = _dateStringToTimestamp(toDate);

      DateTime toDatePlusOne =
          toTimestamp.toDate().add(const Duration(days: 1));
      Timestamp toTimestampPlusOne = Timestamp.fromDate(toDatePlusOne);

      QuerySnapshot querySnapshot = await _firestore
          .collection('Tickets')
          .where('Approval Time', isGreaterThanOrEqualTo: fromTimestamp)
          .where('Approval Time', isLessThanOrEqualTo: toTimestampPlusOne)
          .where('Outlet', isEqualTo: outletName)
          .where('header', isEqualTo: 'Gate-Pass-Inward(Retail Outlet)')
          .where('Type', isEqualTo: 'Cartons')
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar(
          'Info',
          'No reports found for the selected date range',
        );
      } else {
        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          inwardReport.add(data);
          inwardCartonCount += int.tryParse(data['Quantity']?.toString() ?? '0') ?? 0;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load inward cartons: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOutwardReport(
      String fromDate, String toDate, String outletName) async {
    try {
      isLoading.value = true;
      outwardReport.clear();
      outwardCartonCount = 0;

      Timestamp fromTimestamp = _dateStringToTimestamp(fromDate);
      Timestamp toTimestamp = _dateStringToTimestamp(toDate);

      DateTime toDatePlusOne =
          toTimestamp.toDate().add(const Duration(days: 1));
      Timestamp toTimestampPlusOne = Timestamp.fromDate(toDatePlusOne);

      QuerySnapshot querySnapshot = await _firestore
          .collection('Tickets')
          .where('Approval Time', isGreaterThanOrEqualTo: fromTimestamp)
          .where('Approval Time', isLessThanOrEqualTo: toTimestampPlusOne)
          .where('Outlet', isEqualTo: outletName)
          .where('header', isEqualTo: 'Gate-Pass-Outwards(Retail Outlet)')
          .where('Type', isEqualTo: 'Cartons')
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar(
          'Info',
          'No reports found for the selected date range',
        );
      } else {
        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          outwardReport.add(data);
          outwardCartonCount += int.tryParse(data['Quantity']?.toString() ?? '0') ?? 0;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load outward cartons: $e',
        backgroundColor: const Color(0xFFB71C1C),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
