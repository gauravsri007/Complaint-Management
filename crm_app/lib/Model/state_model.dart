class StatesResponse {
  final bool status;
  final String message;
  final List<StateModel> data;

  StatesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StatesResponse.fromJson(Map<String, dynamic> json) {
    return StatesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => StateModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class StateModel {
  final String id;
  final String
  name;

  StateModel({
    required this.id,
    required this.name,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] ?? '',
      name: json['state_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'state_name': name,
  };
}
