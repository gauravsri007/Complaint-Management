import 'package:flutter/material.dart';

class ComplaintFilterSheet extends StatefulWidget {
  const ComplaintFilterSheet({super.key});

  @override
  State<ComplaintFilterSheet> createState() => _ComplaintFilterSheetState();
}

class _ComplaintFilterSheetState extends State<ComplaintFilterSheet> {
  String? engineer;
  String? status;
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController machineNoController = TextEditingController();
  TextEditingController modelController = TextEditingController();

  List<String> engineers = [
    "Engineer Smith",
    "Engineer Jones",
    "Mohd Hameed",
    "Engineer Ali"
  ];

  List<String> statuses = ["Open", "Assigned", "Resolved"];

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
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text("Filter Complaints",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            // SERVICE ENGINEER
            buildDropdown(
              label: "Service Engineer",
              value: engineer,
              items: engineers,
              onChanged: (v) => setState(() => engineer = v),
            ),

            const SizedBox(height: 16),

            // STATUS
            buildDropdown(
              label: "Status",
              value: status,
              items: statuses,
              onChanged: (v) => setState(() => status = v),
            ),

            const SizedBox(height: 16),

            // DATE RANGE (FROM)
            datePickerTile(
              label: "Complaint Date From",
              date: startDate,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => startDate = picked);
              },
            ),

            const SizedBox(height: 12),

            // DATE RANGE (TO)
            datePickerTile(
              label: "Complaint Date To",
              date: endDate,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => endDate = picked);
              },
            ),

            const SizedBox(height: 16),

            // MACHINE NO
            buildTextField("Machine No", machineNoController),

            const SizedBox(height: 16),

            // MODEL
            buildTextField("Model", modelController),

            const SizedBox(height: 20),

            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, null); // clear filter
                    },
                    child: const Text("Reset"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        "engineer": engineer,
                        "status": status,
                        "startDate": startDate,
                        "endDate": endDate,
                        "machineNo": machineNoController.text,
                        "model": modelController.text,
                      });
                    },
                    child: const Text("Apply"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Helpers -----------

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget datePickerTile({
    required String label,
    required DateTime? date,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          date != null
              ? "${date.day}-${date.month}-${date.year}"
              : label,
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
