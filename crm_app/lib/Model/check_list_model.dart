class ChecklistItem {
  final String title;
  final List<String> options;
  String? selected;

  ChecklistItem({
    required this.title,
    required this.options,
    this.selected,
  });
}