
import 'package:crm_app/Model/complaint_details_model.dart';

class ComplaintsResponse {
  final bool status;
  final String message;
  final int page_start;
  final int per_page;
  final int count;
  final List<ComplaintDetail> data;

  ComplaintsResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.page_start,
    required this.per_page,
    required this.count,
  });

  factory ComplaintsResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      page_start: json['page_start'],
      per_page: json['per_page'],
      count: json['count'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ComplaintDetail.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
