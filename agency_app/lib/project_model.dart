class Project {
  final int id;
  final String title;
  final String description;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String assignedTo;
  final String budget;
  final String deadline;
  final String priority;
  final int progress; 

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.assignedTo,
    required this.budget,
    required this.deadline,
    required this.priority,
    required this.progress,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? "No details.",
      clientName: json['client_name'],
      clientEmail: json['client_email'] ?? "",
      clientPhone: json['client_phone'] ?? "",
      assignedTo: json['assigned_to'] ?? "Unassigned",
      budget: json['budget'],
      deadline: json['deadline'],
      priority: json['priority'] ?? "Medium",
      progress: json['progress'] ?? 0,
    );
  }
}