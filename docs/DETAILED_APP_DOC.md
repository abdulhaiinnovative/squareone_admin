# SquareOne Admin — Detailed Documentation

This document captures the code architecture, runtime initialization, navigation, state-management patterns, Firestore data model (inferred), notification flow, key modules, and build/run instructions for the SquareOne Admin Flutter app.

---

**Table of contents**
- Project overview
- Initialization & entrypoint
- Routing & navigation
- State management pattern
- Key modules and files
- Controllers and responsibilities
- Firestore collections & inferred schema
- Notifications & FCM flow
- Assets, fonts & resources
- Build, run & common commands
- Recommendations & extension points

---

**Project overview**
- Language / SDK: Dart / Flutter (SDK constraint in `pubspec.yaml`).
- Main packages: GetX (`get`), Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`, `firebase_storage`), `get_storage` for local persistence, and utility packages (`dio`, `file_picker`, `flutter_local_notifications`, `cached_network_image`, etc.).

See dependencies: [pubspec.yaml](pubspec.yaml)

---

**Initialization & entrypoint**
- File: [lib/main.dart](lib/main.dart)
  - Calls `WidgetsFlutterBinding.ensureInitialized()`.
  - Initializes `GetStorage` and `Firebase.initializeApp(...)` with `firebase_options.dart`.
  - Sets preferred device orientations to portrait only.
  - Configures Firebase Messaging background handler and retrieves initial message.
  - Starts `GetMaterialApp` with `SplashView` as `home`.

**Splash & Auto-login**
- File: [lib/ui/views/splash/splash_view.dart](lib/ui/views/splash/splash_view.dart)
- Controller: [lib/ui/views/splash/splash_controller.dart](lib/ui/views/splash/splash_controller.dart)
  - Requests notification permissions, waits ~3s, reads stored credentials from `GetStorage`.
  - Attempts sign-in with `FirebaseAuth` using stored credentials; on success resolves user's `Department` from `Depart Members` and routes to the appropriate department home screen (Admin, Security, Maintainance, Marketing, Food Court).

---

**Routing & navigation**
- The app uses `GetX` navigation helpers: `Get.to(...)` and `Get.offAll(...)` across controllers and UI. There is no centralized route table; screens are navigated programmatically.
- Common patterns:
  - `Get.put(Controller())` for dependency injection and controller creation.
  - `Get.offAll(HomeView())` for replacing stack after login or form submission.

Examples (files):
- `lib/ui/views/auth/auth_controller.dart` — routes user to department-specific home views after sign-in.
- `lib/ui/views/splash/splash_controller.dart` — auto-login and routing.

---

**State management**
- GetX (`get`) is used for state management and DI.
  - Controllers extend `GetxController`.
  - Views use `GetBuilder<T>` or `Obx` to react to Rx fields.
- `GetStorage` stores small, persistent values (email, password, name).

---

**Key modules & file map (high level)**
- UI components: `lib/ui/component/*` — shared widgets (tiles, buttons, text fields, dropdowns, colors, dialog helper).
- Views and controllers: `lib/ui/views/*` grouped by feature (auth, splash, home, forms, tickets, notifications, profile, outlets, department).
- Helpers: `lib/helper/*` — e.g., `notification_helper.dart` for FCM & local notifications integration.

Representative files (not exhaustive):
- Entry: [lib/main.dart](lib/main.dart)
- Splash: [lib/ui/views/splash/*](lib/ui/views/splash)
- Auth: [lib/ui/views/auth/*](lib/ui/views/auth)
- Home (per-department): [lib/ui/views/home/*](lib/ui/views/home)
- Tickets: [lib/ui/views/tickets/*](lib/ui/views/tickets)
- Forms: [lib/ui/views/forms/*](lib/ui/views/forms)
- Notifications: [lib/ui/views/notifications/*](lib/ui/views/notifications)
- Profile: [lib/ui/views/profile/*](lib/ui/views/profile)
- Outlets: [lib/ui/views/outlets/*](lib/ui/views/outlets)

---

**Controllers & responsibilities (patterns & examples)**
- Controllers manage UI state, input controllers, validation, Firestore operations, and navigation.
- Common responsibilities:
  - Hold `TextEditingController` instances for inputs.
  - Expose Rx fields (`RxBool`, `RxString`, `Rx<TextEditingController>`) for reactive updates.
  - Read/write to Firestore collections.
  - Trigger FCM messages using `sendMessage(...)` helper.
  - Navigate with `Get.to`, `Get.offAll` and show dialogs/snackbars via `Get`.

Examples:
- `GatePassInwardController` (`lib/ui/views/forms/gate_pass/gate_pass_inward_controller.dart`)
  - Collects form inputs (outlet, particular, type, quantity, contact, date/time, POC).
  - Resolves outlet UID and token from `Outlets` collection.
  - Creates a ticket in `Emergency Tickets` and notifies department and outlet tokens.

- `AddOutletController` (`lib/ui/views/forms/add_outlet/add_outlet_controller.dart`)
  - Creates a Firebase Auth user for the outlet and writes an `Outlets` doc with outlet metadata.

- `AddDepartmentController` (`lib/ui/views/forms/add_depart_member/add_depart_controller.dart`)
  - Writes `Depart Members` document and creates Firebase Auth user.

- `AddNotificationsController` (`lib/ui/views/forms/add_notification/add_notifications_controller.dart`)
  - Handles file picking and HEIC conversion, Firebase Storage uploads, writing to `Notification` or `Approval-Notification`, and broadcasting messages to outlet tokens.

---

**Firestore collections & inferred schemas**
The following schemas are inferred from controller code (field names are string keys as used in the code). This is not authoritative — check the live Firestore for exact types and additional fields.

- `Outlets` (document keyed by outlet email in some places)
  - Outlet Name: string
  - POC: string
  - Contact Number: string
  - Email: string
  - Password: string
  - status: string ('Active'|'Inactive')
  - token: string or array (device tokens)
  - outlet type: string ('Retail Outlet' | 'Food Court Outlet')

- `Depart Members` (document keyed by email)
  - Name: string
  - Contact Number: string
  - Email: string
  - Password: string
  - Department: string (e.g., 'Admin','Operations','Security','Maintainance','Marketing','CR','Food Court')
  - token: string or array (device token(s))

- `Emergency Tickets` (examples from gate pass inward)
  - Department: string ('Security')
  - Outlet Name: string
  - Item: string
  - header: string (form header / type)
  - Partiular: string
  - Type: string
  - Quantity: string
  - Contact: string
  - Time: string
  - Date: string
  - POC: string
  - Opened By: string
  - Status: string (e.g., 'Urgent Approved')
  - User ID: string (outlet UID)
  - Creation Time: Timestamp
  - Approval Time: Timestamp
  - Apprved By: string
  - Ticket Number: string (UUID)

- `Notification` documents
  - subject: string
  - description: string
  - time: Timestamp/DateTime
  - file: null or map { name: string, url: string }

- `Approval-Notification` documents (for maintainance/security approval flows)
  - same fields as above

- `Tickets` collection (used across ticket listing views)
  - Common fields used in queries: Status, Department, Date, Outlet, Ticket By (varies based on generated tickets).

Notes:
- Several controllers query `Outlets` to read `token` values and `Depart Members` to broadcast notifications.
- Field naming is inconsistent in places (e.g., 'Apprved By' vs 'Approved By' — maintain exact key strings when reading/writing).

---

**Notifications & FCM flow**
- Helpers: [lib/helper/notification_helper.dart](lib/helper/notification_helper.dart)
  - `PushNotificationService` registers foreground and click handlers, creates a local Android notification channel, and listens to `FirebaseMessaging.onMessage` and `onMessageOpenedApp` events.
  - `onMessageOpenedApp` inspects `message.data['type']` and routes the user to specific detail screens (Gate ticket detail, non-rental activity, security ticket detail) or handles a `logout` type by clearing storage and signing out.

- Sending notifications: `sendMessage(...)` in `lib/ui/views/forms/add_notification/add_notifications_controller.dart` (and referenced by other controllers) uses a service-account based flow:
  - `getAccessToken()` uses `googleapis_auth` to obtain an OAuth access token using embedded service-account JSON in code (sensitive — see Recommendations).
  - `sendMessage()` posts to the FCM HTTP v1 endpoint `https://fcm.googleapis.com/v1/projects/<project>/messages:send` with a bearer access token and message payload including `notification`, `data`, and `android` channel config.

Security note: The repository contains service account private key material inside the controller file (hard-coded). This is a severe security risk — rotate the key immediately and move secrets to a secure environment (CI secrets, server-side service, or environment variables). Do not commit private keys.

---

**Assets, fonts & resources**
- App uses custom fonts in `assets/fonts/` (Poppins variations) declared in `pubspec.yaml`.
- Image assets are in `assets/` organized by `splash`, `home`, `nav_bar`, `profile`.

---

**Build & run**
Prerequisites: Flutter SDK (as specified in `pubspec.yaml` environment), Android/iOS toolchains configured for platform builds.

Common commands:
```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d <device>
```

For release builds, follow platform-specific steps (Android signing via `key.properties`, iOS provisioning in Xcode). See `android/` and `ios/` folders for platform config.

---

**Testing & validation**
- Unit tests: repository includes `test/widget_test.dart` — run `flutter test` to execute.
- Static analysis: `flutter analyze` uses `flutter_lints` configured in `analysis_options.yaml`.

---

**Security & maintenance recommendations**
1. Remove embedded service-account private key from source. Use a server-side function or environment-secured token exchange to send FCM messages.
2. Consolidate notification sending into a single helper/service (it's partially duplicated across controllers). Keep the FCM HTTP v1 client in one place and call it from controllers.
3. Normalize Firestore field names and create a small schema reference module or constants file to avoid typos like `Apprved By`.
4. Consider centralizing Firestore path helpers and access wrappers for testing and easier mocking.
5. Limit direct use of `Get.offAll`/`Get.to` across controllers — centralize navigation flows if the app grows.

---

**Next steps I can take for you**
- Generate a full file-by-file index linking to the most relevant controllers and views.
- Produce a Mermaid graph of navigation flows between the major screens.
- Extract an explicit Firestore schema file (JSON/Markdown) listing collections and fields found in the code.
- Run `flutter analyze` and collect issues to address.

Tell me which next step you want and I will proceed.
