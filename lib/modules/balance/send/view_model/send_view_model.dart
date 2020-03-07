import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:capo/modules/balance/send/model/send_history_model.dart';
import 'package:capo/utils/capo_storage_utils.dart';
import 'package:capo/utils/capo_utils.dart';
import 'package:capo/utils/dialog/capo_dialog_utils.dart';
import 'package:capo/utils/rnode_networking.dart';
import 'package:capo/utils/transfer_funds_rho.dart';
import 'package:capo/utils/wallet_view_model.dart';
import 'package:capo_core_dart/capo_core_dart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rxbus/rxbus.dart';

class SendViewModel extends ChangeNotifier {
  String selfRevAddress = "";
  String maxTransferAmount = "0";
  String selfRevBalance = "0";
  String transferAddress = "";
  String transferAmount = "";
  double minerFee = 160000;
  BuildContext buildContext;
  bool btnEnable = false;
  bool fromDonate = false;
  WalletViewModel _walletViewModel;
  TextEditingController addressEditController = TextEditingController();
  TextEditingController transferAmountEditController = TextEditingController();

  SendViewModel() {
    addressEditController.addListener(() {
      String address = addressEditController.text;
      setRevAddress(address: address);
      btnShouldEnable();
    });

    transferAmountEditController.addListener(() {
      String amount = transferAmountEditController.text;
      setRevAmount(amount: amount);
      btnShouldEnable();
    });
  }

  btnShouldEnable() {
    btnEnable = transferAddress.length > 0 && transferAmount.length > 0;
    notifyListeners();
  }

  bool checkInput() {
    if (!transferAddress.startsWith("1111") ||
        (transferAddress.length < 45 || transferAddress.length > 60)) {
      CapoDialogUtils.showCupertinoDialog(
          buildContext: buildContext, message: tr("sendPage.incorrectAddress"));
      return false;
    }
    try {
      double sendAmount = double.parse(transferAmount);
      double selfMaxAmount = double.parse(maxTransferAmount);
      if (sendAmount > selfMaxAmount) {
        CapoDialogUtils.showCupertinoDialog(
            buildContext: buildContext,
            message:
                tr("sendPage.greaterMaxAmount", args: [maxTransferAmount]));

        return false;
      }
      if (sendAmount <= 0) {
        CapoDialogUtils.showCupertinoDialog(
            buildContext: buildContext,
            message: tr("sendPage.incorrectAmount"));
        return false;
      }
    } catch (e) {
      CapoDialogUtils.showCupertinoDialog(
          buildContext: buildContext, message: tr("sendPage.incorrectAmount"));
      return false;
    }

    if (transferAddress == selfRevAddress) {
      CapoDialogUtils.showCupertinoDialog(
          buildContext: buildContext, message: tr("sendPage.addressIsSame"));
      return false;
    }

    String decimal = transferAmount.split(".").last;
    if (decimal != null && decimal.length > 8) {
      CapoDialogUtils.showCupertinoDialog(
          buildContext: buildContext,
          message: tr("sendPage.incorrectAmountLength"));

      return false;
    }

    return true;
  }

  tappedSendBtn() {
    bool checkPassed = checkInput();
    if (!checkPassed) {
      return;
    }
    showBottomSheet(buildContext);
  }

  doDeploy(String privateKey) async {
    CapoDialogUtils.showProcessIndicator(
        context: buildContext, tip: tr("sendPage.sending"));
    int amount = (double.parse(transferAmount) * 10e7).toInt();
    String term = transferFundsRho(
        revAddrFrom: selfRevAddress,
        revAddrTo: transferAddress,
        amount: amount);

    await RNodeNetworking.gRPC
        .sendDeploy(deployCode: term, privateKey: privateKey)
        .then((Map map) async {
      Navigator.pop(buildContext);
      DeployResponse response = map["response"];
      String deployID = map["deployID"];
      String error = (response.error.messages != null &&
              response.error.messages.length > 0)
          ? response.error.messages.first
          : null;
      if (error != null && error.length > 0) {
        CapoDialogUtils.showCupertinoDialog(
            buildContext: buildContext,
            message: tr("sendPage.deployFailed") + ": " + error.toString());
      } else {
        await saveSendHistory(deployID);
        _walletViewModel.getBalance();
        CapoDialogUtils.showCupertinoDialog(
            buildContext: buildContext,
            message: tr("sendPage.deploySuccess"),
            okTapped: () {
              FocusScope.of(buildContext).requestFocus(FocusNode());
              if (fromDonate) {
                showToast(tr("sendPage.thanks_donate"));
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.pop(buildContext);
                });
                return;
              }
              Navigator.pop(buildContext);
            });
      }
    }).catchError((error) {
      print("error:$error");
      Navigator.pop(buildContext);
      CapoDialogUtils.showCupertinoDialog(
          buildContext: buildContext,
          message: tr("sendPage.deployFailed") + ": " + error.toString());
    });
  }

  saveSendHistory(String deployID) async {
    TransactionHistory history = TransactionHistory(
        type: TransactionType.send,
        to: transferAddress,
        from: selfRevAddress,
        amount: transferAmount,
        deployId: deployID,
        status: TransactionStatus.pending,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString());
    String jsonString =
        await CapoStorageUtils.shared.readByAddress(key: kUserTransactions);
    if (jsonString == null || jsonString.length == 0) {
      TransactionHistoryModel model = TransactionHistoryModel();
      model.transactionHistoryList = [history];
      String modelString = json.encode(model.toJson());
      await CapoStorageUtils.shared
          .saveByAddress(key: kUserTransactions, content: modelString);
      RxBus.post("", tag: "AddTransaction");
      return;
    }
    TransactionHistoryModel model =
        TransactionHistoryModel.fromJson(json.decode(jsonString));
    model.transactionHistoryList.add(history);
    String modelString = json.encode(model.toJson());
    await CapoStorageUtils.shared
        .saveByAddress(key: kUserTransactions, content: modelString);
    RxBus.post("", tag: "AddTransaction");
  }

  getRevBalance(BuildContext context) {
    final Map map = ModalRoute.of(context).settings.arguments;
    if (map != null) {
      String transferAddr = map["revAddress"];
      if (transferAddr != null && transferAddr.length > 0) {
        addressEditController.text = transferAddr;
      }
      if (map["donate"] == "true") {
        fromDonate = true;
      }
    }

    _walletViewModel = Provider.of<WalletViewModel>(context);
    String selfBalance =
        _walletViewModel.revBalance == "--" ? "0" : _walletViewModel.revBalance;
    try {
      double sendAmount = double.parse(selfBalance);
      double maxAmount = sendAmount * 10e7 - minerFee;
      if (maxAmount <= 0) {
        maxTransferAmount = "0";
      } else {
        maxTransferAmount = (maxAmount / 10e7).toString();
      }
    } catch (e) {
      maxTransferAmount = "0";
    }
    selfRevBalance = selfBalance;
    selfRevAddress = _walletViewModel.currentWallet.address;
    buildContext = context;
  }

  setRevAddress({@required String address}) {
    if (address != null && address.length > 0) {
      transferAddress = address;
    } else {
      transferAddress = "";
    }
  }

  setRevAmount({@required String amount}) {
    if (amount != null && amount.length > 0) {
      transferAmount = amount;
    } else {
      transferAmount = "";
    }
  }

  decodeQrCode(String qrCode) {
    Uri uri = Uri.parse(qrCode);
    if (uri.scheme.toLowerCase() != "revaddress") {
      return;
    }
    String address = uri.path;
    String amount = uri.queryParameters["amount"];

    addressEditController.text = address;
    transferAmountEditController.text = amount;
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      if (barcode != null && barcode.length > 0 && !fromDonate) {
        decodeQrCode(barcode);
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        showToast(tr("appError.cameraPermission"));
      }
    } on FormatException {
      showToast(tr("appError.nothingScanned"));
    } catch (_) {}
  }

  showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 40,
                  width: double.infinity,
                  child: Center(
                      child: Text(
                    tr("sendPage.showModalBottomSheet.title"),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  )),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    children: <Widget>[
                      Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            capoNumberFormat(transferAmount) + " REV",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ))),
                      ListTile(
                        leading: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: Text(tr("sendPage.showModalBottomSheet.to"),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .color)),
                        ),
                        title: Text(transferAddress,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14)),
                      ),
                      Divider(),
                      ListTile(
                        leading: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: Text(
                            tr("sendPage.showModalBottomSheet.from"),
                            style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.caption.color),
                          ),
                        ),
                        title: Text(selfRevAddress,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14)),
                      ),
                      Divider(),
                      ListTile(
                        leading: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                          child: Text(tr("sendPage.showModalBottomSheet.fee"),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .color)),
                        ),
                        title: Text(
                            "≈ " + (minerFee / 10e7).toString() + " REV",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14)),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                        width: double.infinity,
                        child: CupertinoButton(
                          color: Color.fromARGB(255, 51, 118, 184),
                          padding: EdgeInsets.all(16),
                          pressedOpacity: 0.8,
                          child: Text(
                            tr("sendPage.showModalBottomSheet.btn_title"),
                            style: Theme.of(context).textTheme.button,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            CapoDialogUtils.showPasswordDialog(
                                buildContext: buildContext,
                                tip: tr("sendPage.signing"),
                                decryptSuccess: (String privateKey) {
                                  doDeploy(privateKey);
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        );
      },
    );
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
