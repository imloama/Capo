import 'dart:convert';

import 'package:capo/modules/settings/settings_modules/node_settings/view/readonly/model/readonly_cell_model.dart';
import 'package:capo/utils/storage_manager.dart';
import 'package:capo_core_dart/capo_core_dart.dart';
import 'package:dio/dio.dart';

const kUserReadonlyNodeSettings = 'kUserReadonlyNodeSettings';
const kUserValidatorNodeSettings = 'kUserValidatorNodeSettings';

class RNodeNetworking {
  static RNodeGRPC get gRPC {
    String jsonString;
    String baseUrl;

    jsonString =
        StorageManager.sharedPreferences.getString(kUserValidatorNodeSettings);

    if (jsonString == null) {
      baseUrl = "node0.root-shard.mainnet.rchain.coop:40401";
    } else {
      final map = json.decode(jsonString);
      ReadonlySections model = ReadonlySections.fromJson(map);
      baseUrl = model.selectedNode;
    }
    var s = baseUrl.split(':');

    final String host = s.first;
    final int port = int.parse(s.last);
    return RNodeGRPC(host: host, port: port);
  }

  static Dio get rNodeDio {
    String jsonString;
    String baseUrl;

    jsonString =
        StorageManager.sharedPreferences.getString(kUserReadonlyNodeSettings);

    if (jsonString == null) {
      baseUrl = "http://observer-asia.services.mainnet.rchain.coop:40403";
    } else {
      final map = json.decode(jsonString);
      ReadonlySections model = ReadonlySections.fromJson(map);
      baseUrl = model.selectedNode;
    }
    return Dio(BaseOptions(baseUrl: baseUrl));
  }
}
