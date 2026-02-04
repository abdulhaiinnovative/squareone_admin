# Firestore Schema (inferred)

This document translates `docs/FIRESTORE_SCHEMA.json` into a human-readable schema with field descriptions and notes. Fields and types are inferred from controller code; verify against a live Firestore instance.

## Outlets
- Document id: typically outlet email or custom id
- Fields:
  - `Outlet Name` (string) — display name of outlet.
  - `POC` (string) — point of contact name.
  - `Contact Number` (string) — contact phone number.
  - `Email` (string) — outlet email address.
  - `Password` (string) — stored password (security risk if plaintext).
  - `status` (string) — e.g., 'Active' or 'Inactive'.
  - `token` (string or array) — device FCM token(s) for outlet devices.
  - `outlet type` (string) — 'Retail Outlet' or 'Food Court Outlet'.

## Depart Members
- Document id: member email
- Fields:
  - `Name` (string)
  - `Contact Number` (string)
  - `Email` (string)
  - `Password` (string)
  - `Department` (string) — role: 'Admin','Operations','Security','Maintainance','Marketing','CR','Food Court'
  - `token` (string or array) — device FCM token(s)

## Emergency Tickets
- Purpose: urgent/emergency ticket records (Gate Pass flows use this collection)
- Fields:
  - `Department` (string)
  - `Outlet Name` (string)
  - `Item` (string)
  - `header` (string) — indicates the specific form/type
  - `Partiular` (string)
  - `Type` (string)
  - `Quantity` (string)
  - `Contact` (string)
  - `Time` (string)
  - `Date` (string)
  - `POC` (string)
  - `Opened By` (string)
  - `Status` (string)
  - `User ID` (string) — outlet uid
  - `Creation Time` (Timestamp)
  - `Approval Time` (Timestamp)
  - `Apprved By` (string) — note typo in code
  - `Ticket Number` (string) — UUID

## Notification
- Purpose: broadcast notifications
- Fields:
  - `subject` (string)
  - `description` (string)
  - `time` (Timestamp)
  - `file` (null or map) — `{ name: string, url: string }`

## Approval-Notification
- Purpose: notifications requiring approval (Maintainance / Security)
- Schema: same as `Notification`.

## Tickets
- Used broadly for ticket lists and status tracking.
- Common query fields (not exhaustive):
  - `Status` (string)
  - `Department` (string)
  - `Date` (string)
  - `Outlet` (string)
  - `Ticket By` (string)

## Notes & Recommendations
- The schema is inferred from code; real documents may have extra fields (e.g., attachments, comments, history arrays).
- Some field names contain typos (`Apprved By`) — prefer normalizing with constants to avoid runtime bugs.
- Sensitive data: `Password` appears stored in Firestore for outlets and depart members — this is insecure. Use Firebase Authentication only and avoid storing raw passwords.
