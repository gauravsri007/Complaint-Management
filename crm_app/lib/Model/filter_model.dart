class ComplaintAssignmentResponse {
  final bool status;
  final int count;
  final List<ComplaintAssignment> data;

  ComplaintAssignmentResponse({
    required this.status,
    required this.count,
    required this.data,
  });

  factory ComplaintAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintAssignmentResponse(
      status: json['status'] ?? false,
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      data: json['data'] != null
          ? List<ComplaintAssignment>.from(
        (json['data'] as List)
            .map((e) => ComplaintAssignment.fromJson(e)),
      )
          : [],
    );
  }
}

class ComplaintAssignment {
  final String id;
  final String complaintNo;
  final String machineModel;
  final String status;
  final String createdDtm;
  final String serviceEngineerId;

  ComplaintAssignment({
    required this.id,
    required this.complaintNo,
    required this.machineModel,
    required this.status,
    required this.createdDtm,
    required this.serviceEngineerId,
  });

  factory ComplaintAssignment.fromJson(Map<String, dynamic> json) {
    return ComplaintAssignment(
      id: json['id']?.toString() ?? '',
      complaintNo: json['complaint_no']?.toString() ?? '',
      machineModel: json['machine_model']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdDtm: json['createdDtm']?.toString() ?? '',
      serviceEngineerId: json['service_engineer_id']?.toString() ?? '',
    );
  }
}
