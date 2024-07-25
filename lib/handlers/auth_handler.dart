import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';

import '../configs/configs.dart';
import '../models/models.dart';
import '../utilities/utilities.dart';

class AuthHandler {
  final Connection connection;

  AuthHandler(this.connection);

  //for login
  Future<Response> login(Request request) async {
    try {
      final req = userModelFromJson(await request.readAsString());

      final checkUser = await connection.execute(
          Sql.named(
              "SELECT * FROM users WHERE email=@email AND password=@password"),
          parameters: {
            "email": req.email,
            "password": _hashString(req.password)
          });

      if (checkUser.isNotEmpty) {
        Map<String, String> result = {
          "full_name": checkUser.first[1].toString(),
          "email": checkUser.first[2].toString()
        };

        final token = _generateToken(result);

        result['token'] = token;

        return Response.ok(responseModelToJson(ResponseModel(
            success: true, message: "Login success.", data: result)));
      } else {
        return Response.notFound(responseModelToJson(ResponseModel(
            success: false,
            message: "Your email or password is wrong.",
            data: null)));
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //for send otp
  Future<Response> sendOtp(Request request) async {
    try {
      final req = sendOtpModelFromJson(await request.readAsString());

      final checkUsers = await connection.execute(
          Sql.named("SELECT * FROM users WHERE email=@email"),
          parameters: {"email": req.email});

      if (req.type == 0) {
        //0 for register
        if (checkUsers.isNotEmpty) {
          return Response.ok(responseModelToJson(ResponseModel(
              success: false,
              message: "User already registered.",
              data: null)));
        }

        return saveEmailOtp(req);
      } else {
        //else for forgot password
        if (checkUsers.isEmpty) {
          return Response.notFound(responseModelToJson(ResponseModel(
              success: false,
              message: "Email is not registered.",
              data: null)));
        }

        return saveEmailOtp(req);
      }
    } catch (e) {
      logger.e("sendOtp e: $e");
      return Response.internalServerError(
          body: responseModelToJson(ResponseModel(
              success: false,
              message: "Failed to send otp code.",
              data: null)));
    }
  }

  //end for send otp

  //for register
  Future<Response> register(Request request) async {
    try {
      final req = userModelFromJson(await request.readAsString());
      final checkUsers = await connection.execute(
          Sql.named("SELECT * FROM users WHERE email=@email"),
          parameters: {"email": req.email});

      if (checkUsers.isNotEmpty) {
        return Response.ok(responseModelToJson(ResponseModel(
            success: false, message: "User already exist.", data: null)));
      }

      // Generate and send OTP
      final otp = generateOTP();
      final sent = await sendOTPSMTP(req.email, otp);
      if (!sent) {
        return Response.internalServerError(
            body: responseModelToJson(ResponseModel(
                success: false, message: "Error sending OTP.", data: null)));
      }

      /*await connection.execute(
          Sql.named(
              "INSERT INTO users (full_name, email, password) VALUES (@full_name, @email, @password)"),
          parameters: {
            "full_name": req.fullName,
            "email": req.email,
            "password": _hashPassword(req.password)
          });*/

      final responseData = ResponseModel(
          success: true, message: "User created.", data: req.toJson());
      return Response.ok(responseModelToJson(responseData));
    } catch (e) {
      throw Exception(e);
    }
  }

  String _hashString(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateToken(Map payload) {
    final jwt = JWT(payload);
    return jwt.sign(SecretKey(secreteKey));
  }

  Future<Response> saveEmailOtp(SendOtpModel req) async {
    try {
      final otp = generateOTP();
      final sent = await sendOTPSMTP(req.email, otp);
      if (!sent) {
        return Response.internalServerError(
            body: responseModelToJson(ResponseModel(
                success: false,
                message: "Failed to send otp code.",
                data: null)));
      }

      final checkEmailOtp = await connection.execute(
          Sql.named("SELECT * FROM email_otp WHERE email=@email"),
          parameters: {"email": req.email});

      if (checkEmailOtp.isEmpty) {
        await connection.execute(
            Sql.named(
                "INSERT INTO email_otp (email, type, otp_code, otp_send_time, received_otp_count) VALUES (@email, @type, @otp_code, @otp_send_time, @received_otp_count)"),
            parameters: {
              "email": req.email,
              "type": req.type,
              "otp_code": _hashString(otp),
              "otp_send_time": DateTime.now().toString(),
              "received_otp_count": 1,
            });
        return Response.ok(responseModelToJson(ResponseModel(
            success: true, message: "OTP code sent successfully", data: null)));
      } else {
        int receivedOtpCount =
            (int.tryParse(checkEmailOtp.first[4].toString()) ?? 0) + 1;


        if (receivedOtpCount > 3) {
          Future.delayed(Duration(minutes: 3),()async{
            await connection.execute(
                Sql.named("DELETE FROM email_otp WHERE email=@email"),
                parameters: {"email": req.email.trim()});
          });
          return Response.badRequest(
              body: responseModelToJson(ResponseModel(
                  success: false,
                  message:
                      "You are blocked for 3 minutes for sending OTP code.",
                  data: null)));
        }

        /*final sendOtpTime =
            DateTime.tryParse(checkEmailOtp.first[3].toString());
        if (sendOtpTime != null &&
            (sendOtpTime.difference(DateTime.now()).inMinutes < -3)) {
          return Response.badRequest(
              body: responseModelToJson(ResponseModel(
                  success: false,
                  message: "Your OTP code has expired.",
                  data: null)));
        }*/

        await connection.execute(
            Sql.named(
                "UPDATE email_otp SET email=@email, type=@type, otp_code=@otp_code, otp_send_time=@otp_send_time, received_otp_count=@received_otp_count WHERE email=@email"),
            parameters: {
              "email": req.email,
              "type": req.type,
              "otp_code": _hashString(otp),
              "otp_send_time": DateTime.now().toString(),
              "received_otp_count": receivedOtpCount,
            });

        return Response.ok(responseModelToJson(ResponseModel(
            success: true, message: "OTP code sent successfully", data: null)));
      }
    } catch (e) {
      logger.e("saveEmailOtp e: $e");
      return Response.internalServerError(
          body: responseModelToJson(ResponseModel(
              success: false,
              message: "Failed to send otp code.",
              data: null)));
    }
  }
}
