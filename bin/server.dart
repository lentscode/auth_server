import 'dart:io';

import 'package:auth_server/config/set_up.dart';
import 'package:auth_server/middlewares/middlewares.dart';
import 'package:auth_server/routes/routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Router pubblico, accessibile senza autorizzazione.
final _publicRouter = Router()
  ..post("/register", register)
  ..post("/login", login);

// Router privato.
final _privateRouter = Router()..get("/<message>", echo);

// Handler corrispondenti.
final _publicHandler = Pipeline().addHandler(_publicRouter.call);
final _privateHandler = Pipeline().addMiddleware(checkSessionId()).addHandler(_privateRouter.call);

// Router principale.
final _mainRouter = Router()
  ..mount("/public", _publicHandler)
  ..mount("/protected", _privateHandler);

void main(List<String> args) async {
  // Chiamata alla funzione di configurazione.
  await setUp();

  final ip = InternetAddress.anyIPv4;

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_mainRouter.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
