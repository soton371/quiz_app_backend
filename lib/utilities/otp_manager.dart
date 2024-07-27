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
    ..subject = 'Verification'
    ..html = '''
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<body style="font-family: Helvetica, Arial, sans-serif; margin: 0px; padding: 0px; background-color: #ffffff;">
  <table role="presentation"
    style="width: 100%; border-collapse: collapse; border: 0px; border-spacing: 0px; font-family: Arial, Helvetica, sans-serif; background-color: rgb(239, 239, 239);">
    <tbody>
      <tr>
        <td align="center" style="padding: 1rem 2rem; vertical-align: top; width: 100%;">
          <table role="presentation" style="max-width: 600px; border-collapse: collapse; border: 0px; border-spacing: 0px; text-align: left;">
            <tbody>
              <tr>
                <td style="padding: 40px 0px 0px;">
                  <div style="text-align: left;">
                    <div style="padding-bottom: 20px;"><img src="https://i.ibb.co/Qbnj4mz/logo.png" alt="Company" style="width: 56px;"></div>
                  </div>
                  <div style="padding: 30px; background-color: rgb(255, 255, 255);">
                    <div style="color: rgb(0, 0, 0); text-align: left;">
                      <h2 style="margin: 1rem 0">Verify Your Quiz 360 Account</h2>
                     <p>Hi,</p> 
                      <p style="padding-bottom: 16px">Thanks for joining Quiz 360! To verify your account, please enter the following 6-digit OTP code:</p>
                      
                      <h2 style="text-align: center;padding-bottom: 16px; font-size: 24px; font-weight: bold;">$otp</h2>
                      
                      <p>This code is valid for 3 minutes.</p>
                    
                    </div>
                  </div>
                  <div style="padding-top: 20px; color: rgb(153, 153, 153); text-align: center;">
                    <p style="padding-bottom: 16px"></p>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </td>
      </tr>
    </tbody>
  </table>
</body>

</html>
    ''';

  try {
    await send(message, smtpServer);
    return true;
  } on MailerException catch (e) {
    logger.e('Message not sent. e: $e');
    return false;
  }
}