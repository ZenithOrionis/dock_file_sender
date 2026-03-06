class DockStatus {
  final bool success;
  final int? statusCode;
  final String? message;
  final List<String> data;

  DockStatus({
    required this.success,
    this.statusCode,
    this.message,
    required this.data,
  });

  factory DockStatus.fromJson(Map<String, dynamic> json) {
    var dataJson = json['data'];
    List<String> dataList = [];
    if (dataJson is List) {
      dataList = List<String>.from(dataJson.map((x) => x.toString()));
    } else if (dataJson is String) {
      // In case the API sometimes returns a single string instead of a list
      dataList = [dataJson];
    }

    return DockStatus(
      success: json['success'] ?? false,
      statusCode: json['status_code'],
      message: json['message'],
      data: dataList,
    );
  }
}
