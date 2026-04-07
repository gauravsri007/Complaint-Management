class SimpleResponse {
  final bool status;
  final String message;

  SimpleResponse({
    required this.status,
    required this.message,
  });

  factory SimpleResponse.fromJson(Map<String, dynamic> json) {
    return SimpleResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}

class RequiredPartsResponse {
  final bool status;
  final String data;

  RequiredPartsResponse({
    required this.status,
    required this.data,
  });

  factory RequiredPartsResponse.fromJson(Map<String, dynamic> json) {
    return RequiredPartsResponse(
      status: json['status'] ?? false,
      data: json['data'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data,
    };
  }
}