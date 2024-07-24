import 'dart:convert';

String responseModelToJson(ResponseModel data) => json.encode(data.toJson());

class ResponseModel {
  final bool success;
  final String message;
  final dynamic data;

  ResponseModel(
      {required this.success, required this.message, required this.data});

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data,
  };
}
