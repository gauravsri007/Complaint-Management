import 'package:crm_app/API/auth_api_service.dart';
import 'package:crm_app/Model/city_model.dart';
import 'package:crm_app/Model/complaintModel.dart';
import 'package:crm_app/Model/complaint_details_model.dart';
import 'package:crm_app/Model/complaints.dart';
import 'package:crm_app/Model/employee_list_model.dart';
import 'package:crm_app/Model/machine_model.dart';
import 'package:crm_app/Model/machine_number_model.dart';
import 'package:crm_app/Model/state_model.dart';
import 'package:crm_app/utilities/user_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/utilities/enums.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppData {
  static AppData shared = AppData();
  static Color primaryBlue = Color(0xFF1D648B);
  static Color darkText = Color(0xFF333333);
  static Color unassignedRed = Color(0xFFD32F2F); // high visibility
  static String _username = "";
  static UserRole? _userRole;
  static List<ComplaintDetail> complaintList = [];
  static List<StateModel> states = [];
  static List<CityModel> cities = [];
  static List<MachineModelData> machine_models = [];
  static List<MachineNumber> machine_numbers = [];
  static List<Employee> employee_list = [];
  static int assigned_complaints_count = 0;
  static int unassigned_complaint_count = 0;
  static int resolved_complaint_count = 0;

  String formatDate(String dateTime) {
    final dt = DateTime.parse(dateTime);
    return DateFormat('dd/MM/yyyy hh:mm a').format(dt);
  }

}
