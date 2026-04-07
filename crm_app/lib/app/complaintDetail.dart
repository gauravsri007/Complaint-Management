import 'dart:convert';

import 'package:crm_app/API/auth_api_service.dart';
import 'package:crm_app/Model/complaint_details_model.dart';
import 'package:crm_app/Model/complaint_history_model.dart';
import 'package:crm_app/Model/employee_list_model.dart';
import 'package:crm_app/Model/get_parts_model.dart';
import 'package:crm_app/Model/login_models.dart';
import 'package:crm_app/utilities/globals.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/utilities/enums.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/check_list_model.dart';
import '../utilities/user_local_storage.dart';

class ComplaintDetailPage extends StatefulWidget {
  final ComplaintDetail complaint;
  final List<String> serviceEngineers;
  final List<String> machineNumbers;
  final VoidCallback onAcknowledge;


  const ComplaintDetailPage({
    required this.complaint,
    required this.serviceEngineers,
    required this.machineNumbers,
    required this.onAcknowledge,
  });

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage>
    with SingleTickerProviderStateMixin {
  late ComplaintDetail complaint;
  List<Employee> employees = [];
  List<PartItem> partsList = [];

  List<ComplaintHistoryModel> complaintHistoryList = [];
  bool _requiredParts = false;
  final TextEditingController engineOilQtyController = TextEditingController();
  final TextEditingController hydraulicOilQtyController = TextEditingController();

  UserData? currentUser;
  final TextEditingController _workDoneController = TextEditingController();
  final TextEditingController _pendingWorkController = TextEditingController();
  final TextEditingController serviceDueDateController = TextEditingController();

  String? status;
  final List<String> status_serviceEngineer = [
    "Work Done",
    "Pending Work",
  ];

// Available parts (example data; replace with real parts from API)
  final List<String> _availableParts = [
    'Filter',
    'Compressor',
    'Fuse',
    'Motor',
    'Valve',
  ];
  // Dynamic list of selected parts (each entry: {'part': String, 'qty': int})
  final List<Map<String, dynamic>> _selectedParts = [
    {
      'PartId': null,
      'Quantity': 1,
    }
  ];

  bool _isComplaintStatus = true; // NEW
  bool _isReplaceAddedParts = true; // NEW
  bool _isServiceCheckList = true; // NEW
  bool _isChecklistExpanded = false;

  List<ChecklistItem> checklist = [
    ChecklistItem(title: "Engine Starting", options: ["Yes", "No"]),
    ChecklistItem(title: "Hours Meter", options: ["Yes", "No"]),
    ChecklistItem(title: "Key Switch", options: ["Yes", "No"]),
    ChecklistItem(title: "Emergency Ground", options: ["Yes", "No"]),
    ChecklistItem(title: "Emergency Platform", options: ["Yes", "No"]),

    ChecklistItem(title: "Battery & Terminal", options: ["Yes", "No"]),
    ChecklistItem(title: "Horn", options: ["Yes", "No"]),
    ChecklistItem(title: "Light", options: ["Yes", "No"]),
    ChecklistItem(title: "Wheel Rim Nut", options: ["Yes", "No"]),
    ChecklistItem(title: "Hydraulic Cylinder Leakage", options: ["Yes", "No"]),
    ChecklistItem(title: "Wire Hardness", options: ["Yes", "No"]),
    ChecklistItem(title: "Break Operates Properly", options: ["Yes", "No"]),
    ChecklistItem(title: "All Toggle Switch in place & works properly", options: ["Yes", "No"]),


    ChecklistItem(title: "Engine Oil", options: ["Yes", "No"]),
    ChecklistItem(title: "Hydraulic Oil", options: ["Yes", "No"]),
    ChecklistItem(title: "Fuel Feed Pump", options: ["Yes", "No", "Electric"]),
    ChecklistItem(
      title: "Function from Basket",
      options: ["OK", "Slow", "Not Working"],
    ),
    ChecklistItem(
      title: "Function from Ground",
      options: ["OK", "Slow", "Not Working"],
    ),
    ChecklistItem(title: "Joy Stick", options: ["Yes", "No"]),
    ChecklistItem(title: "Hydraulic Pipe Leakage", options: ["Yes", "No"]),
    ChecklistItem(title: "Machine free bypass/modification", options: ["Yes", "No","Corrected"]),
    ChecklistItem(title: "Machine maintained by Opt", options: ["Yes", "No"]),
    ChecklistItem(title: "Machine Service Due", options: ["Yes", "Due"]),
  ];
  final _formKey = GlobalKey<FormState>();

  bool _isComplaintExpanded = true; // NEW
  bool _isAcknowledgeLoading = false;
  bool _isComplaintDetailsLoading = false;
  bool _isComplaintHistoryLoading = false;
  bool _isEmployeeLoading = false;
  bool _isAssignComplaintLoading = false;
  String? selectedEngineerId;
  // String? selectedParts;
  late TabController tabController;
  bool _isPartsExpanded = false;
  bool _showPartsForm = false;
  final _authService =
  AuthApiService('https://dashboard.reachinternational.co.in/development/api');
  final _statusFocus = FocusNode();
  final _workDoneFocus = FocusNode();
  final _statusKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _initData();
    checkSession(context);

  }

  Future<void> checkSession(BuildContext context) async {
    bool expired = await UserLocalStorage.isSessionExpired();

    if (expired) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _initData() async {
    complaint = widget.complaint;
    complaint = widget.complaint;          // 👈 MUST
    complaintHistoryList = [];
    currentUser = await UserLocalStorage.getSavedUser();

    // print("currentUser?.role ************************* ${currentUser?.role == UserRole.serviceEngineer.label}");
    // print('complaint!.status ************************* ${complaint!.status}');
    // print('currentUser?.role ************************* ${currentUser?.role}');
    if (complaint!.status == ComplaintStatus.open.string && currentUser?.role == UserRole.serviceEngineer.label) {
      complaintAcknowledge();
    } else {
      widget.complaint.status = complaint.status;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAcknowledge();
      });
    }

    tabController = TabController(length: 2, vsync: this);

    Future.wait([
      getComplaintDetails(),
      getComplaintHistory(),
      getEmployeeList(),
      getPartsList(),
    ]);
  }

  String? getUserIdFromUserName(
      List<Employee> employees,
      String userName,
      ) {
    try {
      return employees
          .firstWhere(
            (e) => e.name.trim().toLowerCase() ==
            userName.trim().toLowerCase(),
      )
          .userId;
    } catch (_) {
      return null; // not found
    }
  }


  Future<void> complaintAcknowledge() async {
    debugPrint('complaintAcknowledge called ...');

    final user = await UserLocalStorage.getSavedUser();
    setState(() => _isAcknowledgeLoading = true);
    try {
      final res = await _authService.complaintAcknowledge(
          complaint_id: complaint!.complaintId!,
          assigned_to:  complaint.assigned_to
      );
      if (res.status == true) {
        debugPrint("Message -----------------------> ${res.message}");
      } else {
        debugPrint('complaintAcknowledge error: ${res.message}');
      }
    } catch (e) {
      debugPrint('complaintAcknowledge exception: $e');
    } finally {
      setState(() => _isAcknowledgeLoading = false);
    }
  }

  Future<void> assignComplaint() async {
    final user = await UserLocalStorage.getSavedUser();
    setState(() => _isAssignComplaintLoading = true);
    try {
      final res = await _authService.assignComplaint(
          complaint_id: complaint!.complaintId!,
          assigned_to: selectedEngineerId!,
          assigned_by:user!.userId,
      );

      if (res.status == true) {
        debugPrint("Message -----------------------> ${res.message}");
        // ✅ SUCCESS ALERT
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Complaint assigned successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context, true); // go back if needed
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        debugPrint('assignComplaint error: ${res.message}');
      }
    } catch (e) {
      debugPrint('assignComplaint exception: $e');
    } finally {
      setState(() => _isAssignComplaintLoading = false);
    }
  }

  Future<void> getComplaintDetails() async {
    final user = await UserLocalStorage.getSavedUser();
    setState(() => _isComplaintDetailsLoading = true);
    try {
      debugPrint('userId: ${user!.userId}');
      final res = await _authService.getComplaintDetails(
          complaint_id: complaint!.complaintId!,
      );
      if (res.status == true) {
        complaint = res.data;
        // ✅ ADD THIS
        // if (complaint.checklist.isNotEmpty) {
        //   prefillChecklist(complaint.checklist.first);
        // }
        // debugPrint("RESPONSE IS -----------------------> ${complaint?.complaintId}");
        debugPrint("RAW RESPONSE: ${jsonEncode(complaint?.toJson())}");
        // print("requiredParts -> ${res.data.requiredParts.length}");
        debugPrint("pdf -> ${res.data.pdf?.pdf}");

      } else {
        debugPrint('getComplaintDetails error: ${res.message}');
      }
    } catch (e) {
      debugPrint('getComplaintDetails exception: $e');
    } finally {
      setState(() => _isComplaintDetailsLoading = false);
    }
  }

  Future<void> getComplaintHistory() async {
    final user = await UserLocalStorage.getSavedUser();

    setState(() => _isComplaintHistoryLoading = true);
    try {
      debugPrint('userId: ${user!.userId}');
      final res = await _authService.getComplaintHistryApi(
        complaint_id: complaint!.complaintId!,
      );
      if (res.status == true) {
        complaintHistoryList = res.data;
        debugPrint("RESPONSE IS -----------------------> ${complaint?.complaint}");
      } else {
        debugPrint('getComplaintHistory error: ${res.message}');
      }
    } catch (e) {
      // 👇 IMPORTANT: still initialize list
      setState(() {
        complaintHistoryList = [];
      });
      debugPrint('getComplaintHistory exception: $e');
    } finally {
      setState(() => _isComplaintHistoryLoading = false);
    }
  }

  Future<void> getEmployeeList() async {
    final user = await UserLocalStorage.getSavedUser();
    debugPrint("user!.role-----------------------> ${user!.role}");

    setState(() => _isEmployeeLoading = true);
    try {
      final res = await _authService.getEmployeeList(
        role_name: "Service Engineer",
      );
      if (res.status == true) {
        employees = res.data;
        debugPrint("RESPONSE IS getEmployeeList-----------------------> ${employees?.first}");
      } else {
        debugPrint('getEmployeeList error: ${res.message}');
      }
    } catch (e) {
      debugPrint('getEmployeeList exception: $e');
    } finally {
      setState(() => _isEmployeeLoading = false);
    }
  }

  Future<void> getPartsList() async {
    final user = await UserLocalStorage.getSavedUser();
    debugPrint("user!.role-----------------------> ${user!.role}");

    setState(() => _isEmployeeLoading = true);
    try {
      final res = await _authService.fetchPartslist();
      if (res.status == true) {
        partsList = res.data;
      } else {
        debugPrint('getPartsList error: ${res.message}');
      }
    } catch (e) {
      debugPrint('getPartsList exception: $e');
    } finally {
      setState(() => _isEmployeeLoading = false);
    }
  }

  Future<void> update_complaint(Map<String, dynamic> mapdata) async {
    final userId = getUserIdFromUserName(employees, complaint.assignee!);
    setState(() => _isEmployeeLoading = false);
    debugPrint(
        "update_complaint -> mapdata: ${mapdata}"
    );
    try {
      final res = await _authService.updateComplaint(
        employee_id: userId!,
        work_done: _workDoneController.text.trim(),
        status: status!,
        pending_work: _pendingWorkController.text.trim(),
        id: complaint.complaintId,
        hasRquiredParts: _requiredParts,
        parts: _selectedParts,
        mapdata: mapdata,
      );
      if (res.status == true) {
        // ✅ SUCCESS ALERT
        debugPrint(
            "update_complaint -> RAW RESPONSE: ${jsonEncode(complaint.toJson())}"
        );
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Complaint updated successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context, true); // go back if needed
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        debugPrint('assignComplaint error: ${res.message}');
      }
    } catch (e) {
      debugPrint('assignComplaint exception: $e');
    } finally {
      setState(() => _isAssignComplaintLoading = false);
    }
  }

  Map<String, dynamic> getChecklistPayload() {
    return {
      "engine_starting": getValue("Engine Starting"),
      "hour_meter": getValue("Hours Meter"),
      "key_switch": getValue("Key Switch"),
      "emergency_ground": getValue("Emergency Ground"),
      "emergency_platform": getValue("Emergency Platform"),
      "battery_terminal": getValue("Battery & Terminal"),
      "horn": getValue("Horn"),
      "light": getValue("Light"),
      "wheel_rim_nut": getValue("Wheel Rim Nut"),
      "hydraulic_cylinder_leakage":
      getValue("Hydraulic Cylinder Leakage"),
      "wire_hardness": getValue("Wire Hardness"),
      "brake_operate_normally":
      getValue("Break Operates Properly"),
      "toggles_switch_normal":
      getValue("All Toggle Switch"),

      "engine_oil_status": getValue("Engine Oil"),
      "engine_oil_qty": engineOilQtyController.text,

      "hydraulic_oil_status": getValue("Hydraulic Oil"),
      "hydraulic_oil_qty": hydraulicOilQtyController.text,

      "fuel_feed_pump": getValue("Fuel Feed Pump"),

      "function_from_basket": getValue("Function from Basket"),
      "function_from_ground": getValue("Function from Ground"),

      "joy_stick": getValue("Joy Stick"),
      "hydraulic_pipe_leakage":
      getValue("Hydraulic Pipe Leakage"),

      "machine_free_bypass": getValue("Machine free bypass"),
      "machine_maintained_by_opt":
      getValue("Machine maintained by Opt"),

      "machine_service_due_status":
      getValue("Machine Service Due"),
      "machine_service_due_date": serviceDueDateController.text,
    };
  }

  String getValue(String title) {
    final item = checklist.firstWhere(
          (e) => e.title == title,
      orElse: () => ChecklistItem(title: title, options: []),
    );

    if (item.selected == null) return "";
    if (item.selected == "Yes") return "Y";
    if (item.selected == "No") return "N";
    return item.selected!; // OK, Slow, Not Working, Electric etc.
  }

  void _addPartRow() {
    setState(() {
      _selectedParts.add({
        'PartId': null,
        'Quantity': 1,
      });
    });
  }

  void _removePartRow(int index) {
    setState(() {
      _selectedParts.removeAt(index);
    });
  }

  void _viewPdf() async {
    final url = complaint.pdf?.pdf;

    if (url == null || url.isEmpty) {
      _showMessage("PDF not available");
      return;
    }

    final viewerUrl =
        "https://docs.google.com/gview?embedded=true&url=$url";

    final uri = Uri.parse(viewerUrl);

    if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      _showMessage("Unable to open PDF");
    }
  }

  void _downloadPdf() async {
    final url = complaint.pdf?.pdf;
    debugPrint("url $url");
    if (url == null || url.isEmpty) {
      _showMessage("PDF not available");
      return;
    }

    try {
      final dir = "/storage/emulated/0/Download"; // Android path
      final filePath = "$dir/complaint_${complaint.complaintId}.pdf";

      await Dio().download(url, filePath);

      _showMessage("PDF downloaded to Downloads");
    } catch (e) {
      _showMessage("Download failed");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  bool get isResolved => widget.complaint.status == ComplaintStatus.resolved;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: AppData.primaryBlue,
        title: const Text("Complaint Details", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (complaint.pdf != null && (complaint.pdf!.pdf?.isNotEmpty ?? false))
            PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'view_pdf') {
                _viewPdf();
              } else if (value == 'download_pdf') {
                _downloadPdf();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_pdf',
                child: Text('View PDF'),
              ),
              const PopupMenuItem(
                value: 'download_pdf',
                child: Text('Download PDF'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: "Details"),
            Tab(icon: Icon(Icons.history), text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          buildDetailsTab(complaint),
          buildHistoryTab(complaintHistoryList.cast<ComplaintHistoryModel>()),
        ],
      ),
    );

  }

  String naIfEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "NA";
    }
    return value;
  }

  // --------------------- TAB 1: DETAILS --------------------- //

  Widget buildDetailsTab(ComplaintDetail complaint) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          if (complaint.images.isNotEmpty) ...[
            SizedBox(
              height: 230,
              width: double.infinity,
              child: Image.network(
                complaint.images.first,
                fit: BoxFit.fitHeight,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isComplaintExpanded = !_isComplaintExpanded;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Complaint Information",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Icon(
                    _isComplaintExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          if (_isComplaintExpanded)
          infoCard(
            children: [

              statusAndDownloadRow(complaint),
              const SizedBox(height: 6),

              Divider(
                thickness: 1,
                color: Colors.grey.shade300,tt
              ),
              const SizedBox(height: 10),

              infoTile(
                Icons.calendar_today,
                "Complaint No",
                naIfEmpty("${complaint?.complaint_no}"),
              ),

              infoTile(
                Icons.calendar_today,
                "Complaint Date",
                naIfEmpty(AppData.shared.formatDate(complaint!.createdDate)),
              ),

              infoTile(
                Icons.place,
                "Location",
                naIfEmpty("${complaint?.stateName}, ${complaint?.cityName}"),
              ),

              infoTile(
                Icons.confirmation_number,
                "Machine No",
                naIfEmpty(complaint?.machine_no),
              ),

              infoTile(
                Icons.precision_manufacturing,
                "Model",
                naIfEmpty(complaint?.machine),
              ),

              infoTile(
                Icons.error_outline,
                "Complaint Info",
                naIfEmpty(complaint?.complaint),
              ),

              infoTile(
                Icons.error_outline,
                "Pending Work",
                naIfEmpty(complaint?.pendingWork),
              ),

              infoTile(
                Icons.error_outline,
                "Work Done",
                naIfEmpty(complaint?.workDone),
              ),

              infoTile(
                Icons.error_outline,
                "Hour Meter",
                naIfEmpty(complaint?.hourMeter),
              ),

              infoTile(
                Icons.error_outline,
                "Assignee",
                naIfEmpty(complaint?.assignee),
              ),
              infoTile(
                Icons.error_outline,
                "Last Updated",
                naIfEmpty(AppData.shared.formatDate(complaint.updatedDate)),
              ),
              infoTile(
                Icons.error_outline,
                "Site Contact Person Name",
                naIfEmpty(complaint.contact_person_name),
              ),
              infoTile(
                Icons.error_outline,
                "Site Contact Person No",
                naIfEmpty(complaint.contact_person_number),
              ),

              const SizedBox(height: 8),
              const Divider(),

              if (complaint.requiredParts.isNotEmpty) ...[
                const SizedBox(height: 10),
                buildPartsDisplaySection(complaint),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 8),
              buildChecklistDisplaySection(complaint),
              const SizedBox(height: 8),

            ],
          ),


            if (currentUser?.role != UserRole.serviceEngineer.label)
            ...[
              sectionTitle("Assign Engineer"),
            ]
          else
            ...[
              sectionTitle("Update Service Report"),
            ],
            infoCard(
            children: [
              // --------------------- serviceEngineer --------------------- //
              if (currentUser?.role == UserRole.serviceEngineer.label)
                ...[
                if (isResolved)
                    ...[
                  infoTile(Icons.note_alt, "Resolution Remarks", complaint.complaintId ?? "No remarks"),
                      infoTile(Icons.done_all, "Resolved Date", complaint.createdDate ?? "-"),
                      infoTile(Icons.engineering, "Resolved By", complaint.assignee ?? "-"),
                    ]
                  else
                    ...[
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              key: _statusKey,
                              child: complaintStatusSection(complaint),
                            ),

                            const SizedBox(height: 10),

                            replacesAddedPartsSection(complaint),
                            const SizedBox(height: 10),

                            serviceCheckListSection(complaint),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),

                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppData.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                          ),
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                              _scrollToFirstError();
                              return;
                            }

                            if (status == null) {
                              _scrollToFirstError();
                              return;
                            }

                            update_complaint(getChecklistPayload());
                          },
                          child: const Text("Update Complaint",
                              style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                   ]

              //--------------------- serviceManager ------------------------
              //-------------------------------------------------------------
               else
                ...[
                  if (isResolved)
                    ...[
                      infoTile(Icons.note_alt, "Resolution Remarks", complaint.complaintId ?? "No remarks"),
                      infoTile(Icons.done_all, "Resolved Date", complaint.createdDate ?? "-"),
                      infoTile(Icons.engineering, "Resolved By", complaint.assignee ?? "-"),
                    ]
                  else
                    ...[
                      seviceEngineerDropdown(),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppData.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                          ),
                          onPressed: () {
                            assignComplaint();
                          },
                          child: const Text("Assign Complaint",
                              style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ]
            ],
          ),
        ],
      ),
    );
  }

  void _scrollToFirstError() {
    final context = _statusKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void prefillChecklist(Checklist data) {
    for (var item in checklist) {
      switch (item.title) {
        case "Engine Starting":
          item.selected = getDisplayValue(data.engineStarting);
          break;

        case "Hours Meter":
          item.selected = getDisplayValue(data.hourMeter);
          break;

        case "Key Switch":
          item.selected = getDisplayValue(data.keySwitch);
          break;

        case "Emergency Ground":
          item.selected = getDisplayValue(data.emergencyGround);
          break;

        case "Emergency Platform":
          item.selected = getDisplayValue(data.emergencyPlatform);
          break;

        case "Battery & Terminal":
          item.selected = getDisplayValue(data.batteryTerminal);
          break;

        case "Horn":
          item.selected = getDisplayValue(data.horn);
          break;

        case "Light":
          item.selected = getDisplayValue(data.light);
          break;

        case "Wheel Rim Nut":
          item.selected = getDisplayValue(data.wheelRimNut);
          break;

        case "Hydraulic Cylinder Leakage":
          item.selected =
              getDisplayValue(data.hydraulicCylinderLeakage);
          break;

        case "Wire Hardness":
          item.selected = getDisplayValue(data.wireHardness);
          break;

        case "Break Operates Properly":
          item.selected =
              getDisplayValue(data.brakeOperateNormally);
          break;

        case "All Toggle Switch in place & works properly":
          item.selected =
              getDisplayValue(data.togglesSwitchNormal);
          break;

        case "Engine Oil":
          item.selected = getDisplayValue(data.engineOilStatus);
          engineOilQtyController.text = data.engineOilQty.trim();
          break;

        case "Hydraulic Oil":
          item.selected =
              getDisplayValue(data.hydraulicOilStatus);
          hydraulicOilQtyController.text =
              data.hydraulicOilQty.trim();
          break;

        case "Fuel Feed Pump":
          item.selected = data.fuelFeedPump;
          break;

        case "Function from Basket":
          item.selected = data.functionFromBasket;
          break;

        case "Function from Ground":
          item.selected = data.functionFromGround;
          break;

        case "Joy Stick":
          item.selected = getDisplayValue(data.joyStick);
          break;

        case "Hydraulic Pipe Leakage":
          item.selected =
              getDisplayValue(data.hydraulicPipeLeakage);
          break;

        case "Machine free bypass/modification":
          item.selected = data.machineFreeBypass;
          break;

        case "Machine maintained by Opt":
          item.selected =
              getDisplayValue(data.machineMaintainedByOpt);
          break;

        case "Machine Service Due":
          item.selected = data.machineServiceDueStatus;
          serviceDueDateController.text =
              data.machineServiceDueDate;
          break;
      }
    }

    setState(() {});
  }

  String getDisplayValue(String value) {
    if (value == "Y") return "Yes";
    if (value == "N") return "No";
    return value;
  }


  Widget buildChecklistDisplaySection(ComplaintDetail complaint) {
    if (complaint.checklist.isEmpty) return const SizedBox();

    final checklist = complaint.checklist.first;

    // helper
    String yesNo(String val) {
      if (val == "Y") return "Yes";
      if (val == "N") return "No";
      return val;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),

        // 🔽 HEADER (EXPAND / COLLAPSE)
        InkWell(
          onTap: () {
            setState(() {
              _isChecklistExpanded = !_isChecklistExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Service Checklist",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                _isChecklistExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 🔽 CONTENT
        if (_isChecklistExpanded) ...[
          _row("Engine Starting", yesNo(checklist.engineStarting)),
          _row("Hour Meter", yesNo(checklist.hourMeter)),
          _row("Key Switch", yesNo(checklist.keySwitch)),
          _row("Emergency Ground", yesNo(checklist.emergencyGround)),
          _row("Emergency Platform", yesNo(checklist.emergencyPlatform)),
          _row("Battery Terminal", yesNo(checklist.batteryTerminal)),
          _row("Horn", yesNo(checklist.horn)),
          _row("Light", yesNo(checklist.light)),
          _row("Wheel Rim Nut", yesNo(checklist.wheelRimNut)),
          _row("Hydraulic Cylinder Leakage",
              yesNo(checklist.hydraulicCylinderLeakage)),
          _row("Wire Hardness", yesNo(checklist.wireHardness)),
          _row("Brake Operate Normally",
              yesNo(checklist.brakeOperateNormally)),
          _row("Toggle Switch Normal",
              yesNo(checklist.togglesSwitchNormal)),

          const Divider(),

          _row("Engine Oil",
              "${yesNo(checklist.engineOilStatus)} (${checklist.engineOilQty.trim()})"),

          _row("Hydraulic Oil",
              "${yesNo(checklist.hydraulicOilStatus)} (${checklist.hydraulicOilQty.trim()})"),

          _row("Fuel Feed Pump", checklist.fuelFeedPump),
          _row("Function from Basket", checklist.functionFromBasket),
          _row("Function from Ground", checklist.functionFromGround),
          _row("Joy Stick", yesNo(checklist.joyStick)),
          _row("Hydraulic Pipe Leakage",
              yesNo(checklist.hydraulicPipeLeakage)),

          const Divider(),

          _row("Machine Free Bypass", checklist.machineFreeBypass),
          _row("Maintained by Operator",
              yesNo(checklist.machineMaintainedByOpt)),
          _row("Service Due Status",
              checklist.machineServiceDueStatus),
          _row("Service Due Date",
              checklist.machineServiceDueDate),
        ],
      ],
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value.isEmpty ? "N/A" : value,
              textAlign: TextAlign.end, // 👈 RIGHT ALIGN
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPartsDisplaySection(ComplaintDetail complaint) {
    if (complaint.requiredParts.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // 🔽 Expand / Collapse Header
        InkWell(
          onTap: () {
            setState(() {
              _isPartsExpanded = !_isPartsExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Replaced/Added Parts",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(
                _isPartsExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 🔽 Expanded Content
        if (_isPartsExpanded)
          ...complaint.requiredParts.map(
                (part) => Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: const Icon(Icons.build_circle, color: Colors.blue),
                title: Text(part.partName),
                subtitle: Text("Quantity: ${part.quantity}"),
              ),
            ),
          ),
      ],
    );
  }

  Widget complaintStatusSection(ComplaintDetail complaint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // 🔽 Expand / Collapse Header
        InkWell(
          onTap: () {
            setState(() {
              _isComplaintStatus = !_isComplaintStatus;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Update Service Report",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(
                _isComplaintStatus
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 🔽 Expanded Content
          if (_isComplaintStatus) ...[
            DropdownButtonFormField<String>(
                focusNode: _statusFocus, // 👈 ADD THIS
              value: status,
              items: ComplaintStatus.values
                  .map(
                    (e) => DropdownMenuItem<String>(
                  value: e.value,
                  child: Text(e.value),
                ),
              )
                  .toList(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: RichText(
                  text: const TextSpan(
                    text: 'Status',
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              onChanged: (v) => setState(() => status = v),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    FocusScope.of(context).requestFocus(_statusFocus);
                    return 'Please select status';
                  }
                  return null;
                }
            ),

            const SizedBox(height: 20),

            // Work Done
            TextFormField(
                focusNode: _workDoneFocus, // 👈 ADD THIS
              controller: _workDoneController,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                label: RichText(
                  text: const TextSpan(
                    text: 'Work Done',
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              minLines: 3,
              maxLines: 6,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    FocusScope.of(context).requestFocus(_workDoneFocus);
                    return 'Please enter work done';
                  }
                  return null;
                }
            ),

            const SizedBox(height: 16),

            // Pending Work
            TextFormField(
              controller: _pendingWorkController,
              decoration: const InputDecoration(
                labelText: 'Pending Work',
                alignLabelWithHint: true,
              ),
              minLines: 2,
              maxLines: 4,
              // validator: (v) => (v == null || v.trim().isEmpty)
              //     ? 'Please describe pending work'
              //     : null,
            ),

            const SizedBox(height: 16),
          ],

      ],
    );
  }

  Widget replacesAddedPartsSection(ComplaintDetail complaint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // 🔽 Expand / Collapse Header
        InkWell(
          onTap: () {
            setState(() {
              _isReplaceAddedParts = !_isReplaceAddedParts;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Required Parts",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(
                _isReplaceAddedParts
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 🔽 Expanded Content
        if (_isReplaceAddedParts) ...[
            Row(
              children: [
                const Text('Required Parts:'),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('No'),
                  selected: !_requiredParts,
                  onSelected: (sel) => setState(() => _requiredParts = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Yes'),
                  selected: _requiredParts,
                  onSelected: (sel) => setState(() => _requiredParts = true),
                ),
              ],
            ),
          // Parts section (dynamic)
          buildPartsFormSection(),
          const SizedBox(height: 24),
        ],

      ],
    );
  }

  Widget serviceCheckListSection(ComplaintDetail complaint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // 🔽 Expand / Collapse Header
        InkWell(
          onTap: () {
            setState(() {
              _isServiceCheckList = !_isServiceCheckList;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Service Checklist",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(
                _isServiceCheckList
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 🔽 Expanded Content
        if (_isServiceCheckList) ...[
          Column(
            children: checklist.map((item) {
              // print("item.title: ${item.title}");
              // print("item.selected: ${item.selected}");
              // print("item.options: ${item.options}");

              return buildChecklistItem(item);
            }).toList(),
          ),
        ],

      ],
    );
  }

  Widget buildChecklistItem(ChecklistItem item) {
    final isEngineOil = item.title == "Engine Oil";
    final isHydraulicOil = item.title == "Hydraulic Oil";
    final isServiceDue = item.title == "Machine Service Due";

    final showQtyField =
        (isEngineOil || isHydraulicOil) && item.selected == "Yes";

    final showDateField =
        isServiceDue && (item.selected == "Yes" || item.selected == "Due");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 🔥 KEY
            children: [
              Expanded(
                flex: 3,

                child: Text(

                  item.title,
                  // textAlign: TextAlign.right, // 👈 KEY CHANGE

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded( // ✅ FIXED (no Align, no Flexible misuse)
                flex: 3,
                child: Wrap(
                  alignment: WrapAlignment.end, // 👈 right align chips
                  spacing: 8,
                  runSpacing: 6,
                  children: item.options.map((option) {
                    final isSelected = item.selected == option;

                    return ChoiceChip(
                      label: Text(option),
                      selected: isSelected,
                      selectedColor: const Color(0xFFDCD3F5),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.blue
                              : Colors.grey.shade300,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          item.selected = option;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          // 🔥 QTY FIELD
          if (showQtyField) ...[
            const SizedBox(height: 10),
            TextFormField(
              controller: isEngineOil
                  ? engineOilQtyController
                  : hydraulicOilQtyController,
              decoration: InputDecoration(
                labelText: "Enter Quantity (e.g. 2L)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],

          // 🔥 DATE PICKER FIELD
          if (showDateField) ...[
            const SizedBox(height: 10),
            TextFormField(
              controller: serviceDueDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Select Service Due Date",
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  setState(() {
                    serviceDueDateController.text =
                    pickedDate.toString().split(' ')[0];
                  });
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget buildHistoryTab(List<ComplaintHistoryModel> historyList) {

    if (historyList.isEmpty) {
      return const Center(
        child: Text(
          "No history found",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: historyList.length,
      itemBuilder: (context, index) {
        final item = historyList[index];
        final isLast = index == historyList.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Timeline Indicator ----
            Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppData.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 3,
                    height: 50,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // ---- History Card ----
            Expanded(
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.status, // ComplaintStatus
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppData.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        item.remarks, // ComplaintRemarks
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            AppData.shared.formatDate(item.addedDateTime),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppData.darkText)),
  );

  Widget infoCard({required List<Widget> children}) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        )
      ],
    ),
    child: Column(children: children),
  );

  Widget infoTile(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 22, color: AppData.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget infoTileWithRight({
    required IconData icon,
    required String label,
    required String leftValue,
    required String rightValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppData.primaryBlue),
          const SizedBox(width: 12),

          // 🔹 Left Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                Text(leftValue,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // 🔹 Right Section (STATUS)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(rightValue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  rightValue,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(rightValue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget statusAndDownloadRow(ComplaintDetail complaint) {
    final status = complaint.status;
    final hasPdf =
        complaint.pdf != null && (complaint.pdf!.pdf.trim().isNotEmpty);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 🔥 STATUS CHIP
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 14, // 👈 change this (try 14–16)
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // 🔥 DOWNLOAD BUTTON
        if (hasPdf)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 10, // 👉 more width padding
                vertical: 8,   // 👉 more height padding
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _downloadPdf,
            icon: const Icon(Icons.download,size: 15,),
            label: const Text(
              "Download Report",
              style: TextStyle(
                fontSize: 14, // 👈 change this (try 14–16)
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    // debugPrint("status $status");
    switch (status.toLowerCase()) {
      case "break down":
        return Colors.red;
      case "completed":
      case "resolved":
        return Colors.green;
      case "pending":
      case "running with issue":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget sectionTitle_details(
      String title, {
        String? trailingText,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // ✅ Leading title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ✅ Trailing text (optional)
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }


  Widget dropdownTile(String label, List<Employee> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5),
      DropdownButtonFormField<Employee>(
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem<Employee>(
            value: e,
            child: Text(e.name), // ✅ show name (String)
          ),
        )
            .toList(),
        onChanged: (Employee? value) {
          if (value == null) return;
          debugPrint("Selected Employee ID: ${value.userId}");
        },
      ),
    ],
  );

  Widget _labelledRow({required Widget label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget seviceEngineerDropdown() {
    return _labelledRow(
      label:  RichText(
        text: const TextSpan(
          text: " Service Engineer",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      child: _isEmployeeLoading
          ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
          : DropdownSearch<Employee>(
        selectedItem: selectedEngineerId == null
            ? null
            : employees.firstWhere(
              (m) => m.userId == selectedEngineerId,
          orElse: () => Employee(userId: '', role: '',name: '',roleId: '',email: ''),
        ),

        items: employees,
        itemAsString: (m) => m.name,

        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Select Service Engineer",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Service Engineer",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        onChanged: (selected) async {
          if (selected == null) return;
          setState(() {
            print("selectedEngineerId $selectedEngineerId");
            selectedEngineerId = selected.userId;
          });
        },
      ),
    );
  }

  Widget partsDropdown(int index) {
    final item = _selectedParts[index];

    return DropdownSearch<PartItem>(
      selectedItem: item['PartId'] == null
          ? null
          : partsList.firstWhere(
            (m) => m.id == item['PartId'],
        orElse: () => PartItem(id: '', name: ''),
      ),

      items: partsList,
      itemAsString: (m) => m.name,

      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Select Parts",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      popupProps: PopupProps.menu(
        showSearchBox: true,
      ),

      onChanged: (selected) {
        if (selected == null) return;

        setState(() {
          _selectedParts[index]['PartId'] = selected.id;
        });
      },
    );
  }

  Widget buildPartsFormSection() {
    if (!_requiredParts) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // 🔽 Header
        InkWell(
          onTap: () {
            setState(() {
              _showPartsForm = !_showPartsForm;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select Parts",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Icon(
                _showPartsForm
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 🔽 FORM CONTENT
        if (_showPartsForm) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedParts.length,
            itemBuilder: (context, index) {
              final item = _selectedParts[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      // 🔽 PART DROPDOWN
                      Expanded(
                        flex: 4,
                        child: partsDropdown(index),
                      ),

                      const SizedBox(width: 10),

                      // 🔽 QUANTITY
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue:
                          (item['Quantity'] as int).toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Qty',
                            isDense: true,
                          ),
                          onChanged: (val) {
                            final q = int.tryParse(val) ?? 1;
                            item['Quantity'] = q;
                          },
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 🔽 DELETE BUTTON
                      IconButton(
                        onPressed: () => _removePartRow(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // 🔽 ADD BUTTON
          ElevatedButton.icon(
            onPressed: _addPartRow,
            icon: const Icon(Icons.add),
            label: const Text("Add Part"),
          ),
        ],
      ],
    );
  }
}
