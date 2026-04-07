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
  final String machineNo;
  final String machineModel;
  final String machineSrNo;

  MachineNumber({
    required this.id,
    required this.machineNo,
    required this.machineModel,
    required this.machineSrNo,
  });

  factory MachineNumber.fromJson(Map<String, dynamic> json) {
    return MachineNumber(
      id: (json['id'] ?? '').toString(),
      machineNo: (json['machine_no'] ?? '').toString(),
      machineModel: (json['machine_model'] ?? '').toString(),
      machineSrNo: (json['machine_sr_no'] ?? '').toString(),
    );
  }



  Map<String, dynamic> toJson() => {
    'id': id,
    'machine_no': machineNo,
    'machine_model': machineModel,
    'machine_sr_no': machineSrNo,
  };

  @override
  String toString() {
    return 'MachineNumber(id: $id, machineNo: $machineNo, machineModel: $machineModel, machineSrNo: $machineSrNo)';
  }

  // @override
  // String toString() => machineNo;
}
