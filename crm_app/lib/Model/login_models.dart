class LoginResponse {
  final int success;
  final String message;
  final String token;
  final UserData data;
  final List<Menu> menu;

  LoginResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.data,
    required this.menu,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      data: UserData.fromJson(json['data']),
      menu: (json['menu'] as List)
          .map((e) => Menu.fromJson(e))
          .toList(),
    );
  }
}

class UserData {
  final String userId;
  final String employeeId;
  final String email;
  final String joiningDate;
  final String name;
  final String mobile;
  final String dob;
  final String profilePic;
  final String licenseCopy;
  final String licenseExp;
  final String licenseType;
  final String address;
  final String aadhaarNo;
  final String roleId;
  final String role;
  final String lastLogin;

  UserData({
    required this.userId,
    required this.employeeId,
    required this.email,
    required this.joiningDate,
    required this.name,
    required this.mobile,
    required this.dob,
    required this.profilePic,
    required this.licenseCopy,
    required this.licenseExp,
    required this.licenseType,
    required this.address,
    required this.aadhaarNo,
    required this.roleId,
    required this.role,
    required this.lastLogin,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'],
      employeeId: json['employee_id'],
      email: json['email'],
      joiningDate: json['joining_date'],
      name: json['name'],
      mobile: json['mobile'],
      dob: json['dob'],
      profilePic: json['profile_pic'],
      licenseCopy: json['license_copy'],
      licenseExp: json['license_exp'],
      licenseType: json['license_type'],
      address: json['address'],
      aadhaarNo: json['aadhaar_no'],
      roleId: json['role_id'],
      role: json['role'],
      lastLogin: json['lastLogin'],
    );
  }
}

class Menu {
  final String menuId;
  final String menuName;
  final Permissions permissions;
  final List<SubMenu> submenus;

  Menu({
    required this.menuId,
    required this.menuName,
    required this.permissions,
    required this.submenus,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      menuId: json['menu_id'],
      menuName: json['menu_name'],
      permissions: Permissions.fromJson(json['permissions']),
      submenus: (json['submenus'] as List)
          .map((e) => SubMenu.fromJson(e))
          .toList(),
    );
  }
}

class SubMenu {
  final dynamic subMenuId;
  final String name;
  final String url;
  final String icon;
  final String position;
  final Permissions permissions;

  SubMenu({
    required this.subMenuId,
    required this.name,
    required this.url,
    required this.icon,
    required this.position,
    required this.permissions,
  });

  factory SubMenu.fromJson(Map<String, dynamic> json) {
    return SubMenu(
      subMenuId: json['sub_menu_id'],
      name: json['name'],
      url: json['url'],
      icon: json['icon'],
      position: json['position'],
      permissions: Permissions.fromJson(json['permissions']),
    );
  }
}

class Permissions {
  final int add;
  final int edit;
  final int delete;
  final int view;

  Permissions({
    required this.add,
    required this.edit,
    required this.delete,
    required this.view,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(
      add: int.parse(json['add'].toString()),
      edit: int.parse(json['edit'].toString()),
      delete: int.parse(json['delete'].toString()),
      view: int.parse(json['view'].toString()),
    );
  }
}