
import 'dart:convert';

import 'package:crm_app/API/auth_api_service.dart';
import 'package:crm_app/Model/complaint_details_model.dart';
import 'package:crm_app/Model/complaints.dart';
import 'package:crm_app/Model/login_models.dart';
import 'package:crm_app/Model/machine_number_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/app/complaintDetail.dart';
import 'package:crm_app/utilities/globals.dart';
import 'package:crm_app/utilities/user_local_storage.dart';
import 'package:crm_app/app/add_complaint.dart';
import 'package:crm_app/utilities/enums.dart';

import '../Model/employee_list_model.dart';
import '../Model/machine_model.dart';

// // ----------------- Filter Sheet Widget -----------------
class ComplaintFilterSheet extends StatefulWidget {
  final List<Employee> engineers;
  final List<MachineNumber> allMachines;
  final List<MachineModelData> allMachineModels;
  final Employee? initialEngineer;
  final String? initialStatus;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final MachineNumber? initialMachineNo;
  final MachineModelData? initialModel;

  const ComplaintFilterSheet({
    super.key,
    required this.engineers,
    required this.allMachines,
    required this.allMachineModels,
    this.initialEngineer,
    this.initialStatus,
    this.initialStartDate,
    this.initialEndDate,
    this.initialMachineNo,
    this.initialModel,
  });
//
  @override
  State<ComplaintFilterSheet> createState() => _ComplaintFilterSheetState();
}

class _ComplaintFilterSheetState extends State<ComplaintFilterSheet> {
  Employee? engineer;
  MachineNumber? machine;
  MachineModelData? machine_model;
  String? status;
  DateTime? startDate;
  DateTime? endDate;
  // TextEditingController machineNo = TextEditingController();
  // TextEditingController model = TextEditingController();
  List<MachineNumber> machineNumbers = [];
  List<MachineModelData> machineModels = [];
  List<String> serviceEngineers = [];
  String? selectedMachineNumberId;
  String? selectedMachineModelId;
  bool _isMachineNumbersLoading = false;
  bool _isMachineModelsLoading = false;
  final Map<String, List<MachineModelData>> _machineModelCache = {};
  final _authService = AuthApiService(
    'https://dashboard.reachinternational.co.in/development/api',
  );

  @override
  void initState() {
    super.initState();
    engineer = widget.initialEngineer;
    status = widget.initialStatus;
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    machine = widget.initialMachineNo;
    machine_model = widget.initialModel;

    // Access the list from the parent widget
  }


  // ------------------ Get  Machine Models  ----------------
  //---------------------------------------------------------
  Future<void> fetchMachineModelsForMachine(String machineId) async {
    if (machineId.isEmpty) return;
    if (_machineModelCache.containsKey(machineId)) {
      setState(() {
        AppData.machine_models = _machineModelCache[machineId]!;
        if (!AppData.machine_models.any((m) => m.id == selectedMachineModelId)) {
          selectedMachineModelId = null;
        }
      });
      return;
    }
    setState(() => _isMachineModelsLoading = true);
    try {
      final res = await _authService.fetchMachineModel(machine_id: machineId);

      if (res.status == true && res.data != null) {
        final list = _parseListResponse<MachineModelData>(res.data, (m) => MachineModelData.fromJson(m));
        AppData.machine_models = list;
        _machineModelCache[machineId] = list;
        if (!list.any((m) => m.id == selectedMachineModelId)) selectedMachineModelId = null;
      } else {
        debugPrint('fetchMachineModels error: ${res.message}');
        AppData.machine_models = [];
      }
    } catch (e) {
      debugPrint('fetchMachineModels exception: $e');
      AppData.machine_models = [];
    } finally {
      setState(() => _isMachineModelsLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text("Filter Complaints", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            engineerDropDown(),

            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: status,
              items: [
                // const DropdownMenuItem(value: '', child: Text('Any Status')),
                // ...ComplaintStatus.values.map((e) => e.label).toList()
                //     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                //     .toList(),
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('Any Status'),
                ),
                ...ComplaintStatus.values.map(
                      (e) => DropdownMenuItem<String>(
                    value: e.value,       // or e.label if your enum has label
                    child: Text(e.value),
                  ),
                ),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Status",
              ),
              onChanged: (v) => setState(() => status = (v == '') ? null : v),
            ),
            const SizedBox(height: 16),
            dateTile(
              label: "Complaint Date From",
              date: startDate,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => startDate = picked);
              },
            ),
            const SizedBox(height: 12),
            dateTile(
              label: "Complaint Date To",
              date: endDate,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: endDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => endDate = picked);
              },
            ),
            const SizedBox(height: 16),

            machineNumberDropdown(),

            const SizedBox(height: 16),

            machineModelDropdown(),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        "engineer": engineer,
                        "status": status,
                        "startDate": startDate,
                        "endDate": endDate,
                        "machineNo": selectedMachineNumberId == null
                            ? null
                            : AppData.machine_numbers.firstWhere(
                              (m) => m.id == selectedMachineNumberId,
                        ),
                        "model": selectedMachineModelId == null
                            ? null
                            : AppData.machine_models.firstWhere(
                              (m) => m.id == selectedMachineModelId,
                        ),
                      });
                    },
                    child: const Text("Reset"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        "engineer": engineer,
                        "status": status,
                        "startDate": startDate,
                        "endDate": endDate,
                        "machineNo": machine,
                        "model": machine_model,
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppData.primaryBlue),
                    child: const Text("Apply"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

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

  Widget engineerDropDown(){
    return DropdownSearch<Employee>(
      selectedItem: engineer,
      items: AppData.employee_list,

      itemAsString: (e) => e.name,

      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Service Engineer",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose, // 🔥 IMPORTANT FIX
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5, // 👈 LIMIT HEIGHT
        ),
      ),

      onChanged: (value) {
        setState(() {
          engineer = value;
        });
      },
    );
  }

  Widget machineNumberDropdown() {
    return DropdownSearch<MachineNumber>(
      selectedItem: machine,
      items: AppData.machine_numbers,

      itemAsString: (e) => e.machineNo,

      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Machine Number",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose, // 🔥 IMPORTANT FIX
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5, // 👈 LIMIT HEIGHT
        ),
      ),

      onChanged: (selected) async {
        setState(() {
          machine = selected; // ✅ IMPORTANT FIX
          selectedMachineNumberId = selected?.id;
          selectedMachineModelId = null;
          AppData.machine_models = [];
        });
        await fetchMachineModelsForMachine(selected!.id);
      },
    );
  }

  Widget machineModelDropdown() {
    final isDisabled = selectedMachineNumberId == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownSearch<MachineModelData>(
          selectedItem: machine_model,
          items: isDisabled ? [] : AppData.machine_models,

          enabled: !isDisabled, // 🔥 disable if no machine selected

          itemAsString: (e) => e.machineModel,

          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: "Machine Model",
              hintText: isDisabled
                  ? "Select Machine Number first"
                  : "Select Machine Model",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _isMachineModelsLoading
                  ? Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : (machine_model != null
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    machine_model = null;
                  });
                },
              )
                  : null),
            ),
          ),

          popupProps: PopupProps.menu(
            showSearchBox: true,
            fit: FlexFit.loose,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            emptyBuilder: (context, searchEntry) {
              if (_isMachineModelsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Center(child: Text("No models found"));
            },
          ),

          onChanged: (value) {
            setState(() {
              machine_model = value;
            });
          },
        ),

        // 🔥 Helper text
        if (isDisabled)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text(
              "Please select Machine Number first",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget dateTile({required String label, required DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? label : "${date.day}-${date.month}-${date.year}",
              style: TextStyle(
                color: date == null ? Colors.grey : Colors.black,
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (label.contains("From")) startDate = null;
                    else endDate = null;
                  });
                },
                child: const Icon(Icons.clear, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class ComplaintListingPage extends StatefulWidget {
  const ComplaintListingPage({super.key});

  @override
  State<ComplaintListingPage> createState() => _ComplaintListingPageState();
}

class _ComplaintListingPageState extends State<ComplaintListingPage>
    with SingleTickerProviderStateMixin {
  final _authService = AuthApiService(
    'https://dashboard.reachinternational.co.in/development/api',
  );

  // final ScrollController _scrollController = ScrollController();
  final ScrollController _assignedController = ScrollController();
  final ScrollController _unassignedController = ScrollController();
  List<MachineNumber> machineNumbers = [];
  List<MachineModelData> machineModels = [];
  List<Employee> serviceEngineers = [];

  String? selectedMachineNumberId;

  late TabController _tabController;
  List<ComplaintDetail> assignedList = [];
  List<ComplaintDetail> unassignedList = [];

  int _assignedPage = 0;
  int _unassignedPage = 0;

  bool _hasMoreAssigned = true;
  bool _hasMoreUnassigned = true;

  bool _isLoadingAssigned = false;
  bool _isLoadingUnassigned = false;
  bool _isEmployeeLoading = false;

  Employee? filterEngineer;
  String? filterStatus;
  DateTime? filterStartDate;
  DateTime? filterEndDate;
  MachineNumber? filterMachineNo;
  MachineModelData? filterModel;
  bool _isMachineNumbersLoading = false;
  UserData? currentUser;

  int get activeFiltersCount => [
    filterEngineer,
    filterStatus,
    filterStartDate,
    filterEndDate,
    filterMachineNo,
    filterModel
  ].where((e) => e != null && e.toString().trim().isNotEmpty).length;

  void openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ComplaintFilterSheet(
        allMachines: machineNumbers,
        allMachineModels: machineModels,
        engineers: serviceEngineers,
        initialEngineer: filterEngineer,
        initialStatus: filterStatus,
        initialStartDate: filterStartDate,
        initialEndDate: filterEndDate,
        initialMachineNo: filterMachineNo,
        initialModel: filterModel,
      ),
    );
    if (result != null) {
      setState(() {
        filterEngineer = result["engineer"];
        filterStatus = result["status"];
        filterStartDate = result["startDate"];
        filterEndDate = result["endDate"];
        filterMachineNo = result["machineNo"];
        filterModel = result["model"];
      });

      // ✅ CALL FILTER API
      _fileterComplaints(
        page: 0,
        type: _tabController.index == 0 ? 1 : 0,
      );
    }
  }//Openfilter
  // Clear all filters
  void clearFilters() {
    setState(() {
      filterEngineer = null;
      filterStatus = null;
      filterStartDate = null;
      filterEndDate = null;
      filterMachineNo = null;
      filterModel = null;
    });

    _reloadComplaints(_tabController.index == 0 ? 1 : 0);
  }

  List<ComplaintDetail> applyFilters(List<ComplaintDetail> list) {
    return list.where((c) {

      final matchesStatus =
          filterStatus == null ||
              filterStatus!.isEmpty ||
              c.status == filterStatus;
      final matchesEngineer =
          filterEngineer == null ||
              c.assignee.trim() == filterEngineer!.name.trim();

      final matchesMachine =
          filterMachineNo == null ||
              c.machine_no.trim() == filterMachineNo!.machineNo.trim();

      final matchesModel =
          filterModel == null ||
              c.machineModel.trim() == filterModel!.machineModel.trim();

      // ✅ Date filter
      bool matchesDate = true;
      if (filterStartDate != null || filterEndDate != null) {
        final compDate = parseHumanDate(c.createdDate);

        if (compDate == null) return false;

        if (filterStartDate != null &&
            compDate.isBefore(DateTime(
              filterStartDate!.year,
              filterStartDate!.month,
              filterStartDate!.day,
            ))) {
          matchesDate = false;
        }

        if (filterEndDate != null &&
            compDate.isAfter(DateTime(
              filterEndDate!.year,
              filterEndDate!.month,
              filterEndDate!.day,
            ).add(const Duration(days: 1)))) {
          matchesDate = false;
        }
      }

      return matchesEngineer &&
          matchesStatus &&
          matchesMachine &&
          matchesModel &&
          matchesDate;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    getComplaintCount();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      if (_tabController.index == 0) {
        if (assignedList.isEmpty) {
          _reloadComplaints(1);
        }
      } else {
        if (unassignedList.isEmpty) {
          currentUser?.role == UserRole.serviceEngineer.label?
          _reloadComplaints(2):_reloadComplaints(0);
        }
      }
    });

    _assignedController.addListener(() {
      _handleScroll(_assignedController, 1); // type 1 = Assigned
    });

    _unassignedController.addListener(() {
      currentUser?.role == UserRole.serviceEngineer.label?_handleScroll(_unassignedController, 2):_handleScroll(_unassignedController, 0); // type 0 = Unassigned/Solved
    });

    _initData();
    checkSession(context);
  }

  Future<void> getComplaintCount() async {
    final user = await UserLocalStorage.getSavedUser();
    try {
      final res = await _authService.getComplaintCountAPI(
          user_id: user!.userId,
          role_id: user.roleId
      );
      if (res.status == true) {
        AppData.assigned_complaints_count = res.assignedComplaints;
        AppData.unassigned_complaint_count = res.unassignedComplaints;
        AppData.resolved_complaint_count = res.resolvedComplaints;
        debugPrint('assignedComplaints: ${res.assignedComplaints}');
        debugPrint('unassignedComplaints: ${res.unassignedComplaints}');
        debugPrint('resolvedComplaints: ${res.resolvedComplaints}');
      } else {
        debugPrint('getComplaintCount error: ${res.status}');
      }
    } catch (e) {
      debugPrint('getComplaintCount exception: $e');
    } finally {
      setState(() => _isEmployeeLoading = false);
    }
  }

  void _handleScroll(ScrollController controller, int type) {
    if (!controller.hasClients) return;

    final isAssigned = type == 1;

    final page = isAssigned ? _assignedPage : _unassignedPage;
    final hasMore = isAssigned ? _hasMoreAssigned : _hasMoreUnassigned;
    final isLoading = isAssigned ? _isLoadingAssigned : _isLoadingUnassigned;

    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore) {
      _fetchComplaints(page: page + 1, type: type);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _reloadByType(int type) async {
    setState(() {
      if (type == 1) {
        assignedList.clear();
        _assignedPage = 0;
        _hasMoreAssigned = true;
      } else {
        unassignedList.clear();
        _unassignedPage = 0;
        _hasMoreUnassigned = true;
      }
    });

    await _fetchComplaints(page: 0, type: type);
  }

  Future<void> checkSession(BuildContext context) async {
    bool expired = await UserLocalStorage.isSessionExpired();

    if (expired) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  Future<void> _initData() async {
    currentUser = await UserLocalStorage.getSavedUser();
    await _reloadComplaints(1);
    fetchMachineNumbers();
  }

  /// 🔹 Reload from page 1
  Future<void> _reloadComplaints(int type) async {
    debugPrint("RelaodType -> $type");
    setState(() {
      if (type == 1) {
        assignedList.clear();
        _assignedPage = 0;
        _hasMoreAssigned = true;
      } else {
        unassignedList.clear();
        _unassignedPage = 0;
        _hasMoreUnassigned = true;
      }
    });

    await _fetchComplaints(page: 0, type: type);
  }

  void _onTabChanged(int index) {
    if (index == 0) {
      if (assignedList.isEmpty) {
        _reloadByType(1);
      }
    } else {
      if (unassignedList.isEmpty) {
        currentUser?.role == UserRole.serviceEngineer.label?
        _reloadByType(2):_reloadByType(0);
      }
    }
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


  // ------------------ Get  Machine number  ----------------
  //---------------------------------------------------------
  Future<void> fetchMachineNumbers() async {
    setState(() => _isMachineNumbersLoading = true);
    try {
      final res = await _authService.fetchMachineNumber();
      debugPrint("RAW RESPONSE: ${jsonEncode(res.data?.toJson())}");
      if (res.status == true && res.data != null) {
        final list = _parseListResponse<MachineNumber>(
          res.data,
              (m) => MachineNumber.fromJson(m),
        );
        AppData.machine_numbers = list;
        debugPrint('fetchMachineNumbers data: ${res.data}');
        print(AppData.machine_numbers);
        // ensure previously selected id still valid
        if (!list.any((m) => m.id == selectedMachineNumberId)) {
          selectedMachineNumberId = null;
        }
      } else {
        debugPrint('fetchMachineNumber error: ${res.message}');
        AppData.machine_numbers = [];
      }
    } catch (e) {
      debugPrint('fetchMachineNumber exception: $e');
      AppData.machine_numbers = [];
    } finally {
      setState(() => _isMachineNumbersLoading = false);
    }
  }

  Future<void> _fetchComplaints({
    required int page,
    required int type,
  }) async {
    final isAssigned = type == 1;

    // ✅ separate loading per tab
    if (isAssigned && _isLoadingAssigned) return;
    if (!isAssigned && _isLoadingUnassigned) return;

    // ✅ stop if no more data
    if (isAssigned && !_hasMoreAssigned) return;
    if (!isAssigned && !_hasMoreUnassigned) return;

    setState(() {
      if (isAssigned) {
        _isLoadingAssigned = true;
      } else {
        _isLoadingUnassigned = true;
      }
    });

    try {
      final res = await _authService.complaints(
        user_id: currentUser!.userId,
        role_id: currentUser!.roleId,
        page_start: page,
        type: type,
      );

      if (res.status == true && res.data != null) {
        final List<ComplaintDetail> newData = res.data;

        setState(() {
          if (isAssigned) {
            assignedList.addAll(newData);
            _assignedPage = page;

            if (newData.isEmpty) {
              _hasMoreAssigned = false;
            }
          } else {
            unassignedList.addAll(newData);
            _unassignedPage = page;

            if (newData.isEmpty) {
              _hasMoreUnassigned = false;
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Pagination error: $e");
    } finally {
      setState(() {
        if (isAssigned) {
          _isLoadingAssigned = false;
        } else {
          _isLoadingUnassigned = false;
        }
      });
    }
  }


  Future<void> _fileterComplaints({
    required int page,
    required int type,
  }) async {
    final isAssigned = type == 1;

    setState(() {
      if (isAssigned) {
        _isLoadingAssigned = true;
      } else {
        _isLoadingUnassigned = true;
      }
    });

    try {
      final res = await _authService.searchfilter(
        from_date: filterStartDate != null
            ? "${filterStartDate!.year}-${filterStartDate!.month}-${filterStartDate!.day}"
            : "",
        to_date: filterEndDate != null
            ? "${filterEndDate!.year}-${filterEndDate!.month}-${filterEndDate!.day}"
            : "",
        status: filterStatus ?? "",
        userid: filterEngineer?.userId ?? "",
        machine_id: filterMachineNo?.id ?? "",
        keyword: "",
      );

      if (res.status == true && res.data != null) {
        final List<ComplaintDetail> newData = res.data;

        setState(() {
          if (isAssigned) {
            assignedList = newData;
            _hasMoreAssigned = false;
          } else {
            unassignedList = newData;
            _hasMoreUnassigned = false;
          }
        });
      }
    } catch (e) {
      debugPrint("Filter error: $e");
    } finally {
      setState(() {
        if (isAssigned) {
          _isLoadingAssigned = false;
        } else {
          _isLoadingUnassigned = false;
        }
      });
    }
  }

  void assignComplaint(ComplaintDetail complaint, String engineerName) {
    setState(() {
      complaint.assignee = engineerName;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
          content: Text(
              'Complaint ${complaint.complaintId} assigned to $engineerName.')));
    });
  }

  void refresh(ComplaintDetail c) {
    setState(() {});
  }

  DateTime? parseHumanDate(String? s) {
    if (s == null) return null;
    // Remove commas
    final cleaned = s.replaceAll(',', '');
    // Remove ordinal suffixes: st, nd, rd, th
    final withoutOrdinal = cleaned.replaceAllMapped(
        RegExp(r'(\d+)(st|nd|rd|th)'), (m) => m.group(1) ?? '');
    final parts = withoutOrdinal.split(RegExp(r'\s+'));
    if (parts.length < 3) {
      // try DateTime.parse fallback
      try {
        return DateTime.parse(cleaned);
      } catch (_) {
        return null;
      }
    }
    // Expected: [day, monthName, year] but day might be numeric (e.g., "22", "5")
    final dayStr = parts[0];
    final monthStr = parts[1];
    final yearStr = parts.length >= 3 ? parts[2] : '';
    final day = int.tryParse(dayStr);
    final year = int.tryParse(yearStr);
    final months = {
      'january': 1,
      'february': 2,
      'march': 3,
      'april': 4,
      'may': 5,
      'june': 6,
      'july': 7,
      'august': 8,
      'september': 9,
      'october': 10,
      'november': 11,
      'december': 12,
    };
    final month = months[monthStr.toLowerCase()];
    if (day != null && month != null && year != null) {
      return DateTime(year, month, day);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final assignedComplaints = applyFilters(assignedList);
    final unassignedComplaints = applyFilters(unassignedList);

    return DefaultTabController(
        length: 2,
        child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppData.primaryBlue,
          title: const Text("Service Complaints",
              style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Stack(
                alignment: Alignment.topRight,
                children: [
                  const Icon(Icons.filter_list, color: Colors.white),
                  if (activeFiltersCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                            minWidth: 16, minHeight: 16),
                        child: Center(
                          child: Text(
                            '$activeFiltersCount',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: openFilterSheet,
            ),
          ],

          bottom: TabBar(
            controller: _tabController,   // 👈 IMPORTANT
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54, // unselected tab text
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: "Assigned (${assignedComplaints.length} of ${AppData.assigned_complaints_count})",
                icon: const Icon(Icons.check_circle_outline),
              ),
              Tab(
                text: currentUser?.role == UserRole.serviceEngineer.label
                    ? "Resolved (${unassignedComplaints.length} of ${AppData.resolved_complaint_count})"
                    : "Unassigned (${unassignedComplaints.length} of ${AppData.unassigned_complaint_count})",
                icon: const Icon(Icons.warning_amber),
              ),
            ],
          ),
        ),

        body: Column(
          children: [
            // Optional: show active filter chips and clear button
            if (activeFiltersCount > 0)
              Padding(
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 10, bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (filterEngineer != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  backgroundColor: Colors.grey.shade200,
                                  label: Text('Engineer: ${filterEngineer!.name}')
                                ),
                              ),
                            if (filterStatus != null && filterStatus!
                                .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  backgroundColor: Colors.grey.shade200,
                                  label: Text('Status: ${filterStatus!}'),
                                ),
                              ),
                            if (filterStartDate != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  backgroundColor: Colors.grey.shade200,
                                  label: Text('From: ${filterStartDate!
                                      .day}-${filterStartDate!
                                      .month}-${filterStartDate!.year}'),
                                ),
                              ),
                            if (filterEndDate != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  backgroundColor: Colors.grey.shade200,
                                  label: Text('To: ${filterEndDate!
                                      .day}-${filterEndDate!
                                      .month}-${filterEndDate!.year}'),
                                ),
                              ),
                            if (filterMachineNo != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  backgroundColor: Colors.grey.shade200,
                                  label: Text('Machine: ${filterMachineNo!}'),
                                ),
                              ),
                            if (filterModel != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  backgroundColor: Colors.grey.shade200,
                                  label: Text('Model: ${filterModel!}'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: clearFilters,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
            // Expanded TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ComplaintListView(
                    scrollController: _assignedController,
                    complaints: assignedComplaints,
                    onReload: () => _reloadComplaints(1), // ✅ FIX
                    isAssignedList: true,
                    serviceEngineers: serviceEngineers,
                    machineNumbers: machineNumbers,
                    onAssign: assignComplaint,
                    onStatusUpdate: refresh,
                    current_user: currentUser,
                  ),

                  ComplaintListView(
                    scrollController: _unassignedController,
                    complaints: unassignedComplaints,
                    onReload: () => currentUser?.role == UserRole.serviceEngineer.label?_reloadComplaints(2):_reloadComplaints(0), // ✅ FIX
                    isAssignedList: false,
                    serviceEngineers: serviceEngineers,
                    machineNumbers: machineNumbers,
                    onAssign: assignComplaint,
                    onStatusUpdate: refresh,
                    current_user: currentUser,
                  ),
                ],
              )
            ),
          ],
        ),
//         // ✅ ADD THIS
        floatingActionButton: currentUser?.role == UserRole.serviceEngineer.label
            ? null
            : FloatingActionButton.extended(
          backgroundColor: AppData.primaryBlue,
          onPressed: () async {
            final shouldReloadAddComplaint = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddComplaintPage(),
              ),
            );
          },
          label: const Text(
            "Add Complaint",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),

        // ✅ This keeps it bottom-right (default)
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

extension on List<MachineNumber> {
  Object? toJson() {}
}

class ComplaintListView extends StatelessWidget {
  final ScrollController scrollController;   // 👈 add this
  final List<ComplaintDetail> complaints;
  final Future<void> Function() onReload;
  final List<Employee> serviceEngineers;
  final List<MachineNumber> machineNumbers;
  final Function(ComplaintDetail, String) onAssign;
  final bool isAssignedList;
  final Function(ComplaintDetail) onStatusUpdate;
  final UserData? current_user;

  const ComplaintListView({
    super.key,
    required this.scrollController,  // 👈 add
    required this.complaints,
    required this.onReload,
    required this.serviceEngineers,
    required this.machineNumbers,
    required this.onAssign,
    required this.isAssignedList,
    required this.onStatusUpdate,
    required this.current_user,
  });


  @override
  Widget build(BuildContext context) {
    if (complaints.isEmpty) {
      return Center(
        child: Text("No complaints found",
            style: TextStyle(fontSize: 16, color: AppData.primaryBlue)),
      );
    }
    return ListView.separated(
      controller: scrollController,   // 👈 important
      padding: const EdgeInsets.all(12),
      itemCount: complaints.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        final isResolved = complaint.status == ComplaintStatus.resolved.string;
        return
          ComplaintCard(
            complaint: complaint,
            onReload: onReload,
            onStatusUpdate: onStatusUpdate,
            machineModels: [],
            machineNumbers: [],
            serviceEngineers: [],
            isAssignedList:complaint.assigned_to == "" ? false : true,
          );
      },
    );
  }

  void showUpdateStatusPopup(BuildContext context, ComplaintDetail complaint,
      Function(ComplaintStatus, String) onUpdate) {
    String? selectedStatus;
    TextEditingController remarksController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 10),
          // ✅ reduced left-right space

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,

          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          // ✅ smaller internal padding
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          // ✅ reduced

          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Update Complaint",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Status"),
              const SizedBox(height: 6),
              const DropdownMenuItem<String>(
                value: '',
                child: Text('Any Status'),
              ),
              ...ComplaintStatus.values.map(
                    (e) => DropdownMenuItem<String>(
                  value: e.value,       // or e.label if your enum has label
                  child: Text(e.value),
                ),
              ),

              const SizedBox(height: 16),
              const Text("Remarks"),
              const SizedBox(height: 6),

              TextField(
                controller: remarksController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Remarks",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          actionsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          // ✅ tighter button spacing

          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppData.primaryBlue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
              ),
              onPressed: () {
                if (selectedStatus != null) {
                  onUpdate(selectedStatus as ComplaintStatus,
                      remarksController.text);
                }
                Navigator.pop(context);
              },
              child: const Text("Update Status"),
            ),
          ],
        );
      },
    );
  }
}


class ComplaintCard extends StatelessWidget {
  final ComplaintDetail complaint;
  final Future<void> Function() onReload;
  final List<String> machineNumbers;
  final List<String> machineModels;
  final List<String> serviceEngineers;
  // final Function(ComplaintDetail, String) onAssign;
  final bool isAssignedList;
  final Function(ComplaintDetail) onStatusUpdate;
  // final UserData? current_user;


  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onReload,
    required this.machineNumbers,
    required this.machineModels,
    required this.serviceEngineers,
    required this.onStatusUpdate,
    required this.isAssignedList,
  });

  @override
  Widget build(BuildContext context) {
    final isResolved = complaint.status == ComplaintStatus.resolved.string;

    void showUpdateStatusPopup(BuildContext context, ComplaintDetail complaint,
        Function(ComplaintStatus, String) onUpdate) {
      String? selectedStatus;
      TextEditingController remarksController = TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 10),
            // ✅ reduced left-right space

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,

            titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            // ✅ smaller internal padding
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            // ✅ reduced

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Update Complaint",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Status"),
                const SizedBox(height: 6),
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('Any Status'),
                ),
                ...ComplaintStatus.values.map(
                      (e) => DropdownMenuItem<String>(
                    value: e.value,       // or e.label if your enum has label
                    child: Text(e.value),
                  ),
                ),

                const SizedBox(height: 16),
                const Text("Remarks"),
                const SizedBox(height: 6),

                TextField(
                  controller: remarksController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Remarks",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),

            actionsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            // ✅ tighter button spacing

            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppData.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
                onPressed: () {
                  if (selectedStatus != null) {
                    onUpdate(selectedStatus as ComplaintStatus,
                        remarksController.text);
                  }
                  Navigator.pop(context);
                },
                child: const Text("Update Status"),
              ),
            ],
          );
        },
      );
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      color: isResolved ? Colors.green.shade50 : Colors.white,
      child:
      ListTile(
        title: Text(
          "${AppData.shared.formatDate(complaint.createdDate)} • ${complaint.cityName}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppData.primaryBlue,
            fontSize: 14,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complaint No: ${complaint.complaint_no}',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              'Machine No: ${complaint.machine_no}',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500),
            ),
        Text(
              'Model: ${complaint.machineModel}',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              'Complaint: ${complaint.complaint}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  !isAssignedList ? "" : ("Assignee: ${complaint.assignee}" ?? "-"),
                  style: TextStyle(
                    color: !isAssignedList ? Colors.black : AppData
                        .primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            if (complaint.status == ComplaintStatus.open)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 6),

                  child: Text(
                    "Click here to Acknowledge",
                    style: TextStyle(
                      color: AppData.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),

        trailing: GestureDetector(
          onTap: () {
            showUpdateStatusPopup(
              context,
              complaint,
                  (newStatus, remarks) {
                complaint.status = newStatus.string;
                onStatusUpdate(complaint);
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppData.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              complaint.status,
              style: TextStyle(
                color: isResolved ? Colors.green : AppData.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        onTap: () async {
          final shouldReload = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComplaintDetailPage(
                complaint: complaint,
                serviceEngineers: serviceEngineers,
                machineNumbers: machineNumbers,
                onAcknowledge: () {
                  complaint.status = complaint.status;
                },
              ),
            ),
          );

          if (shouldReload == true) {
            await onReload();
          }
        },
      ),
    );
  }
}


// Example usage to run the app
void main() {
  runApp(const MaterialApp(home: ComplaintListingPage()));
}
