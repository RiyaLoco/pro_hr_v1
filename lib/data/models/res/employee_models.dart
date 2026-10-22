/// Employee details linked to the authenticated account.
class Employee {
  final int? id;
  final String? code;
  final String? name;
  final String? email;
  final String? phone;
  final String? position;
  final String? department;
  final String? joinDate;
  final String? avatarUrl;

  const Employee({
    this.id,
    this.code,
    this.name,
    this.email,
    this.phone,
    this.position,
    this.department,
    this.joinDate,
    this.avatarUrl,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    String? text(dynamic value) {
      if (value is! String && value is! num) return null;
      final result = value.toString().trim();
      return result.isEmpty ? null : result;
    }

    String? label(dynamic value) =>
        value is Map ? text(value['name'] ?? value['title']) : text(value);

    final fullName = [
      text(json['f_name'] ?? json['first_name']),
      text(json['l_name'] ?? json['last_name']),
    ].whereType<String>().join(' ');
    return Employee(
      id: int.tryParse('${json['id']}'),
      code: text(json['employee_code'] ?? json['code']),
      name: text(json['full_name']) ?? text(json['name']) ?? text(fullName),
      email: text(json['email']),
      phone: text(json['phone'] ?? json['phone_number']),
      position: label(
        json['position'] ?? json['designation'] ?? json['job_title'],
      ),
      department: label(json['department']),
      joinDate: text(
        json['hire_date'] ??
            json['join_date'] ??
            json['joining_date'] ??
            json['date_of_joining'],
      ),
      avatarUrl: text(json['avatar_url'] ?? json['avatar']),
    );
  }
}
