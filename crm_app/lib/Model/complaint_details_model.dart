import 'dart:convert';

ComplaintDetailResponse complaintDetailResponseFromJson(String str) =>
    ComplaintDetailResponse.fromJson(json.decode(str));

class ComplaintDetailResponse {
  final bool status;
  final String message;
  final int page_start;
  final int per_page;
  final int count;
  final ComplaintDetail data;

  ComplaintDetailResponse({
    required this.status,
    required this.page_start,
    required this.per_page,
    required this.count,
    required this.message,
    required this.data,
  });

  factory ComplaintDetailResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintDetailResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      page_start: json['page_start'] ?? 0,
      per_page: json['per_page'] ?? 0,
      count: json['count'] ?? 0,
      data: json['data'] != null
          ? ComplaintDetail.fromJson(json['data'])
          : ComplaintDetail.empty(), // ✅ SAFE
    );
  }
}

class ComplaintDetail {
  final String complaintId;
  final String complaint_no;
  final String machine;
  final String machine_no;
  final String machineModel;
  final String hourMeter;
   String status;
  final String workDone;
  final String pendingWork;
  final String complaint;
  final String createdBy;
  final String createdDate;
  final String updatedBy;
  final String updatedDate;
  final String lastupdatedDate;
  final String stateName;
  final String cityName;
  final String machineSrNo;
  final String contact_person_name;
  final String contact_person_number;
  String assignee;
  final String assigned_to;
  final List<String> images;
  final List<RequiredPart> requiredParts;
  final List<Checklist> checklist;
  final PdfModel? pdf;

  ComplaintDetail({
    required this.complaintId,
    required this.complaint_no,
    required this.machine,
    required this.machine_no,
    required this.machineModel,
    required this.hourMeter,
    required this.status,
    required this.workDone,
    required this.pendingWork,
    required this.complaint,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
    required this.contact_person_name,
    required this.contact_person_number,
    required this.lastupdatedDate,
    required this.stateName,
    required this.cityName,
    required this.machineSrNo,
    required this.assignee,
    required this.assigned_to,
    required this.images,
    required this.requiredParts,
    required this.checklist,
    required this.pdf,
  });

  factory ComplaintDetail.empty() {
    return ComplaintDetail(
      complaintId: '',
      complaint_no: '',
      machine: '',
      machine_no: '',
      machineModel: '',
      hourMeter: '',
      status: '',
      workDone: '',
      pendingWork: '',
      complaint: '',
      createdBy: '',
      createdDate: '',
      updatedBy: '',
      updatedDate: '',
      lastupdatedDate: '',
      stateName: '',
      cityName: '',
      machineSrNo: '',
      contact_person_name: '',
      contact_person_number: '',
      assignee: '',
      assigned_to: '',
      images: [],
      requiredParts: [],
      checklist: [],
      pdf: null,
    );
  }

  factory ComplaintDetail.fromJson(Map<String, dynamic> json) {
    return ComplaintDetail(
      complaintId: json['complaint_id'] ?? '',
      complaint_no: json['complaint_no'] ?? '',
      machine: json['machine'] ?? '',
      machine_no: json['machine_no'] ?? '',
      machineModel: json['machine_model'] ?? '',
      hourMeter: json['hour_meter'] ?? '',
      status: json['status'] ?? '',
      workDone: json['work_done'] ?? '',
      pendingWork: json['pending_work'] ?? '',
      complaint: json['complaint'] ?? '',
      createdBy: json['created_by'] ?? '',
      createdDate: json['created_date'] ?? '',
      updatedBy: json['updated_by'] ?? '',
      contact_person_name: json['contact_person_name'] ?? '',
      contact_person_number: json['contact_person_number'] ?? '',
      updatedDate: json['updated_date'] ?? '',
      lastupdatedDate: json['updated_date'] ?? '',
      stateName: json['state_name'] ?? '',
      cityName: json['city_name'] ?? '',
      machineSrNo: json['machine_sr_no'] ?? '',
      assignee: json['assignee'] ?? '',
      assigned_to: json['assigned_to'] ?? '',
      images: (json['images'] as List?)
      ?.map((e) => e.toString())
      .toList() ?? [],
      requiredParts: (json['required_parts'] as List? ?? [])
          .map((e) => RequiredPart.fromJson(e))
          .toList(),
      checklist: (json['checklist'] as List? ?? [])
          .map((e) => Checklist.fromJson(e))
          .toList(),
      pdf: json['pdf'] != null ? PdfModel.fromJson(json['pdf']) : null,

    );
  }



  Map<String, dynamic> toJson() {
    return {
      'complaint_id': complaintId,
      'complaint': complaint, // ✅ ADD THIS
      'complaint_no': complaint_no,
      'machine': machine,
      'machine_no': machine_no,
      'machine_model': machineModel,
      'hour_meter': hourMeter,
      'status': status,
      'work_done': workDone,
      'pending_work': pendingWork,
      'created_by': createdBy,
      'created_date': createdDate,
      'updated_by': updatedBy,
      'contact_person_name': contact_person_name,
      'contact_person_number': contact_person_number,
      'updated_date': updatedDate,
      'lastupdatedDate': lastupdatedDate,
      'state_name': stateName,
      'city_name': cityName,
      'assignee': assignee,
      'assigned_to': assigned_to,

      // 🔥 IMPORTANT ADD THIS
      "required_parts":
      requiredParts.map((e) => e.toJson()).toList(),

      // 🔥 THIS WAS MISSING
      "checklist":
      checklist.map((e) => e.toJson()).toList(),

      // 🔥 PDF (optional)
      if (pdf != null)
        'pdf': {
          'complaintid': pdf!.complaintId,
          'pdf': pdf!.pdf,
          'created_at': pdf!.createdAt,
        },
    };
  }
}

class PdfModel {
  final String complaintId;
  final String pdf;
  final String createdAt;

  PdfModel({
    required this.complaintId,
    required this.pdf,
    required this.createdAt,
  });

  factory PdfModel.fromJson(Map<String, dynamic> json) {
    return PdfModel(
      complaintId: json['complaintid'] ?? '',
      pdf: json['pdf'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class RequiredPart {
  final String partRowId;
  final String partId;
  final String partName;
  final String quantity;
  final String addedDateTime;

  RequiredPart({
    required this.partRowId,
    required this.partId,
    required this.partName,
    required this.quantity,
    required this.addedDateTime,
  });

  factory RequiredPart.fromJson(Map<String, dynamic> json) {
    return RequiredPart(
      partRowId: json['part_row_id'] ?? '',
      partId: json['PartId'] ?? '',
      partName: json['part_name'] ?? '',
      quantity: json['Quantity'] ?? '',
      addedDateTime: json['AddedDateTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "part_row_id": partRowId,
      "PartId": partId,
      "part_name": partName,
      "Quantity": quantity,
      "AddedDateTime": addedDateTime,
    };
  }
}

class Checklist {
  final String id;
  final String complaintId;

  final String engineStarting;
  final String hourMeter;
  final String keySwitch;
  final String emergencyGround;
  final String emergencyPlatform;
  final String batteryTerminal;
  final String horn;
  final String light;
  final String wheelRimNut;
  final String hydraulicCylinderLeakage;
  final String wireHardness;
  final String brakeOperateNormally;
  final String togglesSwitchNormal;

  final String engineOilStatus;
  final String engineOilQty;

  final String hydraulicOilStatus;
  final String hydraulicOilQty;

  final String fuelFeedPump;
  final String functionFromBasket;
  final String functionFromGround;

  final String joyStick;
  final String hydraulicPipeLeakage;

  final String machineFreeBypass;
  final String machineMaintainedByOpt;

  final String machineServiceDueStatus;
  final String machineServiceDueDate;

  final String createdAt;

  Checklist({
    required this.id,
    required this.complaintId,
    required this.engineStarting,
    required this.hourMeter,
    required this.keySwitch,
    required this.emergencyGround,
    required this.emergencyPlatform,
    required this.batteryTerminal,
    required this.horn,
    required this.light,
    required this.wheelRimNut,
    required this.hydraulicCylinderLeakage,
    required this.wireHardness,
    required this.brakeOperateNormally,
    required this.togglesSwitchNormal,
    required this.engineOilStatus,
    required this.engineOilQty,
    required this.hydraulicOilStatus,
    required this.hydraulicOilQty,
    required this.fuelFeedPump,
    required this.functionFromBasket,
    required this.functionFromGround,
    required this.joyStick,
    required this.hydraulicPipeLeakage,
    required this.machineFreeBypass,
    required this.machineMaintainedByOpt,
    required this.machineServiceDueStatus,
    required this.machineServiceDueDate,
    required this.createdAt,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      id: json['id'] ?? '',
      complaintId: json['complaint_id'] ?? '',
      engineStarting: json['engine_starting'] ?? '',
      hourMeter: json['hour_meter'] ?? '',
      keySwitch: json['key_switch'] ?? '',
      emergencyGround: json['emergency_ground'] ?? '',
      emergencyPlatform: json['emergency_platform'] ?? '',
      batteryTerminal: json['battery_terminal'] ?? '',
      horn: json['horn'] ?? '',
      light: json['light'] ?? '',
      wheelRimNut: json['wheel_rim_nut'] ?? '',
      hydraulicCylinderLeakage:
      json['hydraulic_cylinder_leakage'] ?? '',
      wireHardness: json['wire_hardness'] ?? '',
      brakeOperateNormally:
      json['brake_operate_normally'] ?? '',
      togglesSwitchNormal:
      json['toggles_switch_normal'] ?? '',
      engineOilStatus: json['engine_oil_status'] ?? '',
      engineOilQty: (json['engine_oil_qty'] ?? '').toString().trim(),
      hydraulicOilStatus: json['hydraulic_oil_status'] ?? '',
      hydraulicOilQty: (json['hydraulic_oil_qty'] ?? '').toString().trim(),
      fuelFeedPump: (json['fuel_feed_pump'] ?? '').toString().trim(),
      functionFromBasket: json['function_from_basket'] ?? '',
      functionFromGround: json['function_from_ground'] ?? '',
      joyStick: json['joy_stick'] ?? '',
      hydraulicPipeLeakage:
      json['hydraulic_pipe_leakage'] ?? '',
      machineFreeBypass: json['machine_free_bypass'] ?? '',
      machineMaintainedByOpt:
      json['machine_maintained_by_opt'] ?? '',
      machineServiceDueStatus:
      json['machine_service_due_status'] ?? '',
      machineServiceDueDate:
      json['machine_service_due_date'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "complaint_id": complaintId,
      "engine_starting": engineStarting,
      "hour_meter": hourMeter,
      "key_switch": keySwitch,
      "emergency_ground": emergencyGround,
      "emergency_platform": emergencyPlatform,
      "battery_terminal": batteryTerminal,
      "horn": horn,
      "light": light,
      "wheel_rim_nut": wheelRimNut,
      "hydraulic_cylinder_leakage": hydraulicCylinderLeakage,
      "wire_hardness": wireHardness,
      "brake_operate_normally": brakeOperateNormally,
      "toggles_switch_normal": togglesSwitchNormal,
      "engine_oil_status": engineOilStatus,
      "engine_oil_qty": engineOilQty,
      "hydraulic_oil_status": hydraulicOilStatus,
      "hydraulic_oil_qty": hydraulicOilQty,
      "fuel_feed_pump": fuelFeedPump,
      "function_from_basket": functionFromBasket,
      "function_from_ground": functionFromGround,
      "joy_stick": joyStick,
      "hydraulic_pipe_leakage": hydraulicPipeLeakage,
      "machine_free_bypass": machineFreeBypass,
      "machine_maintained_by_opt": machineMaintainedByOpt,
      "machine_service_due_status": machineServiceDueStatus,
      "machine_service_due_date": machineServiceDueDate,
      "created_at": createdAt,
    };
  }
}