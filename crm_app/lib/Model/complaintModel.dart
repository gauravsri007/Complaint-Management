// --- Data Model (from above) ---
import '../utilities/enums.dart';

class Complaint {
  final String id;
  final String machineNumber;
  final String model;
  final String date;
  final String place;
  final String machineName;
  final String description;
  final String reportedBy;
  ComplaintStatus status;
  String assignedTo; // Mutable for reassignment
  // List<ComplaintHistory> history; // ⬅️ add this


  Complaint({
    required this.id,
    required this.machineNumber,
    required this.model,
    required this.date,
    required this.place,
    required this.machineName,
    required this.description,
    required this.reportedBy,
    required this.status,
    required this.assignedTo,
    // this.history = const [],
  });

  bool get isAssigned => assignedTo != null;
}

