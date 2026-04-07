import 'dart:convert';

import 'package:crm_app/API/auth_api_service.dart';
import 'package:crm_app/Model/common_model.dart';
import 'package:crm_app/utilities/enums.dart';
import 'package:crm_app/utilities/globals.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/app/service_listing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/login_page.dart';
import '../Model/employee_list_model.dart';
import '../Model/machine_model.dart';
import '../Model/machine_number_model.dart';
import '../utilities/user_local_storage.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String username = "";
  UserRole? userRole;
  bool _isLogoutLoading = false;
  final _authService =
  AuthApiService('https://dashboard.reachinternational.co.in/development/api');
  bool _isMachineModelsLoading = false;
  bool _isEmployeeLoading = false;

  final Map<String, List<MachineModelData>> _machineModelCache = {};

  @override
  void initState() {
    super.initState();
    checkSession(context);
    _loadUser();
    getEmployeeList();
  }

  Future<void> checkSession(BuildContext context) async {
    bool expired = await UserLocalStorage.isSessionExpired();

    if (expired) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> logoutAction() async {
    final user = await UserLocalStorage.getSavedUser();
    setState(() => _isLogoutLoading = true);
    try {
      debugPrint('userId: ${user!.userId}');
      final res = await _authService.logout(user_id: user!.userId);
      if (res.status == true) {
        debugPrint('logout error: ${res.message}');
        debugPrint('logout status: ${res.status}');

        logout(context);
      } else {
        debugPrint('logout error: ${res.message}');
      }
    } catch (e) {
      debugPrint('logout exception: $e');
    } finally {
      setState(() => _isLogoutLoading = false);
    }
  }

  Future<void> _loadUser() async {
    final user = await UserLocalStorage.getSavedUser();
    debugPrint('User Role: ${user?.role}');
    debugPrint('User Name: ${user?.name}');
    debugPrint('User ID: ${user?.userId}');
    debugPrint('Employee ID: ${user?.employeeId}');
    debugPrint('Mobile: ${user?.mobile}');
    debugPrint('user?.roleId: ${user?.roleId}');

    final role = UserRole.fromIdString(user?.roleId);
    debugPrint('role?.label: ${role?.label}');
    // Update UI state only here
    setState(() {
      username = user!.name;
      // userRole = user!.role as UserRole?;
    });
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('user_role'); // also clear saved role
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  // Helper: convert res.data (which might be List<Map> or List<Model>) to List<T>.
  List<T> _parseListResponse<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data == null) return <T>[];
    try {
      final list = data as List<dynamic>;
      return list.map<T>((e) {
        if (e is T) return e;
        if (e is Map<String, dynamic>) return fromJson(e);
        if (e is Map) return fromJson(Map<String, dynamic>.from(e));
        // fallback: try json decode string (rare)
        throw Exception('Unsupported element type ${e.runtimeType}');
      }).toList();
    } catch (e) {
      debugPrint('_parseListResponse error: $e');
      return <T>[];
    }
  }

  Future<void> getEmployeeList() async {
    final user = await UserLocalStorage.getSavedUser();
    // debugPrint("user!.role-----------------------> ${user!.role}");

    setState(() => _isEmployeeLoading = true);
    try {
      final res = await _authService.getEmployeeList(
        role_name: "Service Engineer",
      );
      if (res.status == true) {
        AppData.employee_list = res.data;
        debugPrint('getEmployeeList data: ${res.data}');

      } else {
        debugPrint('getEmployeeList error: ${res.message}');
      }
    } catch (e) {
      debugPrint('getEmployeeList exception: $e');
    } finally {
      setState(() => _isEmployeeLoading = false);
    }
  }



  void _showError(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }



    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppData.primaryBlue,
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              username.isNotEmpty ? "Welcome $username," : "Welcome,",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              "Our Services",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: dashboardTile(
                          color: Colors.blue,
                          icon: Icons.report_problem,
                          label: "Complaints",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ComplaintListingPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: dashboardTile(
                          color: Colors.grey,
                          icon: Icons.home_repair_service,
                          label: "Services",
                          onTap: () {

                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: dashboardTile(
                          color: Colors.grey,
                          icon: Icons.checklist,
                          label: "Todo",
                          onTap: () {

                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: dashboardTile(
                          color: Colors.red,
                          icon: Icons.logout,
                          label: "Logout",
                          onTap: () => logoutAction(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Image.asset(
              'assets/logo-reach-site.jpg',
              height: 80,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget dashboardTile({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

extension on List<Employee> {
  Object? toJson() {}
}

extension on List<MachineNumber> {
  Object? toJson() {}
}
