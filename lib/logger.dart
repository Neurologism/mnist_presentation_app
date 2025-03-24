import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Logger {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String? _name;

  Logger([this._name]);

  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';


  void i(dynamic message) {
    if (kDebugMode) {
      print('$_blue${_dateFormat.format(DateTime.now())} $_name [INFO]: $message$_reset');
    }
  }

  void e(dynamic message, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('$_red${_dateFormat.format(DateTime.now())} $_name [ERROR]: $message$_reset');
      if (stackTrace != null) {
        debugPrintStack(stackTrace: stackTrace, label: _name);
      }
    }
  }

  void w(dynamic message) {
    if (kDebugMode) {
      print('$_yellow${_dateFormat.format(DateTime.now())} $_name [WARNING]: $message$_reset');
    }
  }

  void f(dynamic message) {
    if (kDebugMode) {
      print('$_magenta${_dateFormat.format(DateTime.now())} $_name [FATAL]: $message$_reset');
    }
  }

  void d(dynamic message) {
    if (kDebugMode) {
      print('$_magenta${_dateFormat.format(DateTime.now())} $_name [DEBUG]: $message$_reset');
    }
  }

  void database(String message) {
    if (kDebugMode) {
      print('$_cyan${_dateFormat.format(DateTime.now())} $_name [DATABASE]: $message$_reset');
    }
  }
}

Logger logger = Logger('WhitemindDemo');
