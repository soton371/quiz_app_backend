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


Future<bool> sendOTP(String recipientEmail, String otp) async {
  String username = 'tasmia437@gmail.com';
  String password = 'password';

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'Your name')
    ..recipients.add('soton371@gmail.com')
    ..subject = 'Test Dart Mailer library :: 😀 :: ${DateTime.now()}'
    ..text = 'This is the plain text.\nThis is line 2 of the text part.'
    ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";

  try {
    final sendReport = await send(message, smtpServer);
    logger.i('Message sent: $sendReport');
    return true;
  } on MailerException catch (e) {
    logger.e('Message not sent.');
    for (var p in e.problems) {
      logger.e('Problem: ${p.code}: ${p.msg}');
    }
    return false;
  }
}