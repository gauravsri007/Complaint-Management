
import 'dart:convert';
import 'package:crm_app/Model/add_complaint_model.dart';
import 'package:crm_app/Model/city_model.dart';
import 'package:crm_app/Model/complaint_assign_model.dart';
import 'package:crm_app/Model/complaint_details_model.dart';
import 'package:crm_app/Model/complaint_history_model.dart';
import 'package:crm_app/Model/complaints.dart';
import 'package:crm_app/Model/employee_list_model.dart';
import 'package:crm_app/Model/common_model.dart';
import 'package:crm_app/Model/get_parts_model.dart';
import 'package:crm_app/Model/machine_model.dart';
import 'package:crm_app/Model/machine_number_model.dart';
import 'package:crm_app/Model/state_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/complaint_count_model.dart';
import '../Model/login_models.dart';

class AuthApiService {
  late Dio dio;
  String token = '';
  AuthApiService(String baseUrl) {
    _init(baseUrl);
  }

  Future<void> _init(String apiUrl) async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    dio = Dio(
      BaseOptions(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Accept": "*/*",
          "Connection": "keep-alive",
          "Accept-Encoding": "gzip, deflate, br",
          "User-Agent": "FlutterApp/1.0",
          "Authorization": "Bearer $token", // Add bearer token
        },
      ),
    );
  }

    late final Dio _dio = Dio(
      BaseOptions(
        baseUrl:
        'https://dashboard.reachinternational.co.in/development/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': '*/*',
          'Connection': 'keep-alive',
          'Accept-Encoding': 'gzip, deflate, br',
          'User-Agent': 'FlutterApp/1.0',
          "Authorization": "Bearer $token", // Add bearer token
        },
      ),
    );

    Future<LoginResponse> login({
      required String email,
      required String password,
    }) async {
      _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
      _dio.transformer = BackgroundTransformer();
      try {
        final formData = FormData.fromMap({
          'email': email,
          'password': password,
        });

        final response = await _dio.post(
          '/Users/login',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            responseType: ResponseType.plain, // <— force bytes
            validateStatus: (_) => true, // allow 200/400/500 printing
          ),
        );
        print("STATUS: ${response.statusCode}");
        print("RAW: ${response.data}");
        // Convert bytes (gzip/deflate/br) → text
        final raw = response.data.toString().trim();

        if (raw.isEmpty) {
          throw Exception("Empty response");
        }

        final start = raw.indexOf('{');

        if (start == -1) {
          throw Exception("Response not JSON: $raw");
        }

        final jsonBody = raw.substring(start);
        final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
        return LoginResponse.fromJson(jsonMap);
      } catch (e) {
        print("Login exception: $e");
        rethrow;
      }
    }


    Future<ComplaintsResponse> complaints({
      required String user_id,
      required String role_id,
      required int page_start,
      required int type,

    }) async {
      _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
      _dio.transformer = BackgroundTransformer();
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      try {
        final formData = FormData.fromMap({
          'userid': user_id,
          'role_id': role_id,
          'page_start': page_start,
          'per_page':10,
          'assigned':type
        });
        print('Page Start -> $page_start');
        print("formData: $formData)");
        final response = await _dio.post(
          '/complaint_list',
          data: formData,
          options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
            contentType: 'multipart/form-data',
            responseType: ResponseType.plain, // <— force bytes
            validateStatus: (_) => true, // allow 200/400/500 printing
          ),
        );
        print("STATUS: ${response.statusCode}");
        // print("RAW: ${response.data}");
        // Convert bytes (gzip/deflate/br) → text
        final raw = response.data.toString().trim();

        if (raw.isEmpty) {
          throw Exception("Empty response");
        }

        final start = raw.indexOf('{');

        if (start == -1) {
          throw Exception("Response not JSON: $raw");
        }

        final jsonBody = raw.substring(start);
        final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
        return ComplaintsResponse.fromJson(jsonMap);
      } catch (e) {
        print("Login exception: $e");
        rethrow;
      }
    }


  Future<StatesResponse> fetchStates() async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    try {
      final response = await _dio.get(
        '/get_states',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain, // <— force bytes
          validateStatus: (_) => true, // allow 200/400/500 printing
        ),
      );
      print("STATUS: ${response.statusCode}");
      print("RAW: ${response.data}");
      // Convert bytes (gzip/deflate/br) → text
      final raw = response.data.toString().trim();

      if (raw.isEmpty) {
        throw Exception("Empty response");
      }

      final start = raw.indexOf('{');

      if (start == -1) {
        throw Exception("Response not JSON: $raw");
      }

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
      return StatesResponse.fromJson(jsonMap);
    } catch (e) {
      print("StatesResponse exception: $e");
      rethrow;
    }
  }//State

  Future<PartsListResponse> fetchPartslist() async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    try {
      final response = await _dio.get(
        '/partslist',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain, // <— force bytes
          validateStatus: (_) => true, // allow 200/400/500 printing
        ),
      );
      // Convert bytes (gzip/deflate/br) → text
      final raw = response.data.toString().trim();

      if (raw.isEmpty) {
        throw Exception("Empty response");
      }

      final start = raw.indexOf('{');

      if (start == -1) {
        throw Exception("Response not JSON: $raw");
      }

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
      return PartsListResponse.fromJson(jsonMap);
    } catch (e) {
      print("PartsListResponse exception: $e");
      rethrow;
    }
  }//State

  Future<MachineNumberResponse> fetchMachineNumber() async {
    try {
      _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
      _dio.transformer = BackgroundTransformer();
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      final response = await _dio.get(
        '/machine_number',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain, // <— force bytes
          validateStatus: (_) => true, // allow 200/400/500 printing
        ),
      );
      print("token $token");
      print("STATUS: ${response.statusCode}");
      print("RAW: ${response.data}");
      // Convert bytes (gzip/deflate/br) → text
      final raw = response.data.toString().trim();

      if (raw.isEmpty) {
        throw Exception("Empty response");
      }

      final start = raw.indexOf('{');

      if (start == -1) {
        throw Exception("Response not JSON: $raw");
      }

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
      return MachineNumberResponse.fromJson(jsonMap);
    } catch (e) {
      print("MachineNumberResponse exception: $e");
      rethrow;
    }
  }//fetchMachineNumber

  Future<CityResponse> fetchCities(
      {
        required String state_id,
      }
      ) async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    try {
      final formData = FormData.fromMap({
        'state_id': state_id,
      });
      final response = await _dio.post(
        '/get_city',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain, // <— force bytes
          validateStatus: (_) => true, // allow 200/400/500 printing
        ),
      );
      final raw = response.data.toString().trim();

      if (raw.isEmpty) {
        throw Exception("Empty response");
      }

      final start = raw.indexOf('{');

      if (start == -1) {
        throw Exception("Response not JSON: $raw");
      }

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
      return CityResponse.fromJson(jsonMap);
    } catch (e) {
      print("CityResponse exception: $e");
      rethrow;
    }
  }//City

  Future<MachineModelResponse> fetchMachineModel(
      {
        required String machine_id,
      }
      ) async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    try {
      final formData = FormData.fromMap({
        'machine_id': machine_id,
      });
      final response = await _dio.post(
        '/machine_model',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain, // <— force bytes
          validateStatus: (_) => true, // allow 200/400/500 printing
        ),
      );
      print("STATUS: ${response.statusCode}");
      print("RAW: ${response.data}");
      final raw = response.data.toString().trim();

      if (raw.isEmpty) {
        throw Exception("Empty response");
      }

      final start = raw.indexOf('{');

      if (start == -1) {
        throw Exception("Response not JSON: $raw");
      }

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
      return MachineModelResponse.fromJson(jsonMap);
    } catch (e) {
      print("MachineModelResponse exception: $e");
      rethrow;
    }
  }//Machines

  Future<SimpleResponse> logout({
    required String user_id,
  }) async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();

    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    try {
      debugPrint('user_id: $user_id');

      final formData = FormData.fromMap({
        'userid': user_id,
      });

      final response = await _dio.post(
        '/logout',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );

      final raw = response.data.toString().trim();

      // debugPrint('statusMessage: ${response.statusMessage}');
      // debugPrint('RAW RESPONSE: $raw');
      if (raw.isEmpty) {
        throw Exception("Empty response");
      }

      final start = raw.indexOf('{');
      if (start == -1) {
        throw Exception("Response not JSON: $raw");
      }

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);

      return SimpleResponse.fromJson(jsonMap); // ✅ correct

    } catch (e) {
      debugPrint("logout exception: $e");
      rethrow;
    }
  }


  Future<SimpleResponse> complaintAcknowledge(
      {
        required String complaint_id,
        required String assigned_to,
      }
      ) async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    try {
      final formData = FormData.fromMap({
        'complaint_id': complaint_id,
        'assigned_to': assigned_to,
      });
      final response = await _dio.post(
        '/acknowledge',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain, // <— force bytes
          validateStatus: (_) => true, // allow 200/400/500 printing
        ),
      );
      final raw = response.data.toString().trim();
      if (raw.isEmpty) {
        throw Exception("Empty response");
      }
      final start = raw.indexOf('{');
      if (start == -1) {
        throw Exception("Response not JSON: $raw");
      }

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
      return SimpleResponse.fromJson(jsonMap);
    } catch (e) {
      print("MachineModelResponse exception: $e");
      rethrow;
    }
  }//Logout

  Future<ComplaintDetailResponse> getComplaintDetails(
      {
        required String complaint_id,
      }
      ) async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    try {
      final formData = FormData.fromMap({
        'complaint_id': complaint_id,
      });
      final response = await _dio.post(
        '/complaint_details',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain, // <— force bytes
          validateStatus: (_) => true, // allow 200/400/500 printing
        ),
      );
      final raw = response.data.toString().trim();
      // print("ComplaintDetailResponse -> RAW RESPONSE: $raw");
      if (raw.isEmpty) {
        throw Exception("Empty response");
      }
      final start = raw.indexOf('{');
      if (start == -1) {
        throw Exception("Response not JSON: $raw");
      }

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
      return ComplaintDetailResponse.fromJson(jsonMap);
    } catch (e) {
      print("ComplaintDetailResponse exception: $e");
      rethrow;
    }
  }//Logout

  Future<EmployeeResponse> getEmployeeList(
      {
        required String role_name,
      }
      ) async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    try {
      final formData = FormData.fromMap({
        'role_name': role_name,
      });
      final response = await _dio.post(
        '/employee_list',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain, // <— force bytes
          validateStatus: (_) => true, // allow 200/400/500 printing
        ),
      );
      final raw = response.data.toString().trim();
      if (raw.isEmpty) {
        throw Exception("Empty response");
      }
      final start = raw.indexOf('{');
      if (start == -1) {
        throw Exception("Response not JSON: $raw");
      }

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
      return EmployeeResponse.fromJson(jsonMap);
    } catch (e) {
      print("EmployeeResponse exception: $e");
      rethrow;
    }
  }//Logout

  Future<ComplaintCountResponse> getComplaintCountAPI(
      {
        required String user_id,
        required String role_id,
      }
      ) async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    try {
      final formData = FormData.fromMap({
        'user_id': user_id,
        'role_id': role_id,
      });
      final response = await _dio.post(
        '/complaintcount',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain, // <— force bytes
          validateStatus: (_) => true, // allow 200/400/500 printing
        ),
      );
      final raw = response.data.toString().trim();
      if (raw.isEmpty) {
        throw Exception("Empty response");
      }
      final start = raw.indexOf('{');
      if (start == -1) {
        throw Exception("Response not JSON: $raw");
      }

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
      return ComplaintCountResponse.fromJson(jsonMap);
    } catch (e) {
      print("ComplaintCountResponse exception: $e");
      rethrow;
    }
  }//Logout

  Future<ComplaintHistoryResponse> getComplaintHistryApi(
      {
        required String complaint_id,
      }
      ) async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    try {
      final formData = FormData.fromMap({
        'complaint_id': complaint_id,
      });
      final response = await _dio.post(
        '/fetchcomplaint',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain, // <— force bytes
          validateStatus: (_) => true, // allow 200/400/500 printing
        ),
      );
      final raw = response.data.toString().trim();
      if (raw.isEmpty) {
        throw Exception("Empty response");
      }
      final start = raw.indexOf('{');
      if (start == -1) {
        throw Exception("Response not JSON: $raw");
      }

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);
      return ComplaintHistoryResponse.fromJson(jsonMap);
    } catch (e) {
      print("ComplaintHistoryResponse exception: $e");
      rethrow;
    }
  }//Logout

  Future<ComplaintLogResponse> addComplaint({
    required String machine_id,
    required String machine_model,
    required String hour_meter,
    required String contact_person_name,
    required String contact_person_number,
    required String complaint,
    required String state,
    required String city_id,
    required String pending_work,
    required String userId,
    String? complaintImagePath, // optional
  }) async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    debugPrint('machine_id :---(.)(.)---: $machine_id');
    debugPrint('machine_model -> $machine_model');
    debugPrint('hour_meter -> $hour_meter');
    debugPrint('contact_person_name -> $contact_person_name');
    debugPrint('contact_person_number -> $contact_person_number');
    debugPrint('complaintController.text -> $complaint');
    debugPrint('state -> $state');
    debugPrint('city_id -> $city_id');
    debugPrint('hourController.text -> $pending_work');
    debugPrint('userId -> $userId');
    //1 machine_id:236
    //2 machine_model:235
    //3 state:28
    //4 city_id:1044
    //5 hour_meter:1495
    //6 complaint:Starter Problem & Service due
    //7 pending_work:inspect the machine Filter choke,  & Hyd Pipe leakage
    //8 status:Problem Solved 1
    //9 userId:1
    //10 contact_person_name:test
    //11 contact_person_number:9711732834
    try {
      final Map<String, dynamic> formMap = {
        'machine_id': machine_id,
        'machine_model': machine_model,
        'state': state,
        'city_id': city_id,
        'pending_work': pending_work,
        // 'status': 'open',
        'hour_meter': hour_meter,
        'complaint': complaint,
        'userId': userId,
        'contact_person_name': contact_person_name,
        'contact_person_number': contact_person_number,
      };
      debugPrint('complaintImagePath :---(.)(.)---: $complaintImagePath');

      // ✅ Add image ONLY if path is valid
      if (complaintImagePath != null) {
        formMap['complaintImage'] = await MultipartFile.fromFile(
          complaintImagePath,
          filename: complaintImagePath.split('/').last,
        );
      }

      final formData = FormData.fromMap(formMap);
      final response = await _dio.post(
        '/add_complaint',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );

      final raw = response.data.toString().trim();
      if (raw.isEmpty) throw Exception("Empty response");

      final start = raw.indexOf('{');
      if (start == -1) throw Exception("Invalid JSON: $raw");

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);

      return ComplaintLogResponse.fromJson(jsonMap);
    } catch (e) {
      rethrow;
    }
  }

  Future<ComplaintAssignResponse> assignComplaint({
    required String complaint_id,
    required String assigned_by,
    required String assigned_to,
  }) async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    try {
      final Map<String, dynamic> formMap = {
        'complaint_id': complaint_id,
        'assigned_by': assigned_by,
        'assigned_to': assigned_to,
      };

      final formData = FormData.fromMap(formMap);
      final response = await _dio.post(
        '/assigned_complaint',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );

      final raw = response.data.toString().trim();
      if (raw.isEmpty) throw Exception("Empty response");

      final start = raw.indexOf('{');
      if (start == -1) throw Exception("Invalid JSON: $raw");

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);

      return ComplaintAssignResponse.fromJson(jsonMap);
    } catch (e) {
      rethrow;
    }
  }

  Future<SimpleResponse> updateComplaint({
    required String employee_id,
    required String work_done,
    required String status,
    required String pending_work,
    required String id,
    required bool hasRquiredParts,
    required List<Map<String, dynamic>> parts,
    required Map<String, dynamic> mapdata,
  }) async {
    debugPrint("updateComplaint -> checklist: $mapdata");

    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    try {
      // ✅ BASE MAP
      Map<String, dynamic> map = {
        "id": id,
        "work_done": work_done,
        "status": status,
        "pending_work": pending_work,
        "employee_id": employee_id,
        "has_required_parts": hasRquiredParts ? 1 : 0,

        // 🔥 IMPORTANT
        "has_required_checklist": 1,
      };

      // ✅ ADD PARTS
      for (int i = 0; i < parts.length; i++) {
        map["parts[$i][PartId]"] = parts[i]["PartId"];
        map["parts[$i][Quantity]"] = parts[i]["Quantity"];
      }

      // ✅ ADD CHECKLIST (IMPORTANT FIX)
      mapdata.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          map[key] = value.toString().trim();
        }
      });

      // ✅ CREATE FORMDATA
      final formData = FormData();

      map.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // 🔍 DEBUG PRINT (VERY IMPORTANT)
      print("--------- FINAL REQUEST ---------");
      formData.fields.forEach((field) {
        print("${field.key}: ${field.value}");
      });

      final response = await _dio.post(
        '/update_complaint',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );

      final raw = response.data.toString().trim();

      if (raw.isEmpty) throw Exception("Empty response");

      final start = raw.indexOf('{');
      if (start == -1) throw Exception("Invalid JSON: $raw");

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);

      return SimpleResponse.fromJson(jsonMap);
    } catch (e) {
      debugPrint("updateComplaint exception: $e");
      rethrow;
    }
  }


  Future<ComplaintsResponse> searchfilter({
    required String from_date,
    required String to_date,
    required String status,
    required String userid,
    required String machine_id,
    required String keyword,
  }) async {
    _dio.options.headers["Accept-Encoding"] = "gzip, deflate";
    _dio.transformer = BackgroundTransformer();
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    try {
      final Map<String, dynamic> formMap = {
        'from_date': from_date,
        'to_date': to_date,
        'status': status,
        'userid': userid,
        'machine_id': machine_id,
        'keyword': keyword,
      };
      final formData = FormData.fromMap(formMap);
      final response = await _dio.post(
        '/searchfilter',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
          contentType: 'multipart/form-data',
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
      final raw = response.data.toString().trim();
      if (raw.isEmpty) throw Exception("Empty response");

      final start = raw.indexOf('{');
      if (start == -1) throw Exception("Invalid JSON: $raw");

      final jsonBody = raw.substring(start);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonBody);

      return ComplaintsResponse.fromJson(jsonMap);
    } catch (e) {
      rethrow;
    }
  }

}//End
