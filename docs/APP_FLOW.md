**Overview**

This document summarizes the app structure, startup flow, navigation patterns, main features, and integration points for the SquareOne Admin Flutter app.

**Entry Point**:
- **File**: [lib/main.dart](lib/main.dart)
- App initializes `GetStorage` and `Firebase` then starts `GetMaterialApp` with `SplashView` as `home`.

**Startup & Routing**:
- On launch the app initializes Firebase services and messaging (see `main.dart`).
- `SplashView` (`lib/ui/views/splash/splash_view.dart`) uses `SplashController` to:
  - request notification permissions,
  - wait ~3s, then check `GetStorage` for stored credentials,
  - sign in with `FirebaseAuth` if credentials exist,
  - route to a department-specific home screen using `Get.offAll(...)` based on the `Depart Members` document.
- Key routing logic: [lib/ui/views/splash/splash_controller.dart](lib/ui/views/splash/splash_controller.dart)

**State Management & Storage**:
- Uses `GetX` and `GetStorage` for lightweight local storage and dependency injection.
- Controllers are `GetxController`/`GetBuilder`-driven; controllers are placed next to views under `lib/ui/views/...`.

**Notifications & Messaging**:
- Firebase Cloud Messaging is configured in `main.dart` (background handler and `getInitialMessage`).
- `SplashController` requests runtime permission for notifications and the app sends device tokens (used by some controllers to push messages).

**Data Layer & Firestore Collections** (observed usages)
- `Outlets` — outlet metadata (name, uid, token, status).
- `Depart Members` — user records keyed by email (department, token, etc.).
- `Emergency Tickets` — tickets created by various forms (Gate Pass, Emergency tickets), storing fields like `Status`, `Opened By`, `Ticket Number`, timestamps.
- Other collections referenced by controllers and views for tickets, notifications, and outlets.

**Major Modules & Screens**
- Splash & Auth
  - `lib/ui/views/splash/*` — startup and auto-login flow.
  - `lib/ui/views/auth/*` — login UI and `AuthController`.
- Home (department-specific)
  - Admin/Operations: `lib/ui/views/home/admin/*`
  - Security, Maintainance, Marketing, Food Court: `lib/ui/views/home/*`
- Forms
  - Gate Pass Inward: view + controller [lib/ui/views/forms/gate_pass/gate_pass_inward_view.dart](lib/ui/views/forms/gate_pass/gate_pass_inward_view.dart) and [lib/ui/views/forms/gate_pass/gate_pass_inward_controller.dart](lib/ui/views/forms/gate_pass/gate_pass_inward_controller.dart)
    - Creates tickets in `Emergency Tickets` collection, notifies outlets and department members, uses Firestore and FCM tokens.
  - Gate Pass Outward, Add Outlet, Add Depart Member, Add Notification — similar patterns (form view + controller).
- Tickets & Approvals
  - Ticket lists, approved/dismissed/closed tickets under `lib/ui/views/tickets/*`.
- Profile & Outlets
  - Profile screens and controllers under `lib/ui/views/profile/*` and outlets under `lib/ui/views/outlets/*`.
- Notifications
  - Notifications list and detail screens under `lib/ui/views/notifications/*`.

**Typical Controller Responsibilities**
- Manage input controllers (`TextEditingController`) and Rx state.
- Validate form fields and show `Get.showSnackbar` for errors.
- Write to Firestore documents/collections, optionally trigger FCM messages via stored tokens.
- Navigate using `Get.offAll`, `Get.to`, etc.

**Integration & Third-party Packages**
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`, `firebase_storage`.
- State & routing: `get` (GetX), `get_storage`.
- UI helpers: `flutter_svg`, `salomon_bottom_bar`.
- Networking & utilities: `dio`, `http`, `cached_network_image`, `flutter_local_notifications`.

**Data Flow Example — Gate Pass Inward**
- User opens `GatePassInward` form (`lib/ui/views/forms/gate_pass/gate_pass_inward_view.dart`).
- The view uses `GatePassInwardController` to collect fields (outlet, particular, type, quantity, contact, date/time, POC).
- On submit `createTicket()` generates a UUID, resolves outlet `uid` and `token`, writes a document into `Emergency Tickets`, then:
  - sends notifications to the outlet and department members,
  - clears fields and navigates back to an appropriate home (`AdminHomeView`).

**Where to look to extend or debug quickly**
- App entry and initialization: [lib/main.dart](lib/main.dart)
- Auto-login + routing: [lib/ui/views/splash/splash_controller.dart](lib/ui/views/splash/splash_controller.dart)
- Example form + logic: Gate Pass Inward controller/view (links above).
- Tickets listing and controllers: `lib/ui/views/tickets/*` and `lib/ui/views/tickets/tickets_controller.dart`.

**Notes / Recommendations**
- Keep Firestore field names consistent (strings used as keys across multiple controllers).
- Centralize notification sending helper if multiple controllers replicate token messaging code.
- Consider abstracting repeated form validation to a shared helper to avoid duplication.

If you'd like, I can:
- generate a visual flow diagram (Mermaid) showing navigation paths,
- expand this doc with an API/Firestore schema reference extracted from controllers,
- or run `flutter analyze` to surface any issues.
