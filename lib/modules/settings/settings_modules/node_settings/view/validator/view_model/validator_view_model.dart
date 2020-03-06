import 'dart:convert';

import 'package:capo/modules/settings/settings_modules/node_settings/view/validator/model/validator_cell_model.dart';
import 'package:capo/utils/dialog/capo_dialog_utils.dart';
import 'package:capo/utils/rnode_networking.dart';
import 'package:capo/utils/storage_manager.dart';
import 'package:capo_core_dart/capo_core_dart.dart';
import 'package:easy_localization/public.dart';
import 'package:flutter/cupertino.dart';

class ValidatorViewModel with ChangeNotifier {
  ValidatorSections tableViewSections;
  BuildContext _buildContext;
  loadJson(context) async {
    String jsonString;
    jsonString =
        StorageManager.sharedPreferences.getString(kUserValidatorNodeSettings);

    if (jsonString == null) {
      jsonString = await DefaultAssetBundle.of(context).loadString(
          'lib/modules/settings/settings_modules/node_settings/view/validator/model/validator_sections.json');
    }
    final map = json.decode(jsonString);
    tableViewSections = ValidatorSections.fromJson(map);
    notifyListeners();

    _buildContext = context;
  }

  cellTapped({@required int section, @required int row}) async {
    String selectedNode = tableViewSections.sections[section][row].url;
    if (selectedNode == tableViewSections.selectedNode) {
      return;
    }
    tableViewSections.selectedNode = selectedNode;
    await saveNodeSettings2Storage(tableViewSections);
    notifyListeners();
  }

  saveNodeSettings2Storage(ValidatorSections tableSections) async {
    String jsonString = json.encode(tableSections.toJson());
    await Future.wait([
      StorageManager.sharedPreferences
          .setString(kUserValidatorNodeSettings, jsonString),
    ]);
  }

  addCustomNode(String nodeUrl) async {
    if (nodeUrl == null || nodeUrl.length == 0) {
      return;
    }

    var _url = nodeUrl;
    if (_url.startsWith(RegExp(r'https?:'))) {
      CapoDialogUtils.showCupertinoDialog(
          buildContext: _buildContext,
          message: tr(
              "settings.note_settings.validator_page.node_address_not_validate"));
      return;
    }
    var s = _url.split(':');
    try {
      final int _ = int.parse(s.last);
    } catch (e) {
      CapoDialogUtils.showCupertinoDialog(
          buildContext: _buildContext,
          message: tr("settings.note_settings.validator_page.port_error"));
      return;
    }

    for (List<Section> sections in tableViewSections.sections) {
      for (Section section in sections) {
        if (section.url == nodeUrl) {
          CapoDialogUtils.showCupertinoDialog(
              buildContext: _buildContext,
              message: tr(
                  "settings.note_settings.validator_page.node_already_exists"));
          return;
        }
      }
    }
    CapoDialogUtils.showProcessIndicator(
        context: _buildContext,
        tip: tr("settings.note_settings.validator_page.testing"));
    bool passed = await testNode(nodeUrl);
    Navigator.pop(_buildContext);
    if (!passed) {
      CapoDialogUtils.showCupertinoDialog(
          buildContext: _buildContext,
          message: tr(
              "settings.note_settings.validator_page.unable_to_connect_to_this_node"));
      return;
    }

    tableViewSections.sections.last.add(Section(url: nodeUrl));
    await saveNodeSettings2Storage(tableViewSections);
    notifyListeners();
  }

  Future<bool> testNode(String nodeUrl) async {
    var s = nodeUrl.split(':');

    final String host = s.first;
    final int port = int.parse(s.last);

    try {
      RNodeGRPC gRPC = RNodeGRPC(host: host, port: port);
      final blocksQuery = BlocksQuery();
      blocksQuery.depth = 1;
      final blocks = await gRPC.deployService.getBlocks(blocksQuery).first;
      final blockNumber = blocks.blockInfo.blockNumber;
      if (blockNumber == null || blockNumber == 0) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  deleteNode(int section, int row) async {
    String nodeUrl = tableViewSections.sections[section][row].url;
    if (nodeUrl == tableViewSections.selectedNode) {
      tableViewSections.selectedNode =
          tableViewSections.sections.first.first.url;
    }
    tableViewSections.sections[section].removeAt(row);
    await saveNodeSettings2Storage(tableViewSections);
    notifyListeners();
  }

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
