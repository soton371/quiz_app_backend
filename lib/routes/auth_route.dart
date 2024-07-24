import 'package:postgres/postgres.dart';
import 'package:shelf_router/shelf_router.dart';

import '../handlers/handlers.dart';

class AuthRoute{

  final Connection connection;
  AuthRoute(this.connection);

  AuthHandler get _authHandler => AuthHandler(connection);

  Router get router => Router()
    ..post('/login', _authHandler.login)
    ..post('/registration', _authHandler.register);
}

