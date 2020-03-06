import 'dart:io';

import 'package:capo/utils/wallet_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

const String kUserTransactions = "kUserTransactions";

class CapoStorageUtils {
  static CapoStorageUtils shared = CapoStorageUtils._internal();
  factory CapoStorageUtils() => _sharedInstance();
  static CapoStorageUtils _sharedInstance() {
    return shared;
  }

  CapoStorageUtils._internal();

  saveByAddress({@required String key, @required String content}) async {
    await _writeContent(fileName: key, content: content);
  }

  Future<String> readByAddress({@required String key}) async {
    try {
      String content = await _readFrom(key);
      return content;
    } catch (_) {
      return null;
    }
  }

  Future<String> get addressDirectory async {
    String address = WalletViewModel.shared.currentWallet.address;
    final dir = await getApplicationDocumentsDirectory();
    final directory = Directory("${dir.path}/$address");
    final exists = await directory.exists();

    if (exists) {
      return directory.path;
    } else {
      directory.createSync();
    }
    return directory.path;
  }

  Future<File> _writeContent(
      {@required String content, @required String fileName}) async {
    final addressDir = await addressDirectory;
    final filePath = addressDir + "/" + fileName;
    final file = File(filePath);
    final exists = file.existsSync();
    if (!exists) {
      file.createSync();
    }
    return file.writeAsString(content);
  }

  Future<String> _readFrom(String fileName) async {
    try {
      final addressDir = await addressDirectory;
      final filePath = addressDir + "/" + fileName;
      final file = File(filePath);
      String body = await file.readAsString();
      return body;
    } catch (_) {
      rethrow;
    }
  }
}
