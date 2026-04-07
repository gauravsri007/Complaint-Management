import 'dart:convert';
import 'dart:io';
import 'package:crm_app/API/auth_api_service.dart';
import 'package:crm_app/Model/city_model.dart';
import 'package:crm_app/Model/machine_model.dart';
import 'package:crm_app/Model/machine_number_model.dart';
import 'package:crm_app/Model/state_model.dart';
import 'package:crm_app/utilities/enums.dart';
import 'package:crm_app/utilities/globals.dart';
import 'package:crm_app/utilities/user_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';


class AddComplaintPage extends StatefulWidget {
  const AddComplaintPage({super.key});

  @override
  State<AddComplaintPage> createState() => _AddComplaintPageState();
}

const Color kPrimaryBlue = Color(0xFF1D648B);

class _AddComplaintPageState extends State<AddComplaintPage> {
  final ImagePicker picker = ImagePicker();
  final _authService =
  AuthApiService('https://dashboard.reachinternational.co.in/development/api');

  // UI controllers
  final TextEditingController machineNoController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController complaintController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController pendingWorkController = TextEditingController();
  final TextEditingController hourController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();

  // images
  List<XFile> pickedImages = [];

  // selected ids (use ids everywhere to avoid duplicate/value errors)
  String? selectedStateId;
  String? selectedCityId;
  String? selectedMachineNumberId;
  String? selectedMachineModelId;
  String? selectedStatus; // status string value from enum

  // loading flags
  bool _isStatesLoading = false;
  bool _isCitiesLoading = false;
  bool _isMachineNumbersLoading = false;
  bool _isMachineModelsLoading = false;
  bool _isSubmitting = false;

  late final double SPACE_BETWEEN_FIELDS = 15;

  // simple caches to avoid repeated network calls
  final Map<String, List<CityModel>> _citiesCache = {};
  final Map<String, List<MachineModelData>> _machineModelCache = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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

  Future<void> _loadInitialData() async {
    // Fire and forget: fetch states and machine numbers in background
    fetchStatesInBackground();
    fetchMachineNumbers();
    // Note: we don't populate machineNumbers/machineModels from AppData.allComplaints here --
    // use API responses / AppData.* where necessary.
  }

  // ----------------------- API calls ----------------------
  //---------------------------------------------------------

// Also replace fetchStatesInBackground() similarly (optional but recommended)


  // -------------------- Add Complaint  --------------------
  //---------------------------------------------------------

  Future<void> add_complaint() async {
    if (_isSubmitting) return;
    // basic validation
    // debugPrint('selectedStateId: $selectedStateId');
    if (
        selectedStateId == null ||
        selectedCityId == null ||
        // selectedStatus == null ||
        // selectedMachineNumberId == null ||
        hourController.text.trim().isEmpty ||
        complaintController.text.trim().isEmpty
    ) {
      debugPrint('selectedStateId -> $selectedStateId');
      debugPrint('selectedCityId -> $selectedCityId');
      debugPrint('selectedStatus -> $selectedStatus');
      debugPrint('hourController.text -> $hourController.text');
      debugPrint('complaintController.text -> $complaintController.text');
      _showError("Please fill all mandatory fields.");
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      debugPrint('-----------------------------1------------------------------');
      final user = await UserLocalStorage.getSavedUser();
      final res = await _authService.addComplaint(
        machine_id: selectedMachineNumberId!,
        machine_model: selectedMachineModelId!,
        hour_meter: hourController.text.trim(),
        userId: user!.userId,
        complaint: complaintController.text.trim(),
        state: selectedStateId!,
        pending_work: pendingWorkController.text.trim(),
        city_id: selectedCityId!,
        contact_person_name:contactPersonController.text.trim() ,
        contact_person_number: contactNumberController.text.trim(),
          complaintImagePath:
          (pickedImages != null && pickedImages!.isNotEmpty)
              ? pickedImages!.first.path
              : null, // File picker result
      );
      debugPrint('-------------------------------2-----------------------------');

      if (res.status == true) {
        // success dialog then pop with success flag
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text("Success", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text(res.message ?? "Complaint submitted successfully."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context, true); // pop page and return true
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        _showError(res.message ?? "Failed to submit complaint.");
      }
    } catch (e) {
      debugPrint('addComplaint exception: $e');
      _showError("Failed to submit complaint. Please try again.");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ----------------------- Get States  --------------------
  //---------------------------------------------------------

  Future<void> fetchStatesInBackground() async {
    setState(() => _isStatesLoading = true);
    try {
      final res = await _authService.fetchStates();
      if (res.status == true && res.data != null) {
        final list = _parseListResponse<StateModel>(
          res.data,
              (m) => StateModel.fromJson(m),
        );
        AppData.states = list;
      } else {
        debugPrint('fetchStates error: ${res.message}');
        AppData.states = [];
      }
    } catch (e) {
      debugPrint('fetchStates exception: $e');
      AppData.states = [];
    } finally {
      setState(() => _isStatesLoading = false);
    }
  }

  // ---------------------- Get  Cities  --------------------
  //---------------------------------------------------------
  Future<void> fetchCitiesForState(String stateId) async {
    if (stateId.isEmpty) return;
    debugPrint("fetchCitiesForState: $stateId");
    debugPrint("selectedCityId: $selectedCityId");
    debugPrint("selectedstateId: $stateId}");

    if (_citiesCache.containsKey(stateId)) {
      setState(() {
        AppData.cities = _citiesCache[stateId]!;
        if (!AppData.cities.any((c) => c.id == selectedCityId)) selectedCityId = null;
      });
      return;
    }

    setState(() => _isCitiesLoading = true);
    try {
      final res = await _authService.fetchCities(state_id: stateId);
      debugPrint("RAW RESPONSE: ${jsonEncode(res.data?.toJson())}");

      if (res.status == true && res.data != null) {
        final list = _parseListResponse<CityModel>(res.data, (m) => CityModel.fromJson(m));
        AppData.cities = list;
        _citiesCache[stateId] = list;
        if (!list.any((c) => c.id == selectedCityId)) selectedCityId = null;
      } else {
        debugPrint('fetchCities error: ${res.message}');
        AppData.cities = [];
      }
    } catch (e) {
      debugPrint('fetchCities exception: $e');
      AppData.cities = [];
    } finally {
      setState(() => _isCitiesLoading = false);
    }
  }

  // ------------------ Get  Machine number  ----------------
  //---------------------------------------------------------
  Future<void> fetchMachineNumbers() async {
    setState(() => _isMachineNumbersLoading = true);
    try {
      final res = await _authService.fetchMachineNumber();

      if (res.status == true && res.data != null) {
        final list = _parseListResponse<MachineNumber>(
          res.data,
              (m) => MachineNumber.fromJson(m),
        );
        AppData.machine_numbers = list;
        print("AppData.machine_numbers");
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

  // -------------------- Image picker helpers --------------------

  Future<void> pickImages() async {
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() => pickedImages.addAll(images));
    }
  }

  // -------------------- Reusable widgets --------------------

  // Widget _labelledRow({required String label, required Widget child}) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Expanded(flex: 4, child: Text(label, style: const TextStyle(color: Colors.black))),
  //       const SizedBox(width: 8),
  //       Expanded(flex: 6, child: child),
  //     ],
  //   );
  // }

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


  Widget _dropdownFormField<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: items.isEmpty ? null : value,
      items: items,
      onChanged: onChanged,
      hint: hint != null ? Text(hint) : null,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Container(height: 1, color: Colors.black26),
  );


  Widget stateDropdown() {
    return _labelledRow(
      label:  RichText(
        text: const TextSpan(
          text: "State",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: " *",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      child: _isMachineNumbersLoading
          ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
          : DropdownSearch<StateModel>(
        selectedItem: selectedStateId == null
            ? null
            : AppData.states.firstWhere(
              (m) => m.id == selectedStateId,
          orElse: () => StateModel(id: '', name: ''),
        ),

        items: AppData.states,
        itemAsString: (m) => m.name,

        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Select State",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search State",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        onChanged: (selected) async {
          if (selected == null) return;
          setState(() {
            selectedStateId = selected.id;
            selectedCityId = null;
            AppData.cities = [];
          });

          await fetchCitiesForState(selected.id);
        },
      ),
    );
  }

  Widget cityDropdown() {
    return _labelledRow(
      label:  RichText(
        text: const TextSpan(
          text: "City",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: " *",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      child: _isCitiesLoading
          ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
          : DropdownSearch<CityModel>(
        selectedItem: selectedCityId == null
            ? null
            : AppData.cities.firstWhere(
              (m) => m.id == selectedCityId,
          orElse: () => CityModel(id: '', name: ''),
        ),

        items: AppData.cities,
        itemAsString: (m) => m.name,

        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Select City",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search City",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        onChanged: (selected) async {
          if (selected == null) return;
          setState(() {
            selectedCityId = selected.id;
          });
        },
      ),
    );
  }

  Widget cityDropdown_() {
    final items = AppData.cities
        .map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name)))
        .toList();

    return _labelledRow(
      label: RichText(
        text: const TextSpan(
          text: "City",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: " *",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: _isCitiesLoading
          ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
          : _dropdownFormField<String>(
        value: selectedCityId,
        items: items,
        hint: "Select City",
        onChanged: (v) => setState(() => selectedCityId = v),
      ),
    );
  }


  Widget machineNumberDropdown() {
    return _labelledRow(
      label: RichText(
        text: const TextSpan(
          text: "Machine Number",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: " *",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // "Machine Number",
      child: _isMachineNumbersLoading
          ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
          : DropdownSearch<MachineNumber>(
        selectedItem: selectedMachineNumberId == null
            ? null
            : AppData.machine_numbers.firstWhere(
              (m) => m.id == selectedMachineNumberId,
          orElse: () => MachineNumber(id: '', machineNo: '', machineModel: '', machineSrNo: ''),
        ),

        items: AppData.machine_numbers,
        itemAsString: (m) => m.machineNo,

        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Select Machine Number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search machine number...",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        onChanged: (selected) async {
          if (selected == null) return;
          setState(() {
            selectedMachineNumberId = selected.id;
            selectedMachineModelId = null;
            AppData.machine_models = [];
          });

          await fetchMachineModelsForMachine(selected.id);
        },
      ),
    );
  }

  Widget machineModelDropdown() {
    return _labelledRow(
      label: RichText(
        text: const TextSpan(
          text: "Machine Model",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: " *",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // label:
      // "Machine Model",
      child: _isMachineModelsLoading
          ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
          : DropdownSearch<MachineModelData>(
        selectedItem: selectedMachineModelId == null
            ? null
            : AppData.machine_models.firstWhere(
              (m) => m.machineModel == selectedMachineModelId,
          orElse: () => MachineModelData(id: '', machineNo: '', machineModel: '', machineSrNo: ''),
        ),

        items: AppData.machine_models,
        itemAsString: (m) => m.machineModel,

        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Select Machine Model",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search machine model...",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        onChanged: (selected) async {
          if (selected == null) return;
          setState(() {
            selectedMachineModelId = selected.machineModel;
            debugPrint("selectedMachineModelId: ${selectedMachineModelId}");

          });
        },
      ),
    );
  }


  Widget statusDropdown() {
    // I assume ComplaintStatus has properties `value` (string) and `name` (label)
    final items = ComplaintStatus.values
        .map((c) => DropdownMenuItem<String>(value: c.value, child: Text(c.name)))
        .toList();

    return _labelledRow(
      label: RichText(
        text: const TextSpan(
          text: "Machine Number",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: " *",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // label: "Status",
      child: _dropdownFormField<String>(
        value: selectedStatus,
        items: items,
        hint: "Select Status",
        onChanged: (v) => setState(() => selectedStatus = v),
      ),
    );
  }

  // -------------------- Build --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Complaint", style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            machineNumberDropdown(),
            // divider(),
            SizedBox(height: SPACE_BETWEEN_FIELDS),

            machineModelDropdown(),
            // divider(),
            SizedBox(height: 12),


            _labelledRow(
              label: RichText(
                text: const TextSpan(
                  text: "Contact Person Name",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // label: "Hour meter",
              child: TextField(
                controller: contactPersonController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: "Enter Cotact Person Name ..",
                  isDense: true,
                  border: UnderlineInputBorder(),
                ),
              ),
              // label: "Hour meter",
            ),
            SizedBox(height: SPACE_BETWEEN_FIELDS),

            _labelledRow(
              label: RichText(
                text: const TextSpan(
                  text: "Contact Person Number",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // label: "Hour meter",
              child: TextField(
                controller: contactNumberController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: "Enter Cotact Person Number ..",
                  isDense: true,
                  border: UnderlineInputBorder(),
                ),
              ),
              // label: "Hour meter",
            ),

            SizedBox(height: SPACE_BETWEEN_FIELDS),

            _labelledRow(
              label: RichText(
                text: const TextSpan(
                  text: "Hour Value",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // label: "Hour meter",
              child: TextField(
                controller: hourController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: "Enter an hour value ..",
                  isDense: true,
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            // divider(),
            SizedBox(height: SPACE_BETWEEN_FIELDS),

            _labelledRow(
              label: RichText(
                text: const TextSpan(
                  text: "Complaint",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // label: "Complaint",
              child: TextField(
                controller: complaintController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Enter a Complaint",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: SPACE_BETWEEN_FIELDS),

            _labelledRow(
              label: RichText(
                text: const TextSpan(
                  text: "Pending Work",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  // children: [
                  //   TextSpan(
                  //     text: "",
                  //     style: TextStyle(
                  //       color: Colors.red,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ],
                ),
              ),
              // label: "Complaint",
              child: TextField(
                controller: pendingWorkController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Enter Pending Work",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: SPACE_BETWEEN_FIELDS),
            // statusDropdown(),
            SizedBox(height: SPACE_BETWEEN_FIELDS),

            stateDropdown(),
            // divider(),
            SizedBox(height: SPACE_BETWEEN_FIELDS),

            cityDropdown(),
            // divider(),
            SizedBox(height: SPACE_BETWEEN_FIELDS),

            SizedBox(height: SPACE_BETWEEN_FIELDS),
            const Text("Upload Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: SPACE_BETWEEN_FIELDS),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
              child: Column(children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final XFile? image = await picker.pickImage(source: ImageSource.camera);
                      if (image != null) setState(() => pickedImages.add(image));
                    },
                    icon: const Icon(Icons.photo_camera),
                    label: const Text("Pick from Camera"),
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue),
                  ),
                ),
                SizedBox(height: SPACE_BETWEEN_FIELDS),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Pick from Gallery"),
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            pickedImages.isNotEmpty
                ? SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: pickedImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return Stack(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(pickedImages[index].path), height: 90, width: 90, fit: BoxFit.cover)),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => pickedImages.removeAt(index)),
                        child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), padding: const EdgeInsets.all(4), child: const Icon(Icons.close, color: Colors.white, size: 16)),
                      ),
                    ),
                  ]);
                },
              ),
            )
                : const SizedBox.shrink(),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : add_complaint,
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50)),
                child: _isSubmitting ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("Submit Complaint", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

extension on List<CityModel> {
  toJson() {}
}


// import 'dart:io';                          // ✅ REQUIRED for File()
// import 'package:crm_app/API/auth_api_service.dart';
// import 'package:crm_app/Model/city_model.dart';
// import 'package:crm_app/Model/machine_model.dart';
// import 'package:crm_app/Model/machine_number_model.dart';
// import 'package:crm_app/Model/state_model.dart';
// import 'package:crm_app/utilities/enums.dart';
// import 'package:crm_app/utilities/globals.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// class AddComplaintPage extends StatefulWidget {
//   AddComplaintPage({super.key});
//
//   @override
//   State<AddComplaintPage> createState() => _AddComplaintPageState();
// }
//
// const Color kPrimaryBlue = Color(0xFF1D648B);
//
// class _AddComplaintPageState extends State<AddComplaintPage> {
//   List<String> machineNumbers = [];
//   List<String> machineModels = [];
//   List<XFile> pickedImages = [];
//   final ImagePicker picker = ImagePicker();
//   final _authService = AuthApiService('https://dashboard.reachinternational.co.in/development/api');
//
//
//   Future<void> pickImages() async {
//     final List<XFile>? images = await picker.pickMultiImage();
//
//     if (images != null && images.isNotEmpty) {
//       setState(() {
//         pickedImages.addAll(images);
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchStatesInBackground();
//
//     fetchMachineNumbers();
//
//     // Access the list from the parent widget
//     machineNumbers = AppData.allComplaints
//         .map((c) => c.machineNumber)
//         .toSet()
//         .toList();
//
//     machineModels = AppData.allComplaints
//         .map((c) => c.model)
//         .toSet()
//         .toList();
//   }
//
//   Future<void> fetchMachineNumbers() async {
//     print('fetchMachineNumbers enter:');
//     try {
//       final res = await _authService.fetchMachineNumber();
//
//       if (res.status == true && res.data != null) {
//         AppData.machine_numbers = res.data.cast<MachineNumber>();
//         // print('fetchStates : ${AppData.states}');
//         // Navigate to)
//         // Navigate to dashboard, save token/user, etc.
//       } else {
//         // Show error message res.message
//         print('fetchMachineNumber error: ${res.message}');
//       }
//     } catch (e) {
//       // Handle network/error
//       print('fetchMachineNumber exception: $e');
//     }
//   }
//
//   Future<void> fetchMachineModels() async {
//     print('fetchMachineModels enter:');
//     try {
//       // selectedMachineNumberId = getMachineIdByName(selectedMachineNumber);
//       final res = await _authService.fetchMachineModel(machine_id: selectedMachineNumberId!);
//
//       if (res.status == true && res.data != null) {
//         AppData.machine_models = res.data.cast<MachineModelData>();
//         // print('cities : ${AppData.cities}');
//         // Navigate to)
//         // Navigate to dashboard, save token/user, etc.
//         selectedCityId = getCityIdByName(selectedCity);
//
//       } else {
//         // Show error message res.message
//         print('fetchStates error: ${res.message}');
//       }
//     } catch (e) {
//       // Handle network/error
//       print('fetchStates exception: $e');
//     }
//   }
//
//   Future<void> fetchStatesInBackground() async {
//     print('fetchStatesInBackground enter:');
//     try {
//       final res = await _authService.fetchStates();
//
//       if (res.status == true && res.data != null) {
//         AppData.states = res.data.cast<StateModel>();
//         // print('fetchStates : ${AppData.states}');
//         // Navigate to)
//         // Navigate to dashboard, save token/user, etc.
//       } else {
//         // Show error message res.message
//         print('fetchStates error: ${res.message}');
//       }
//     } catch (e) {
//       // Handle network/error
//       print('fetchStates exception: $e');
//     }
//   }
//
//
//
//   Future<void> fetchCities() async {
//     print('fetchCities enter:');
//     try {
//       selectedStateId = getStateIdByName(selectedState);
//       final res = await _authService.fetchCities(state_id: selectedStateId!);
//
//       if (res.status == true && res.data != null) {
//         AppData.cities = res.data.cast<CityModel>();
//         // print('cities : ${AppData.cities}');
//         // Navigate to)
//         // Navigate to dashboard, save token/user, etc.
//         selectedCityId = getCityIdByName(selectedCity);
//
//       } else {
//         // Show error message res.message
//         print('fetchStates error: ${res.message}');
//       }
//     } catch (e) {
//       // Handle network/error
//       print('fetchStates exception: $e');
//     }
//   }
//
//
//   // required String complaint,
//   // required String state,
//   // required String city_id,
//   // required String status,
//
//   Future<void> add_complaint() async {
//     print('add_complaint enter:');
//
//     try {
//       final res = await _authService.addComplaint(
//         complaint: complaintController.text.trim(),
//         state: selectedStateId!,
//         city_id: selectedCityId!,
//         status: selectedStatus!,
//       );
//
//       print("complaint ${complaintController.text.trim()}");
//       print("state $selectedStateId");
//       print("city_id $selectedCityId");
//       print("status $selectedStatus");
//
//       if (res.status == true && res.data != null) {
//         print("response ${res.status}");
//         /// 🎉 SHOW SUCCESS ALERT AND RETURN BACK
//         showDialog(
//           context: context,
//           barrierDismissible: false, // user cannot close by tapping outside
//           builder: (_) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               title: const Text("Success", style: TextStyle(fontWeight: FontWeight.bold)),
//               content: Text(res.message),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);     // close dialog
//                     Navigator.pop(context, true); // go back (with success flag)
//                   },
//                   child: const Text("OK"),
//                 ),
//               ],
//             );
//           },
//         );
//
//       } else {
//         // ❌ Show error toast / alert
//         _showError(res.message ?? "Something went wrong");
//         print('addComplaint error: ${res.message}');
//       }
//
//     } catch (e) {
//       print('addComplaint exception: $e');
//       _showError("Failed to submit complaint. Please try again.");
//     }
//   }
//
//
//   void _showError(String msg) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Error"),
//         content: Text(msg),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK"),
//           )
//         ],
//       ),
//     );
//   }
//
//
//   final TextEditingController machineNoController = TextEditingController();
//   final TextEditingController modelController = TextEditingController();
//   final TextEditingController complaintController = TextEditingController();
//   final TextEditingController pendingWorkController = TextEditingController();
//   final TextEditingController workDoneController = TextEditingController();
//
//   String? selectedState;
//   String? selectedStatus;
//   String? selectedCity;
//   String? selectedMachineModel;
//   String? selectedMachineNumber;
//   String? selectedStateId;
//   String? selectedCityId;
//   String? selectedMachineNumberId;
//   String? selectedMachineModelId;
//   final stateIds = AppData.states.map((s) => s.id).toList();
//
//   String? getStateIdByName(String? stateName) {
//     if (stateName == null) return null;
//
//     final match = AppData.states.firstWhere(
//           (s) => s.name == stateName,
//       orElse: () => StateModel(id: "", name: ""),
//     );
//
//     return match.id.isEmpty ? null : match.id;
//   }
//
//   String? getMachineIdByName(String? machineName) {
//     if (machineName == null) return null;
//
//     final match = AppData.machine_numbers.firstWhere(
//           (s) => s.machineNo == machineName,
//       orElse: () => MachineNumber(id: "", machineNo: '', machineModel: '', machineSrNo: ''),
//     );
//
//     return match.id.isEmpty ? null : match.id;
//   }
//
//   String? getMachineModelIdByName(String? machineModelName) {
//     if (machineModelName == null) return null;
//
//     final match = AppData.machine_models.firstWhere(
//           (s) => s.machineModel == machineModelName,
//       orElse: () => MachineModelData(id: "", machineSrNo: "", machineNo: "", machineModel: ""),
//     );
//
//     return match.id.isEmpty ? null : match.id;
//   }
//
//   String? getCityIdByName(String? city) {
//     if (city == null) return null;
//
//     final match = AppData.cities.firstWhere(
//           (s) => s.name == city,
//       orElse: () => CityModel(id: "", name: ""),
//     );
//
//     return match.id.isEmpty ? null : match.id;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: kPrimaryBlue,
//         title: const Text("Add Complaint", style: TextStyle(color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//             machineNumberDropdown(),
//             divider(),
//
//             machineModelDropdown(),
//             divider(),
//
//             // buildDropdown("Machine No", selectedMachineNumber, machineNumbers, (value) {
//             //   setState(() => selectedMachineNumber = value);
//             // }),
//             // divider(),
//             // buildDropdown("Machine Model", selectedMachineModel, machineModels, (value) {
//             //   setState(() => selectedMachineModel = value);
//             // }),
//             divider(),
//
//             buildTextField("Hour meter", workDoneController,"Enter an hour value .."),
//             divider(),
//
//             buildLargeInput("Complaint", complaintController,"Enter a Complaint"),
//             divider(),
//
//             statusDropdown(),
//
//             divider(),
//
//             stateDropdown(),
//
//             divider(),
//
//             cityDropdown(),
//
//             divider(),
//
//             const SizedBox(height: 25),
//
//             Text(
//               "Upload Image",
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//
//             const SizedBox(height: 10),
//
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 4,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   // CAMERA BUTTON
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: () async {
//                         final XFile? image = await picker.pickImage(source: ImageSource.camera);
//                         if (image != null) {
//                           setState(() => pickedImages.add(image));
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: kPrimaryBlue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       icon: const Icon(Icons.photo_camera, color: Colors.white),
//                       label: const Text("Pick from Camera",
//                           style: TextStyle(color: Colors.white, fontSize: 16)),
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // GALLERY BUTTON
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: () async {
//                         final List<XFile>? images = await picker.pickMultiImage();
//                         if (images != null && images.isNotEmpty) {
//                           setState(() => pickedImages.addAll(images));
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: kPrimaryBlue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       icon: const Icon(Icons.photo_library, color: Colors.white),
//                       label: const Text("Pick from Gallery",
//                           style: TextStyle(color: Colors.white, fontSize: 16)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             pickedImages.isNotEmpty
//                 ? SizedBox(
//               height: 90,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: pickedImages.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 10),
//                 itemBuilder: (context, index) {
//                   return Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.file(
//                           File(pickedImages[index].path),
//                           height: 90,
//                           width: 90,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Positioned(
//                         right: 0,
//                         top: 0,
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               pickedImages.removeAt(index);
//                             });
//                           },
//                           child: Container(
//                             decoration: const BoxDecoration(
//                               color: Colors.black54,
//                               shape: BoxShape.circle,
//                             ),
//                             padding: const EdgeInsets.all(4),
//                             child: const Icon(Icons.close, color: Colors.white, size: 16),
//                           ),
//                         ),
//                       )
//                     ],
//                   );
//                 },
//               ),
//             )
//                 : Text("", style: TextStyle(color: Colors.grey)),
//
//             const SizedBox(height: 30),
//
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: kPrimaryBlue,
//                   padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
//                 ),
//                 onPressed: () {
//                   add_complaint();
//                 },
//                 child: const Text("Submit Complaint", style: TextStyle(color: Colors.white, fontSize: 16)),
//               ),
//             ),
//
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   //      REUSABLE WIDGETS (UNCHANGED)
//   // ============================================================
//
//   Widget buildTextField(String label, TextEditingController controller,String placeholder) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(flex: 4, child: Text(label, style: const TextStyle(color: Colors.black))),
//         Expanded(
//           flex: 6,
//           child: TextField(
//             controller: controller,
//             style: const TextStyle(color: Colors.black),
//             decoration: InputDecoration(
//               hintText: placeholder,
//               hintStyle: const TextStyle(color: Colors.black54),
//               isDense: true,
//               border: const UnderlineInputBorder(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget buildLargeInput(String label, TextEditingController controller,String placeholder) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(flex: 4, child: Text(label, style: const TextStyle(color: Colors.black))),
//         Expanded(
//           flex: 6,
//           child: TextField(
//             controller: controller,
//             maxLines: 3,
//             style: const TextStyle(color: Colors.black),
//             decoration: InputDecoration(
//               hintText: placeholder,
//               hintStyle: TextStyle(color: Colors.black54),
//               border: OutlineInputBorder(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget statusDropdown() {
//     final items = ComplaintStatus.values
//         .map((c) => DropdownMenuItem<String>(
//       value: c.value,        // unique id used as value
//       child: Text(c.name),// shown text
//     ))
//         .toList();
//
//     // ensure selectedCityId is valid (avoid assert)
//     final valueExists = selectedStatus == null || items.any((it) => it.value == selectedStatus);
//
//     return DropdownButton<String>(
//       isExpanded: true,
//       value: valueExists ? selectedStatus : null, // if not valid, show hint
//       hint: const Text('Select Status'),
//       items: items,
//       onChanged: (v) => setState(() => selectedStatus = v
//
//       ),
//     );
//   }
//
//   Widget cityDropdown() {
//     final items = AppData.cities
//         .map((c) => DropdownMenuItem<String>(
//       value: c.id,        // unique id used as value
//       child: Text(c.name),// shown text
//     ))
//         .toList();
//
//     // ensure selectedCityId is valid (avoid assert)
//     final valueExists = selectedCityId == null || items.any((it) => it.value == selectedCityId);
//
//     return DropdownButton<String>(
//       isExpanded: true,
//       value: valueExists ? selectedCityId : null, // if not valid, show hint
//       hint: const Text('Select city'),
//       items: items,
//       onChanged: (v) => setState(() => selectedCityId = v
//
//       ),
//     );
//   }
//
//
//
//   String? _selectedStateId; // holds the id, not the name
//   Widget stateDropdown() {
//     final items = AppData.states
//         .map((c) => DropdownMenuItem<String>(
//       value: c.id,        // unique id used as value
//       child: Text(c.name),// shown text
//     ))
//         .toList();
//
//     // ensure selectedCityId is valid (avoid assert)
//     final valueExists = _selectedStateId == null || items.any((it) => it.value == _selectedStateId);
//
//     return DropdownButton<String>(
//       isExpanded: true,
//       value: valueExists ? _selectedStateId : null, // if not valid, show hint
//       hint: const Text('Select State'),
//       items: items,
//       onChanged: (v) async {
//         // update state id immediately so dropdown shows new selection
//         setState(() => _selectedStateId = v);
//
//         if (v != null && v.isNotEmpty) {
//           await fetchCities();
//         } else {
//           // cleared selection
//           setState(() {
//             AppData.cities = [];
//             selectedCityId = null;
//           });
//         }
//       },
//
//     );
//   }
//
//   Widget machineModelDropdown() {
//     final items = AppData.machine_models
//         .map((c) => DropdownMenuItem<String>(
//       value: c.id,        // unique id used as value
//       child: Text(c.machineModel),// shown text
//     ))
//         .toList();
//
//     // ensure selectedCityId is valid (avoid assert)
//     final valueExists = selectedMachineModel == null || items.any((it) => it.value == selectedMachineModel);
//
//     return DropdownButton<String>(
//       isExpanded: true,
//       value: valueExists ? selectedMachineModel : null, // if not valid, show hint
//       hint: const Text('Select Machine Model'),
//       items: items,
//       onChanged: (v) => setState(() => selectedMachineModel = v
//       ),
//     );
//   }
//
//   Widget machineNumberDropdown() {
//     final items = AppData.machine_numbers
//         .map((c) => DropdownMenuItem<String>(
//       value: c.id,        // unique id used as value
//       child: Text(c.machineNo),// shown text
//     ))
//         .toList();
//
//     // ensure selectedCityId is valid (avoid assert)
//     final valueExists = selectedMachineNumberId == null || items.any((it) => it.value == selectedMachineNumberId);
//
//     return DropdownButton<String>(
//       isExpanded: true,
//       value: valueExists ? selectedMachineNumberId : null, // if not valid, show hint
//       hint: const Text('Select Machine Number'),
//       items: items,
//       // onChanged: (v) => setState(() => selectedMachineNumberId = v),
//       onChanged: (v) async {
//         // update state id immediately so dropdown shows new selection
//         setState(() => selectedMachineNumberId = v);
//
//         if (v != null && v.isNotEmpty) {
//           await fetchMachineModels();
//         } else {
//           // cleared selection
//           setState(() {
//             AppData.machine_numbers = [];
//             selectedMachineNumberId = null;
//           });
//         }
//       },
//     );
//   }
//
//   Widget buildDropdown(
//       String label,
//       String? value,
//       List<String> items,
//       Function(String?) onChanged,
//       ) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 4,
//           child: Text(
//             label,
//             style: const TextStyle(color: Colors.black),
//           ),
//         ),
//
//         Expanded(
//           flex: 6,
//           child: DropdownButtonFormField<String>(
//             isExpanded: true, // ⭐ Prevents overflow
//             value: value,
//             dropdownColor: Colors.white,
//             decoration: InputDecoration(
//               contentPadding:
//               const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//
//             items: items.map((e) {
//               return DropdownMenuItem(
//                 value: e,
//                 child: Text(
//                   e,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis, // ⭐ Truncate long text
//                 ),
//               );
//             }).toList(),
//
//             onChanged: onChanged,
//           ),
//         ),
//       ],
//     );
//   }
//
//
//   Widget divider() => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 10),
//     child: Container(height: 1, color: Colors.black26),
//   );
// }
