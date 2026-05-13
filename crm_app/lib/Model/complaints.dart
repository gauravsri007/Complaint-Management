
import 'package:crm_app/Model/complaint_details_model.dart';

class ComplaintsResponse {
  final bool status;
  final String message;
  final int pageStart;
  final int perPage;
  final int count;
  final List<ComplaintDetail> data;

  ComplaintsResponse({
    required this.status,
    required this.message,
    required this.pageStart,
    required this.perPage,
    required this.count,
    required this.data,
  });

  factory ComplaintsResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      pageStart: json['page_start'] ?? 0,
      perPage: json['per_page'] ?? 0,
      count: json['count'] ?? 0,

      data: json['data'] is List
          ? (json['data'] as List)
          .where((e) {
        return e is Map<String, dynamic>;
      })
          .map((e) => ComplaintDetail.fromJson(
        e as Map<String, dynamic>,
      ))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'page_start': pageStart,
      'per_page': perPage,
      'count': count,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'ComplaintsResponse{status: $status, message: $message, pageStart: $pageStart, perPage: $perPage, count: $count, data: $data}';
  }
}
  class ComplaintDetail {
  final String complaintId;
  final String complaintNo;
  final String machineNo;
  final String machineModel;
  final String hourMeter;
  final String complaint;
  final String status;
  final String? workDone;
  final String? pendingWork;
  final String? contactPersonName;
  final String? contactPersonNumber;
  final String createdBy;
  final String createdDate;
  final String updatedBy;
  final String updatedDate;
  final String stateName;
  final String cityName;
  String assignee;
  final String assignedTo;
  final String lastUpdatedDate;
  final String? pdf;
  final String? pdfCreatedAt;

  ComplaintDetail({
  required this.complaintId,
  required this.complaintNo,
  required this.machineNo,
  required this.machineModel,
  required this.hourMeter,
  required this.complaint,
  required this.status,
  this.workDone,
  this.pendingWork,
  this.contactPersonName,
  this.contactPersonNumber,
  required this.createdBy,
  required this.createdDate,
  required this.updatedBy,
  required this.updatedDate,
  required this.stateName,
  required this.cityName,
  required this.assignee,
  required this.assignedTo,
  required this.lastUpdatedDate,
  this.pdf,
  this.pdfCreatedAt,
  });

  factory ComplaintDetail.fromJson(Map<String, dynamic> json) {
  return ComplaintDetail(
  complaintId: json['complaint_id']?.toString() ?? '',
  complaintNo: json['complaint_no'] ?? '',
  machineNo: json['machine_no'] ?? '',
  machineModel: json['machine_model'] ?? '',
  hourMeter: json['hour_meter'] ?? '',
  complaint: json['complaint'] ?? '',
  status: json['status'] ?? '',
  workDone: json['work_done'],
  pendingWork: json['pending_work'],
  contactPersonName: json['contact_person_name'],
  contactPersonNumber: json['contact_person_number'],
  createdBy: json['created_by'] ?? '',
  createdDate: json['created_date'] ?? '',
  updatedBy: json['updated_by'] ?? '',
  updatedDate: json['updated_date'] ?? '',
  stateName: json['state_name'] ?? '',
  cityName: json['city_name'] ?? '',
  assignee: json['assignee'] ?? '',
  assignedTo: json['assigned_to'] ?? '',
  lastUpdatedDate: json['last_updated_date'] ?? '',
  pdf: json['pdf'],
  pdfCreatedAt: json['pdf_created_at'],
  );
  }

  Map<String, dynamic> toJson() {
  return {
  'complaint_id': complaintId,
  'complaint_no': complaintNo,
  'machine_no': machineNo,
  'machine_model': machineModel,
  'hour_meter': hourMeter,
  'complaint': complaint,
  'status': status,
  'work_done': workDone,
  'pending_work': pendingWork,
  'contact_person_name': contactPersonName,
  'contact_person_number': contactPersonNumber,
  'created_by': createdBy,
  'created_date': createdDate,
  'updated_by': updatedBy,
  'updated_date': updatedDate,
  'state_name': stateName,
  'city_name': cityName,
  'assignee': assignee,
  'assigned_to': assignedTo,
  'last_updated_date': lastUpdatedDate,
  'pdf': pdf,
  'pdf_created_at': pdfCreatedAt,
  };
  }
  }

