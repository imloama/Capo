import 'package:capo/modules/balance/send/model/send_history_model.dart';
import 'package:capo/utils/rnode_networking.dart';
import 'package:capo_core_dart/capo_core_dart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:intl/intl.dart';
import 'package:rxbus/rxbus.dart';

class TransactionCellViewModel with ChangeNotifier {
  final TransactionHistory history;
  TransactionCellViewModel({@required this.history});

  fetchTransactionStatus() async {
    if (history.status == TransactionStatus.failed ||
        history.status == TransactionStatus.success) {
      notifyListeners();
      return;
    }
    fetchBlockHash();
  }

  fetchBlockHash() async {
    if (history.status == TransactionStatus.failed ||
        history.status == TransactionStatus.success) {
      notifyListeners();
      return;
    }

    if (history.blockHash != null && history.blockHash.length > 0) {
      fetchBlockStatus();
      return;
    }
    FindDeployQuery query = FindDeployQuery();
    query.deployId = HEX.decode(history.deployId);
    FindDeployResponse findDeployResponse =
        await RNodeNetworking.gRPC.deployService.findDeploy(query);
    String error = findDeployResponse.error.messages.length > 0
        ? findDeployResponse.error.messages.first
        : null;
    if (error != null) {
      bool timeout = isTimeout();
      if (timeout) {
        history.status = TransactionStatus.failed;
        transactionStatusChanged();
        return;
      }
      Future.delayed(Duration(seconds: 10), () {
        if (_disposed) {
          return;
        }
        fetchBlockHash();
      });
      return;
    }
    String blockHash = findDeployResponse.blockInfo.blockHash;
    if (blockHash != null && blockHash.length > 0) {
      history.blockHash = blockHash;
      transactionStatusChanged();
      fetchBlockStatus();
    }
  }

  fetchBlockStatus() async {
    if (history.status == TransactionStatus.failed ||
        history.status == TransactionStatus.success) {
      notifyListeners();
      return;
    }
    IsFinalizedQuery finalizedQuery = IsFinalizedQuery();
    finalizedQuery.hash = history.blockHash;
    IsFinalizedResponse isFinalizedResponse =
        await RNodeNetworking.gRPC.deployService.isFinalized(finalizedQuery);

    if (isFinalizedResponse.isFinalized) {
      history.status = TransactionStatus.success;
      transactionStatusChanged();
    } else {
      bool timeout = isTimeout();
      if (timeout) {
        history.status = TransactionStatus.failed;
        transactionStatusChanged();
        return;
      }
      Future.delayed(Duration(seconds: 10), () {
        if (_disposed) {
          return;
        }
        fetchBlockStatus();
      });
    }
  }

  bool isTimeout() {
    DateTime dateNow = DateTime.now();
    int timestamp = int.parse(history.timestamp);
    DateTime sendTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    var difference = dateNow.difference(sendTime);
    if (difference.inHours >= 2) {
      return true;
    }
    return false;
  }

  transactionStatusChanged() {
    RxBus.post("", tag: "SaveTransactions");
    RxBus.post("", tag: "TransactionStatusChanged");
  }

  Color getIndicatorColor() {
    Color color =
        history.status == TransactionStatus.failed ? Colors.red : Colors.green;
    if (history.type == TransactionType.receive) {
      color = Colors.green;
    }
    return color;
  }

  bool shouldAnimate() {
    if (history.status == TransactionStatus.pending) {
      return true;
    }
    return false;
  }

  String getStatus() {
    return history.status.toString().split(".").last;
  }

  String getTime() {
    int timestamp = int.parse(history.timestamp);
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    date.toLocal();
    var formatter = new DateFormat('yyyy/MM/dd HH:mm:ss');
    String dateString = formatter.format(date);
    return dateString;
  }

  String getType(TransactionHistory history) {
    if (history.type == TransactionType.send) {
      return "To:" + history.to;
    }
    return "From:" + history.from;
  }

  String getAmount() {
    if (history.type == TransactionType.send) {
      return "-" + history.amount;
    }
    return "+" + history.amount;
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
