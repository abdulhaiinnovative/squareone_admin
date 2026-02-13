import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:squareone_admin/ui/views/forms/add_depart_member/add_depart_member_view.dart';
import 'package:squareone_admin/ui/views/home/food_dept/food_dept_view.dart';
import 'package:squareone_admin/ui/views/home/head/admin_home/admin_home.dart';
import 'package:squareone_admin/ui/views/home/head/admin_home/admin_notification/new_admin_notification.dart';

import 'package:squareone_admin/ui/views/home/head/head_home/head_profile_view.dart';
import 'package:squareone_admin/ui/views/home/head/head_home/worker_view.dart';
import 'package:squareone_admin/ui/views/home/maintainance/maintainance_view.dart';
import 'package:squareone_admin/ui/views/home/marketing/marketing_view.dart';
import 'package:squareone_admin/ui/views/home/security/security_view.dart';
import 'package:squareone_admin/ui/views/notifications/notifications_view.dart';
import 'package:squareone_admin/ui/views/profile/profile_view.dart';
import 'package:squareone_admin/ui/views/team_availability_dashboard.dart';

import '../views/home/admin/home_view.dart';
import '../views/home/head/admin_home/adminprofile/new_admin_profile.dart';
import '../views/home/head/head_home/head_home.dart';

const Color redColor = Color(0xffC12934);
const Color greenColor = Color(0xFFDEFFE5);
const Color textGreenColor = Color(0xFF27BB4A);
const Color textRedColor = Color(0xFFC12934);
const Color bgRedColor = Color(0xFFFFDEDE);
const Color greyTextColor = Color(0xFF858597);

List homeCardTitle = [
  'Gate Pass Inward',
  'Gate Pass Outwards',
  'Maintainance',
  'Non-Retail Hour Activity',
  "Food Court Inward",
  "Food Court Outward",
  "Food Court Activity",
  "Food Court Maintainance",
];
List homeCardImages = [
  'assets/home/gate_pass_inward.svg',
  'assets/home/gate_pass_outward.svg',
  'assets/home/maintenance.svg',
  'assets/home/non_retail.svg',
  'assets/home/gate_pass_inward.svg',
  'assets/home/gate_pass_outward.svg',
  'assets/home/maintenance.svg',
  'assets/home/non_retail.svg',
];

List homeCardHeaders = [
  'Gate-Pass-Inward(Retail Outlet)',
  'Gate-Pass-Outwards(Retail Outlet)',
  'Maintainance(Retail Outlet)',
  'Non-Retail-Hour-Activity(Retail Outlet)',
  'Gate-Pass-Inward(Food Court Outlet)',
  'Gate-Pass-Outwards(Food Court Outlet)',
  'Non-Retail-Hour-Activity(Food Court Outlet)',
  'Maintainance(Food Court Outlet)',
];

List securityCardTitle = [
  'Gate Pass Inward',
  'Gate Pass Outwards',
  'Maintainance',
  'Non-Retail Hour Activity',
  "Food Court Inward",
  "Food Court Outward",
  "Food Court Activity",
  "Food Court Maintainance",
];

List securityCardImages = [
  'assets/home/gate_pass_inward.svg',
  'assets/home/gate_pass_outward.svg',
  'assets/home/maintenance.svg',
  'assets/home/non_retail.svg',
  'assets/home/gate_pass_inward.svg',
  'assets/home/gate_pass_outward.svg',
  'assets/home/maintenance.svg',
  'assets/home/non_retail.svg',
];

List securityCardHeaders = [
  'Gate-Pass-Inward(Retail Outlet)',
  'Gate-Pass-Outwards(Retail Outlet)',
  'Maintainance(Retail Outlet)',
  'Non-Retail-Hour-Activity(Retail Outlet)',
  'Gate-Pass-Inward(Food Court Outlet)',
  'Gate-Pass-Outwards(Food Court Outlet)',
  'Non-Retail-Hour-Activity(Food Court Outlet)',
  'Maintainance(Food Court Outlet)',
];

List maintainanceCardTitle = [
  'Maintainance',
  'Non-Retail Hour Activity',
];

List maintainanceCardImages = [
  'assets/home/maintenance.svg',
  'assets/home/non_retail.svg',
];

List maintainanceCardHeaders = [
  'Maintainance(Retail Outlet)',
  'Non-Retail-Hour-Activity(Retail Outlet)',
];

List foodDeptCardTitle = [
  "Food Court Inward",
  "Food Court Outward",
  "Food Court Activity",
  "Food Court Maintainance",
];

List foodDeptCardImages = [
  'assets/home/gate_pass_inward.svg',
  'assets/home/gate_pass_outward.svg',
  'assets/home/maintenance.svg',
  'assets/home/non_retail.svg',
];

List foodDeptCardHeaders = [
  'Gate-Pass-Inward(Food Court Outlet)',
  'Gate-Pass-Outwards(Food Court Outlet)',
  'Non-Retail-Hour-Activity(Food Court Outlet)',
  'Maintainance(Food Court Outlet)',
];
List marketingCardTitle = [
  'Branding Activity',
  'Food Court Branding Activity',
];

List marketingCardImages = [
  'assets/home/non_retail.svg',
  'assets/home/non_retail.svg',
];

List marketingCardHeaders = [
  'Non-Retail-Hour-Activity',
  'Non-Retail-Hour-Activity(Food Court Outlet)',
];

List profileImg = [
  'assets/home/ticket.svg',
  'assets/home/ticket.svg',
  'assets/home/ticket.svg',
  'assets/home/ticket.svg',
  'assets/home/ticket.svg',
  'assets/profile/outlet.svg',
  'assets/profile/profile.svg'
];
List securityProfileText = [
  'Approve Tickets',
  'Dismiss Tickets',
  // 'Closed Tickets',
  // 'Urgent Tickets',
  'All Outlets',
  'All Departments',
];
List profileText = [
  'In Progress Tickets',
  'Approve Tickets',
  'Dismiss Tickets',
  // 'Closed Tickets',
  // 'Urgent Tickets',
  'All Outlets',
  'All Departments',
];

final List profileCardImages = [
  'assets/profile/profile_1.svg',
  'assets/profile/profile_2.svg',
  'assets/profile/profile_3.svg',
  'assets/profile/profile_4.svg',
];
List emergencyCard = [
  'Gate Pass Inward',
  'Gate Pass Outwards',
  'Non-Retail Hour Activity',
  'Maintenance',
];

List emergencyCardImages = [
  'assets/home/gate_pass_inward.svg',
  'assets/home/gate_pass_outward.svg',
  'assets/home/non_retail.svg',
  'assets/home/maintenance.svg',
];
List<SalomonBottomBarItem> headItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home_outlined),
    title: const Text(
      'Home',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.notifications_none),
    title: const Text(
      'Notification',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.groups_3_outlined),
    title: const Text(
      'Workers',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.account_circle_outlined),
    title: const Text(
      'Profile',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
];
List<SalomonBottomBarItem> adminItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home_outlined),
    title: const Text(
      'Home',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.notifications_none),
    title: const Text(
      'Notification',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.groups_3_outlined),
    title: const Text(
      'Workers',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.account_circle_outlined),
    title: const Text(
      'Profile',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
];
List<SalomonBottomBarItem> newAdminItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home_outlined),
    title: const Text(
      'Home',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.notifications_none),
    title: const Text(
      'Notification',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),

  SalomonBottomBarItem(
    icon: const Icon(Icons.account_circle_outlined),
    title: const Text(
      'Profile',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
];

List<SalomonBottomBarItem> maintainanceItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home_outlined),
    title: const Text(
      'Home',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.notifications_none),
    title: const Text(
      'Notification',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.account_circle_outlined),
    title: const Text(
      'Profile',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
];
List<SalomonBottomBarItem> foodDeptItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home_outlined),
    title: const Text(
      'Home',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.notifications_none),
    title: const Text(
      'Notification',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.account_circle_outlined),
    title: const Text(
      'Profile',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
];
List<SalomonBottomBarItem> marketingItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home_outlined),
    title: const Text(
      'Home',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.notifications_none),
    title: const Text(
      'Notification',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.account_circle_outlined),
    title: const Text(
      'Profile',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
];

List<SalomonBottomBarItem> securityItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home_outlined),
    title: const Text(
      'Home',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.notifications_none),
    title: const Text(
      'Notification',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.account_circle_outlined),
    title: const Text(
      'Profile',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    ),
  ),
];

final adminPages = [
  const HomeView(),
  const NotificationsView(),
  const AddDepartmentView(),
  const ProfileView(),
];

final headPages = [
  const HeadHome(),
  const NewAdminNotification(),
  WorkerView(),
  const HeadProfileView(),
];
final newAdminPages = [
  const AdminHome(),
  const NewAdminNotification(),
  // const AddDepartmentView(),
  const NewAdminProfile(),
];
final foodDeptPages = [
  const FoodDeptView(),
  const NotificationsView(),
  const ProfileView(),
];
final maintainancePages = [
  const MaintainanceView(),
  const NotificationsView(),
  const ProfileView(),
];
final marketingPages = [
  const MarketingView(),
  const NotificationsView(),
  const ProfileView(),
];
final securityPages = [
  const SecurityView(),
  const NotificationsView(),
  const ProfileView(),
];
