// To parse this JSON data, do
//
//     final matchOtpModel = matchOtpModelFromJson(jsonString);

import 'dart:convert';

MatchOtpModel matchOtpModelFromJson(String str) => MatchOtpModel.fromJson(json.decode(str));

String matchOtpModelToJson(MatchOtpModel data) => json.encode(data.toJson());

class MatchOtpModel {
  final String email;
  final String otp;

  MatchOtpModel({
    required this.email,
    required this.otp,
  });

  factory MatchOtpModel.fromJson(Map<String, dynamic> json) => MatchOtpModel(
    email: json["email"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "otp": otp,
  };
}
