// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_status.dart';

// **************************************************************************
// EnumeGenerator
// **************************************************************************

extension HttpStatusName on HttpStatus {
  String get name => toString().substring(11);
}

extension HttpStatuscode on HttpStatus {
  int get code {
    switch (this) {
      case HttpStatus.ok:
        return 200;
      case HttpStatus.badRequest:
        return 400;
      case HttpStatus.conflict:
        return 407;
    }
  }
}

extension HttpStatusvalue on HttpStatus {
  String get value {
    switch (this) {
      case HttpStatus.ok:
        return 'OK';
      case HttpStatus.badRequest:
        return 'Bad Request';
      case HttpStatus.conflict:
        return 'Proxy Authentication Required';
    }
  }
}
