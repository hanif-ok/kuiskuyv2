class ClassModel {
  final String id;
  final String name;
  final String teacherId;
  final String joinCode;
  final String password;
  final List<String> studentIds;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.joinCode,
    required this.password,
    required this.studentIds,
    required this.createdAt,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map, String id) {
    return ClassModel(
      id: id,
      name: map['name'] ?? '',
      teacherId: map['teacherId'] ?? '',
      joinCode: map['joinCode'] ?? '',
      password: map['password'] ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teacherId': teacherId,
      'joinCode': joinCode,
      'password': password,
      'studentIds': studentIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
