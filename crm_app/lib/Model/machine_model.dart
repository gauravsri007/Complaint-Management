class MachineModelResponse {
  final bool status;
  final String message;
  final List<MachineModelData> data;

  MachineModelResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MachineModelResponse.fromJson(Map<String, dynamic> json) {
    return MachineModelResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MachineModelData.fromJson(e))
          .toList()
          ?? [],
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

class MachineModelData {
  final String id;
  final String machineSrNo;
  final String machineNo;
  final String machineModel;

  MachineModelData({
    required this.id,
    required this.machineSrNo,
    required this.machineNo,
    required this.machineModel,
  });

  factory MachineModelData.fromJson(Map<String, dynamic> json) {
    return MachineModelData(
      id: json['id'] ?? '',
      machineSrNo: json['machine_sr_no'] ?? '',
      machineNo: json['machine_no'] ?? '',
      machineModel: json['machine_model'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'machine_sr_no': machineSrNo,
      'machine_no': machineNo,
      'machine_model': machineModel,
    };
  }
}
