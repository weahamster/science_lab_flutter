class Course {
  final String id;
  final String title;
  final String? className;
  final String? description;
  final String? teacherId;
  final String? schoolId;
  final bool isActive;
  final DateTime createdAt;
  
  Course({
    required this.id,
    required this.title,
    this.className,
    this.description,
    this.teacherId,
    this.schoolId,
    required this.isActive,
    required this.createdAt,
  });
  
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      className: json['class'],
      description: json['description'],
      teacherId: json['teacher_id'],
      schoolId: json['school_id'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}