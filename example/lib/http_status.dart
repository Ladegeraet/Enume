import 'package:enume/enume.dart';

part 'http_status.g.dart';

@Enume()
enum HttpStatus {
  @Value(200, name: 'code')
  @Value('OK')
  ok,
  @Value('400', name: 'code')
  @Value('Bad Request')
  badRequest,
  @Value(407, name: 'code')
  @Value('Proxy Authentication Required')
  conflict,
}
