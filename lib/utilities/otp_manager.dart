import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:quiz_app_backend/configs/configs.dart';

String generateOTP() {
  const otpLength = 6;
  final random = Random();
  String otp = '';

  for (int i = 0; i < otpLength; i++) {
    otp += (random.nextInt(9) + 1).toString();
  }

  return otp;
}


Future<bool> sendOTPSMTP(String recipientEmail, String otp) async {

  final smtpServer = gmail(senderEmail, sendOTPPassword);

  final message = Message()
    ..from = Address(senderEmail, 'Quiz 360')
    ..recipients.add(recipientEmail)
    ..subject = 'Verification for Quiz 360'
    ..html = "<h1>OTP Code</h1>\n<p>$otp</p>";

  try {
    await send(message, smtpServer);
    return true;
  } on MailerException catch (e) {
    logger.e('Message not sent. e: $e');
    return false;
  }
}