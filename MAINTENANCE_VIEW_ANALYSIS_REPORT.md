# 📋 Analysis Report: Maintenance View Ticket Filtering

## Executive Summary

The maintenance view currently shows tickets with **"Approved"** status, but the requirement is to display only **"Open"** status tickets for maintenance role users.

---

## Current Implementation Analysis

### 1. **File Location**

- **Main View File**: `/lib/ui/views/home/maintainance/maintainance_view.dart`
- **Related Files**:
  - `/lib/ui/views/tickets/view_ticekts.dart` (Ticket list view)
  - `/lib/ui/component/department_tile.dart` (Department tile component)
  - `/lib/ui/component/colors.dart` (Configuration constants)

### 2. **Current Status Value**

**Line 108 & 121 in `maintainance_view.dart`:**

```dart
Get.to(
    () => ViewTickets(
          status: "Approved",  // ❌ Currently set to "Approved"
        ),
    arguments: [
      maintainanceCardTitle[index],
      maintainanceCardHeaders[index]
    ]);
```

### 3. **Ticket Status System**

Based on the codebase analysis, the application uses the following ticket statuses:

- ✅ **"Open"** - New/pending tickets
- ✅ **"Approved"** - Tickets that have been approved
- ✅ **"Dismissed"** - Tickets that were rejected (Note: also spelled as "Dissmissed" in some places)
- ✅ **"Closed"** - Tickets that have been completed
- ✅ **"Artwork Approved"** - Marketing-specific status
- ❌ **"Deleted"** - Soft-deleted tickets (excluded from queries)

### 4. **How Tickets are Displayed**

#### **Department Tile Component** (`department_tile.dart`)

Shows the count of active tickets:

```dart
StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('Tickets')
        .where('header', isEqualTo: header)
        .where('Status', isEqualTo: status)  // Uses status from parent
        .snapshots(),
```

- This component receives the `status` parameter and displays the count
- Currently receives **"Approved"** from maintenance view

#### **View Tickets Screen** (`view_ticekts.dart`)

Displays the actual list of tickets:

```dart
stream: controller.filter.value == ''
    ? FirebaseFirestore.instance
        .collection('Tickets')
        .where('Status', isEqualTo: status)  // Uses status parameter
        .where('header', isEqualTo: data[1])
        .snapshots()
```

- Default constructor parameter: `status = "Open"`
- Can be overridden when navigating from maintenance view
- Currently receives **"Approved"** when called from maintenance view

---

## 5. **Maintenance Department Configuration**

### Maintenance Card Data (`colors.dart` - Lines 82-93):

```dart
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
```

**Two Categories for Maintenance Role:**

1. **Maintenance (Retail Outlet)** - Maintenance-related tickets
2. **Non-Retail Hour Activity (Retail Outlet)** - After-hours activities

---

## 6. **Impact Analysis**

### What Currently Happens:

1. Maintenance user logs in → sees `MaintainanceView`
2. Two department tiles displayed:
   - "Maintainance"
   - "Non-Retail Hour Activity"
3. Each tile shows count of **"Approved"** tickets
4. Clicking a tile navigates to `ViewTickets` with `status: "Approved"`
5. User sees approved tickets only

### What Should Happen:

1. Maintenance user logs in → sees `MaintainanceView`
2. Two department tiles displayed (same)
3. Each tile shows count of **"Open"** tickets
4. Clicking a tile navigates to `ViewTickets` with `status: "Open"`
5. User sees open/pending tickets that need attention

---

## 7. **Required Changes**

### **File**: `lib/ui/views/home/maintainance/maintainance_view.dart`

#### **Change Location 1** (Line 105-113):

**Current Code:**

```dart
onTap: () {
  Get.to(
      () => ViewTickets(
            status: "Approved",  // ❌ Change this
          ),
      arguments: [
        maintainanceCardTitle[index],
        maintainanceCardHeaders[index]
      ]);
},
```

**Required Change:**

```dart
onTap: () {
  Get.to(
      () => ViewTickets(
            status: "Open",  // ✅ Change to "Open"
          ),
      arguments: [
        maintainanceCardTitle[index],
        maintainanceCardHeaders[index]
      ]);
},
```

#### **Change Location 2** (Line 115-122):

**Current Code:**

```dart
child: DepartmentTile(
  width: width,
  height: height,
  title: maintainanceCardTitle[index],
  imgUrl: maintainanceCardImages[index],
  header: maintainanceCardHeaders[index],
  status: "Approved",  // ❌ Change this
),
```

**Required Change:**

```dart
child: DepartmentTile(
  width: width,
  height: height,
  title: maintainanceCardTitle[index],
  imgUrl: maintainanceCardImages[index],
  header: maintainanceCardHeaders[index],
  status: "Open",  // ✅ Change to "Open"
),
```

---

## 8. **Data Flow Diagram**

```
┌─────────────────────────────────────────┐
│   MaintainanceView                      │
│   (maintainance_view.dart)              │
│                                         │
│   Status: "Approved" → "Open" ✅        │
└──────────────┬──────────────────────────┘
               │
               ├─────────────────────────────────────┐
               │                                     │
               ▼                                     ▼
┌──────────────────────────────┐    ┌────────────────────────────┐
│   DepartmentTile             │    │   ViewTickets              │
│   (department_tile.dart)     │    │   (view_ticekts.dart)      │
│                              │    │                            │
│   Receives: "Open"           │    │   Receives: "Open"         │
│   Shows: Count of Open       │    │   Shows: List of Open      │
│   tickets per department     │    │   tickets                  │
└──────────────┬───────────────┘    └────────────┬───────────────┘
               │                                  │
               └──────────────┬───────────────────┘
                              ▼
              ┌────────────────────────────────┐
              │   Firebase Firestore           │
              │   Collection: 'Tickets'        │
              │                                │
              │   Query Filters:               │
              │   - Status: "Open"             │
              │   - header: (department)       │
              └────────────────────────────────┘
```

---

## 9. **Testing Recommendations**

After implementing changes, verify:

1. ✅ **Tile Count Display**: Department tiles show count of **Open** tickets only
2. ✅ **Ticket List**: Clicking tiles shows list of **Open** tickets only
3. ✅ **Ticket Actions**: Maintenance users can:
   - View open ticket details
   - Approve tickets (changes status to "Approved")
   - Dismiss tickets (changes status to "Dismissed")
4. ✅ **Filter Functionality**: Date and outlet filters work correctly with Open status
5. ✅ **No Regression**: Other user roles (Admin, Security, Food Court) not affected

---

## 10. **Related Components for Reference**

### Similar Implementations:

- **Security Department**: Uses `"Approved"` status (same current behavior)
- **Admin Department**: Shows `"Open"` status tickets in `tickets_list.dart`
- **Food Court Department**: Shows `"Open"` status tickets

### Ticket Detail Views Used:

- `GateInwardDetails` - For gate pass tickets
- `NonRentalActivity` - For non-retail hour activities
- `SecurityTicektDetails` - For maintenance tickets

---

## 11. **Risk Assessment**

| Risk Level | Impact                         | Mitigation                                           |
| ---------- | ------------------------------ | ---------------------------------------------------- |
| 🟢 **Low** | Simple status parameter change | Only affects maintenance role users, isolated change |
| 🟢 **Low** | No database schema changes     | Only filtering logic, no data modification           |
| 🟢 **Low** | No breaking changes            | Other departments use different views                |

---

## 12. **Summary of Changes Needed**

| File                     | Lines | Current Value | New Value | Occurrences |
| ------------------------ | ----- | ------------- | --------- | ----------- |
| `maintainance_view.dart` | 108   | `"Approved"`  | `"Open"`  | 1           |
| `maintainance_view.dart` | 121   | `"Approved"`  | `"Open"`  | 1           |

**Total Changes**: 2 string replacements in 1 file

---

## 13. **Additional Notes**

### Typo Found:

There's an inconsistency in the codebase:

- Some places use `"Dismissed"` (correct)
- Some places use `"Dissmissed"` (typo with double 's')

This doesn't affect the current change but should be standardized in future updates.

### Business Logic:

Maintenance role workflow appears to be:

1. **Open** → New tickets needing attention
2. **Approved** → Tickets authorized for action
3. **Closed** → Tickets completed
4. **Dismissed** → Tickets rejected

By showing **Open** tickets, maintenance users will see pending requests that need their initial review/approval.

---

## 14. **Implementation Status**

- **Report Generated**: November 7, 2025
- **Analysis Status**: ✅ Complete
- **Implementation Status**: ✅ Complete
- **Files Modified**: 1
- **Lines Changed**: 2

---

## Changelog

### November 7, 2025

- ✅ Created analysis report
- ✅ Implemented status change from "Approved" to "Open"
- ✅ Updated ViewTickets navigation parameter
- ✅ Updated DepartmentTile status parameter
