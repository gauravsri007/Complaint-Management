class MachineNumberResponse {
  final bool status;
  final String message;
  final List<MachineNumber> data;

  MachineNumberResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MachineNumberResponse.fromJson(Map<String, dynamic> json) {
    return MachineNumberResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MachineNumber.fromJson(e as Map<String, dynamic>))
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

class MachineNumber {
  final String id;
  final String machineModel;
  final String machineDisplay;

  MachineNumber({
    required this.id,
    required this.machineModel,
    required this.machineDisplay,
  });

  factory MachineNumber.fromJson(
      Map<String, dynamic> json,
      ) {
    return MachineNumber(
      id: json['id']?.toString() ?? '',
      machineModel:
      json['machine_model']?.toString() ?? '',
      machineDisplay:
      json['machine_display']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'machine_model': machineModel,
      'machine_display': machineDisplay,
    };
  }

  @override
  String toString() {
    return machineDisplay.isNotEmpty
        ? machineDisplay
        : "N/A";
  }
}