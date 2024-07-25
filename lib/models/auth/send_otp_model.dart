// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

SendOtpModel sendOtpModelFromJson(String str) => SendOtpModel.fromJson(json.decode(str));

String sendOtpModelToJson(SendOtpModel data) => json.encode(data.toJson());


class SendOtpModel {
  final String email;
  final int type;

  SendOtpModel({
    required this.email,
    required this.type,
  });

  factory SendOtpModel.fromJson(Map<String, dynamic> json) => SendOtpModel(

    email: json["email"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "type": type,
  };
}
