class ComplaintLogResponse {
  final bool status;
  final String message;
  final int complaintId;
  final List<String> images;

  ComplaintLogResponse({
    required this.status,
    required this.message,
    required this.complaintId,
    required this.images,
  });

  factory ComplaintLogResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintLogResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      complaintId: json['complaint_id'] ?? 0,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "complaint_id": complaintId,
      "images": images,
    };
  }
}
