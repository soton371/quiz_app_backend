// To parse this JSON data, do
//
//     final changePasswordModel = changePasswordModelFromJson(jsonString);

import 'dart:convert';

ChangePasswordModel changePasswordModelFromJson(String str) => ChangePasswordModel.fromJson(json.decode(str));

String changePasswordModelToJson(ChangePasswordModel data) => json.encode(data.toJson());

class ChangePasswordModel {
  final String currentPassword;
  final String newPassword;

  ChangePasswordModel({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordModel.fromJson(Map<String, dynamic> json) => ChangePasswordModel(
    currentPassword: json["current_password"],
    newPassword: json["new_password"],
  );

  Map<String, dynamic> toJson() => {
    "current_password": currentPassword,
    "new_password": newPassword,
  };
}
