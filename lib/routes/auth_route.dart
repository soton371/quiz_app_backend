import 'package:postgres/postgres.dart';
import 'package:shelf_router/shelf_router.dart';

import '../handlers/handlers.dart';

class AuthRoute{

  final Connection connection;
  AuthRoute(this.connection);

  AuthHandler get _authHandler => AuthHandler(connection);

  Router get router => Router()
    ..post('/login', _authHandler.login)
    ..post('/send_otp', _authHandler.sendOtp)
    ..post('/match_otp', _authHandler.matchOtp)
    ..put('/reset_password', _authHandler.resetPassword)
    ..put('/change_password', _authHandler.changePassword)
    ..post('/registration', _authHandler.register);
}

