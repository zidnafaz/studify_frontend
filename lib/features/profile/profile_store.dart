class ProfileData {
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool assignmentNotif;
  final bool reminderNotif;
  final bool classUpdateNotif;

  const ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.assignmentNotif,
    required this.reminderNotif,
    required this.classUpdateNotif,
  });

  factory ProfileData.initial() {
    return const ProfileData(
      name: 'Ayla Putri',
      email: 'ayla.putri@studify.id',
      phone: '+62 812-0000-0000',
      role: 'Student',
      assignmentNotif: true,
      reminderNotif: true,
      classUpdateNotif: true,
    );
  }

  factory ProfileData.empty() {
    return const ProfileData(
      name: '',
      email: '',
      phone: '',
      role: '',
      assignmentNotif: false,
      reminderNotif: false,
      classUpdateNotif: false,
    );
  }

  ProfileData copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? assignmentNotif,
    bool? reminderNotif,
    bool? classUpdateNotif,
  }) {
    return ProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      assignmentNotif: assignmentNotif ?? this.assignmentNotif,
      reminderNotif: reminderNotif ?? this.reminderNotif,
      classUpdateNotif: classUpdateNotif ?? this.classUpdateNotif,
    );
  }

  bool get isEmpty =>
      name.isEmpty && email.isEmpty && phone.isEmpty && role.isEmpty;
}

class ProfileStore {
  ProfileStore._();

  static final ProfileStore instance = ProfileStore._();

  ProfileData _data = ProfileData.initial();

  ProfileData get data => _data;

  void save(ProfileData data) {
    _data = data;
  }

  void reset() {
    _data = ProfileData.empty();
  }
}


