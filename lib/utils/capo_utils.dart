import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Locale capoAppDeviceLocale;

String capoNumberFormat(dynamic number) {
  final formatter = NumberFormat("#,###.########");
  if (number is String) {
    return formatter.format(double.tryParse(number) ?? 0);
  }
  if (number is num) {
    return formatter.format(number);
  }
  return "0";
}

String capoAmountFormat(dynamic amount) {
  final formatter = NumberFormat("#,###.##");
  var result = "0.00";

  if (amount is String) {
    result = formatter.format(double.tryParse(amount) ?? 0);
  }
  if (amount is num) {
    result = formatter.format(amount);
  }
  return result;
}

int hexToInt(String hex) {
  int val = 0;
  int len = hex.length;
  for (int i = 0; i < len; i++) {
    int hexDigit = hex.codeUnitAt(i);
    if (hexDigit >= 48 && hexDigit <= 57) {
      val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 65 && hexDigit <= 70) {
      // A..F
      val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 97 && hexDigit <= 102) {
      // a..f
      val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
    } else {
      throw new FormatException("Invalid hexadecimal value");
    }
  }
  return val;
}

extension HexColor on Color {
  static Color mainColor = Color.fromARGB(255, 51, 118, 184);

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16)}'
      '${red.toRadixString(16)}'
      '${green.toRadixString(16)}'
      '${blue.toRadixString(16)}';
}
