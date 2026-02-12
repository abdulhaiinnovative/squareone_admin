// Hardcoded dummy data for employee-facing app (no persistence)
// Keep const maps for fast synchronous access; provide simple helpers

const Map<String, Map<String, dynamic>> departments = {
  'department_id1': {'name': 'Operations'},
  'department_id2': {'name': 'Finance'},
  'department_id3': {'name': 'Procurement'},
};

const Map<String, Map<String, dynamic>> personnel = {
  'user_id1': {
    'name': 'Super Admin',
    'role': 'SuperAdmin',
    'email': 'superadmin@example.com',
    'phone': '+1234567890',
    'password': 'superadmin123',
  },
  'user_id2': {
    'name': 'Squareone Admin',
    'role': 'admin',
    'email': 'admin@gmail.com',
    'password': 'admin123',
    'phone': '+0987654321',
  },
  'user_id3': {
    'name': 'Alice Johnson',
    'role': 'head',
    'department_id': 'department_id1',
    'email': 'alice@example.com',
    'phone': '+1122334455',
    'shifts': [
      {
        'date': '2026-01-22',
        'start_time': '09:00:00',
        'end_time': '17:00:00',
        'timezone': 'PKT',
      },
      {
        'date': '2026-01-23',
        'start_time': '09:00:00',
        'end_time': '17:00:00',
        'timezone': 'PKT',
      }
    ],
  },
  'user_id4': {
    'name': 'Bob Brown',
    'role': 'head',
    'department_id': 'department_id1',
    'email': 'bob@example.com',
    'phone': '+5566778899',
    'shifts': [
      {
        'date': '2026-01-22',
        'start_time': '17:00:00',
        'end_time': '01:00:00',
        'timezone': 'PKT',
      }
    ],
  },
  'user_id5': {
    'name': 'Charlie Davis',
    'role': 'employee',
    'department_id': 'department_id1',
    'email': 'charlie@example.com',
    'phone': '+9988776655',
    'password': 'charlie123',
    'added_by': 'user_id3',
    'shifts': [
      {
        'date': '2026-01-22',
        'start_time': '09:00:00',
        'end_time': '17:00:00',
        'timezone': 'PKT',
      }
    ],
  },
  // Additional employees for testing
  'user_id6': {
    'name': 'Sara Khan',
    'role': 'employee',
    'department_id': 'department_id1',
    'email': 'sara@example.com',
    'password': 'sara123',
    'phone': '+923001234567',
    'added_by': 'user_id3',
    'shifts': [
      {
        'date': '2026-01-23',
        'start_time': '08:00:00',
        'end_time': '16:00:00',
        'timezone': 'PKT',
      }
    ],
  },
  'user_id7': {
    'name': 'Ahmed Ali',
    'role': 'employee',
    'department_id': 'department_id2',
    'email': 'ahmed@example.com',
    'password': 'ahmed123',
    'phone': '+923331234567',
    'added_by': 'user_id4',
    'shifts': [
      {
        'date': '2026-01-23',
        'start_time': '10:00:00',
        'end_time': '18:00:00',
        'timezone': 'PKT',
      }
    ],
  },
};

final Map<String, Map<String,dynamic>> tickets = {
  'ticket_id' : {
    // "parent_ticket_id": null,
    // "is_subticket": false,

    'ticket_title': 'Clean',
    'ticket_description': "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",


    "created_at": "2026-01-23T10:15:00+05:00",
    "created_by": "user_id3",           // Alice (Head)
    "created_by_role": "head",
    "department_id": "${departments['department_id1']?['name']}",


    "assigned_to": const {
      "user_id": "user_id5",
      "name": "Charlie Davis",
      "role": "employee"
    },          // Charlie (Employee)
    "assigned_by": {
      "user_id": "${personnel['user_id3']}",
      "name": "${personnel['user_id3']?['name']}",
      "role": "${personnel['user_id3']?['role']}",
      "assigned_at": "2026-01-23T10:18:00+05:00",
      // head | Admin | SuperAdmin
    },


    "status": "Assigned",
    "completion": const {
      "completed_at": null,
      "images": [],
      "remarks": null
    },

    "approved": null,
    "approved_by": null,
    "approved_at": null,
    "feedback": null,
    "feedback_rating": null,

    "subtickets": const [],
    "last_updated_at": "2026-01-23T10:20:00+05:00",
    "last_updated_by": "user_id5"
  },
};


// Mutable current employee for simple in-memory login simulation
Map<String, dynamic>? currentEmployee;

void loginAsEmployeeById(String id) {
  final raw = personnel[id];
  if (raw != null) {
    currentEmployee = Map<String, dynamic>.from(raw);
    currentEmployee!['id'] = id;
  } else {
    currentEmployee = null;
  }
}

List<Map<String, dynamic>> getAllEmployees() {
  return personnel.entries
      .where((e) => e.value['role'] == 'employee')
      .map((e) => {'id': e.key, ...Map<String, dynamic>.from(e.value)})
      .toList();
}

Map<String, dynamic>? getEmployeeById(String id) {
  final raw = personnel[id];
  return raw == null ? null : {'id': id, ...Map<String, dynamic>.from(raw)};
}

// Existing helpers (kept for compatibility)
Map<String, dynamic>? getDepartment(String id) => departments[id];

Map<String, dynamic>? getUser(String userId) => personnel[userId];

List<Map<String, dynamic>> getUsersInDepartment(String departmentId) {
  return personnel.values
      .where((user) => user['department_id'] == departmentId)
      .map((u) => Map<String, dynamic>.from(u))
      .toList();
}

List<Map<String, dynamic>> getAvailableUsersInDepartment(String departmentId) {
  return getUsersInDepartment(departmentId)
      .where((user) => (user['shifts'] as List?)?.isNotEmpty ?? false)
      .toList();
}
