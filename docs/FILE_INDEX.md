# File Index — Key UI files

This index lists important views, controllers, components, and helpers with workspace-relative links to help you navigate the codebase.

## Entry
- [lib/main.dart](lib/main.dart)
  - Summary: App entry; initializes Firebase, GetStorage, FCM and starts `GetMaterialApp` with `SplashView`.
  - Key points: `backgroundHandler`, `Firebase.initializeApp`, `GetMaterialApp`.

## Splash & Auth
- [lib/ui/views/splash/splash_view.dart](lib/ui/views/splash/splash_view.dart)
  - Summary: Splash screen UI with branding and loading indicator.
  - Key widgets: background image, loading spinner; uses `SplashController` via `GetBuilder`.
- [lib/ui/views/splash/splash_controller.dart](lib/ui/views/splash/splash_controller.dart)
  - Summary: Auto-login flow and routing to department home screens.
  - Key methods: `onInit()` (requests FCM permissions, timer), `getData()`, `routeToHome(email)`.
- [lib/ui/views/auth/auth_view.dart](lib/ui/views/auth/auth_view.dart)
  - Summary: Login UI for department members and outlets.
  - Key widgets: email/password fields, submit button; interacts with `AuthController`.
- [lib/ui/views/auth/auth_controller.dart](lib/ui/views/auth/auth_controller.dart)
  - Summary: Handles sign-in using `FirebaseAuth` and routes user by department.
  - Key methods: login, error handling, Firestore lookup for `Depart Members`.

## Home (by department)
- [lib/ui/views/home/admin/admin_home_view.dart](lib/ui/views/home/admin/admin_home_view.dart)
  - Summary: Admin dashboard with quick actions (add outlet/member, view reports, notifications).
  - Key widgets: grid/list of admin actions; navigates to forms and tickets.
- [lib/ui/views/home/maintainance/maintainance_home_view.dart](lib/ui/views/home/maintainance/maintainance_home_view.dart)
  - Summary: Maintainance-specific dashboard showing assigned tickets and actions.
- [lib/ui/views/home/security/security_home_view.dart](lib/ui/views/home/security/security_home_view.dart)
  - Summary: Security dashboard tailored to security tickets and gate pass handling.
- [lib/ui/views/home/marketing/marketing_home_view.dart](lib/ui/views/home/marketing/marketing_home_view.dart)
  - Summary: Marketing dashboard with marketing tickets and approvals.
- [lib/ui/views/home/food_dept/food_dept_home_view.dart](lib/ui/views/home/food_dept/food_dept_home_view.dart)
  - Summary: Food court view for Food Court Outlet users with ticket lists and outlet-specific actions.

## Forms
- Gate Pass Inward: [lib/ui/views/forms/gate_pass/gate_pass_inward_view.dart](lib/ui/views/forms/gate_pass/gate_pass_inward_view.dart)
  - Summary: Form UI to create inward gate pass tickets (dropdowns, date/time pickers).
  - Key widgets: dropdown for outlet/particular/type, `datefeild`, `timefeild`, submit button.
- Gate Pass Inward Controller: [lib/ui/views/forms/gate_pass/gate_pass_inward_controller.dart](lib/ui/views/forms/gate_pass/gate_pass_inward_controller.dart)
  - Summary: Handles form validation, resolves outlet UID/token, writes to `Emergency Tickets`, and sends notifications.
  - Key methods: `pickDate()`, `pickTime()`, `createTicket()`.
- Gate Pass Outward: [lib/ui/views/forms/gate_pass/gate_pass_outward._view.dart](lib/ui/views/forms/gate_pass/gate_pass_outward._view.dart)
  - Summary: Outward gate pass form (similar fields to inward); used by outlets.
- Add Outlet: [lib/ui/views/forms/add_outlet/add_outlet_view.dart](lib/ui/views/forms/add_outlet/add_outlet_view.dart)
  - Summary: UI to add a new outlet (name, contact, email, password, type).
- Add Outlet Controller: [lib/ui/views/forms/add_outlet/add_outlet_controller.dart](lib/ui/views/forms/add_outlet/add_outlet_controller.dart)
  - Summary: Creates Firebase Auth account and writes `Outlets` doc.
  - Key methods: `addOutlet()`.
- Add Depart Member: [lib/ui/views/forms/add_depart_member/add_depart_member_view.dart](lib/ui/views/forms/add_depart_member/add_depart_member_view.dart)
  - Summary: UI to add department members (name, contact, email, password, department).
- Add Depart Controller: [lib/ui/views/forms/add_depart_member/add_depart_controller.dart](lib/ui/views/forms/add_depart_member/add_depart_controller.dart)
  - Summary: Writes `Depart Members` doc and creates Firebase Auth user.
  - Key methods: `addDepart()`.
- Add Notification View: [lib/ui/views/forms/add_notification/add_notification_view.dart](lib/ui/views/forms/add_notification/add_notification_view.dart)
  - Summary: UI to compose notifications with optional file attachment.
- Add Notification Controller: [lib/ui/views/forms/add_notification/add_notifications_controller.dart](lib/ui/views/forms/add_notification/add_notifications_controller.dart)
  - Summary: Handles file picking/HEIC conversion, uploads to Firebase Storage, writes to `Notification` or `Approval-Notification`, and broadcasts via `sendMessage()`.
  - Key methods: `pickFile()`, `uploadFileToFirebaseStorage()`, `sendNotifications()`, `sendMessage()`.

## Tickets
- Tickets listing & controllers: [lib/ui/views/tickets/tickets_list.dart](lib/ui/views/tickets/tickets_list.dart), [lib/ui/views/tickets/tickets_controller.dart](lib/ui/views/tickets/tickets_controller.dart)
  - Summary: Central ticket listing and filtering by department/date/outlet.
  - Key methods: queries to `Tickets` collection, filtering logic in `tickets_controller`.
- Ticket detail views:
  - [lib/ui/views/tickets/details/gate_pass_detail.dart](lib/ui/views/tickets/details/gate_pass_detail.dart)
    - Summary: Shows gate pass ticket fields and approval/close actions.
  - [lib/ui/views/tickets/details/non_retail_activity.dart](lib/ui/views/tickets/details/non_retail_activity.dart)
    - Summary: Non-retail activity ticket detail (activity, notes, actions).
  - [lib/ui/views/tickets/details/security.dart](lib/ui/views/tickets/details/security.dart)
    - Summary: Security ticket detail view with relevant fields.
- Approved/Dismissed/Closed lists:
  - [lib/ui/views/tickets/approved_tickets.dart](lib/ui/views/tickets/approved_tickets.dart)
  - [lib/ui/views/tickets/dismissed_tickets.dart](lib/ui/views/tickets/dismissed_tickets.dart)
    - Summary: Paginated list of dismissed tickets; removed unused `intl` import.
  - [lib/ui/views/tickets/closed_tickets_list.dart](lib/ui/views/tickets/closed_tickets_list.dart)

## Outlets & Reports
- [lib/ui/views/outlets/outlet_view.dart](lib/ui/views/outlets/outlet_view.dart)
  - Summary: Lists outlets and links to outlet profile.
- [lib/ui/views/outlets/outlet_profile.dart](lib/ui/views/outlets/outlet_profile.dart)
  - Summary: Detailed view for an outlet with actions (view workers, reports).
- Carton report: [lib/ui/views/outlets/carton_report.dart](lib/ui/views/outlets/carton_report.dart)
  - Summary: Outlet-specific carton usage report UI.
- Carton controller: [lib/ui/views/outlets/carton_report_controller.dart](lib/ui/views/outlets/carton_report_controller.dart)
  - Summary: Handles Firestore queries for carton report data.

## Profile & Department
- [lib/ui/views/profile/profile_view.dart](lib/ui/views/profile/profile_view.dart)
  - Summary: Profile menu with links to view/edit profile and department features.
- [lib/ui/views/profile/profile_controller.dart](lib/ui/views/profile/profile_controller.dart)
  - Summary: Manages profile state and sign-out flow.
- [lib/ui/views/profile/my_profile_view.dart](lib/ui/views/profile/my_profile_view.dart)
  - Summary: Displays current user's profile fetched from `Depart Members` doc.
- [lib/ui/views/department/department_view.dart](lib/ui/views/department/department_view.dart)
  - Summary: Lists department members and allows navigation to member profiles.

## Notifications
- [lib/ui/views/notifications/notifications_view.dart](lib/ui/views/notifications/notifications_view.dart)
  - Summary: Shows pending, approval, and sent notifications; links to detail and approval screens.
- [lib/ui/views/notifications/notification_detail.dart](lib/ui/views/notifications/notification_detail.dart)
  - Summary: Detailed view of a notification and actions (approve, dismiss).
- [lib/ui/views/notifications/sent_notification/sent_notifications.dart](lib/ui/views/notifications/sent_notification/sent_notifications.dart)
  - Summary: Lists notifications already broadcast.
- Notifications controller: [lib/ui/views/notifications/notifications_controller.dart](lib/ui/views/notifications/notifications_controller.dart)
  - Summary: Reads `Depart Members` tokens and manages approval/dispatch flows.
- Notification helper: [lib/helper/notification_helper.dart](lib/helper/notification_helper.dart)
  - Summary: Sets up FCM listeners, local notifications, and route-on-click behavior.

## UI Components
- `lib/ui/component/` contains shared UI widgets and helpers (buttons, text fields, tiles, dialog).
  - Notable components: `dropdown_feild.dart`, `text_feilds.dart`, `buttons.dart`, `dialog.dart`, and various tile widgets used in lists.

---

If you want more detail for any specific file (examples, key fields, or call sites), tell me which files and I will expand them.
