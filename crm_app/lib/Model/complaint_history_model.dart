class ComplaintHistoryResponse {
  final bool status;
  final String message;
  final List<ComplaintHistoryModel> data;

  ComplaintHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ComplaintHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintHistoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ComplaintHistoryModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}


// class ComplaintHistory {
//   final String id;
//   final String complaintId;
//   final String remarks;
//   final String addedDateTime;
//   final String status;
//   final String userId;

//   ComplaintHistory({
//     required this.id,
//     required this.complaintId,
//     required this.remarks,
//     required this.addedDateTime,
//     required this.status,
//     required this.userId,
//   });
//
//   factory ComplaintHistory.fromJson(Map<String, dynamic> json) {
//     return ComplaintHistory(
//       id: json['Id'] ?? '',
//       complaintId: json['ComplaintId'] ?? '',
//       remarks: json['ComplaintRemarks'] ?? '',
//       addedDateTime: json['AddedDateTime'] ?? '',
//       status: json['ComplaintStatus'] ?? '',
//       userId: json['UserId'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "Id": id,
//       "ComplaintId": complaintId,
//       "ComplaintRemarks": remarks,
//       "AddedDateTime": addedDateTime,
//       "ComplaintStatus": status,
//       "UserId": userId,
//     };
//   }
// }

class ComplaintHistoryModel {
  final String id;
  final String complaintId;
  final String remarks;
  final String addedDateTime;
  final String status;
  final String userId;

  ComplaintHistoryModel({
    required this.id,
    required this.complaintId,
    required this.remarks,
    required this.addedDateTime,
    required this.status,
    required this.userId,
  });

  factory ComplaintHistoryModel.fromJson(Map<String, dynamic> json) {
    return ComplaintHistoryModel(
      id: json['Id'] ?? '',
      complaintId: json['ComplaintId'] ?? '',
      remarks: json['ComplaintRemarks'] ?? '',
      addedDateTime: json['AddedDateTime'] ?? '',
      status: json['ComplaintStatus'] ?? '',
      userId: json['UserId'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "Id": id,
      "ComplaintId": complaintId,
      "ComplaintRemarks": remarks,
      "AddedDateTime": addedDateTime,
      "ComplaintStatus": status,
      "UserId": userId,
    };
  }
}

