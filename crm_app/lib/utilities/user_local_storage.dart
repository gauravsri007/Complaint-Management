import 'package:shared_preferences/shared_preferences.dart';

import '../Model/login_models.dart';

class UserLocalStorage {
  static Future<void> saveUserLocally(UserData user,String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);
    await prefs.setString('userId', user.userId);
    await prefs.setString('employee_id', user.employeeId);
    await prefs.setString('email', user.email);
    await prefs.setString('name', user.name);
    await prefs.setString('mobile', user.mobile);
    await prefs.setString('role', user.role);
    await prefs.setString('role_id', user.roleId);
  }

  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();

    int? loginTime = prefs.getInt('login_time');

    if (loginTime == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;

    final difference = now - loginTime;

    return difference > Duration(hours: 1).inMilliseconds;
  }

  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('token')) return null;

    return prefs.getString('token') ?? "";
    }

  static Future<UserData?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userId')) return null;

    return UserData(
      userId: prefs.getString('userId') ?? "",
      employeeId: prefs.getString('employee_id') ?? "",
      email: prefs.getString('email') ?? "",
      joiningDate: "", // Not saved earlier, optional
      name: prefs.getString('name') ?? "",
      mobile: prefs.getString('mobile') ?? "",
      dob: "",
      profilePic: "",
      licenseCopy: "",
      licenseExp: "",
      licenseType: "",
      address: "",
      aadhaarNo: "",
      roleId: prefs.getString('role_id') ?? "",
      role: prefs.getString('role') ?? "",
      lastLogin: "",
    );
  }

}

