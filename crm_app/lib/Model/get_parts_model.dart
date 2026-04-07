class PartsListResponse {
  final bool status;
  final String message;
  final List<PartItem> data;

  PartsListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PartsListResponse.fromJson(Map<String, dynamic> json) {
    return PartsListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => PartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PartItem {
  final String id;
  final String name;

  PartItem({
    required this.id,
    required this.name,
  });

  factory PartItem.fromJson(Map<String, dynamic> json) {
    return PartItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  @override
  String toString() => name; // helpful for Dropdowns
}
