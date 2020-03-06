import 'package:capo/modules/settings/settings_modules/wallet/detail/view_model/view_model.dart';
import 'package:capo/provider/provider_widget.dart';
import 'package:easy_localization/public.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@FFRoute(name: "capo://icapo.app/settings/wallets/detail")
class WalletDetailPage extends StatelessWidget {
  final WalletDetailViewModel viewModel = WalletDetailViewModel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Color.fromARGB(255, 25, 25, 25)
          : Color.fromARGB(255, 241, 242, 246),
      appBar: AppBar(
          title: Text(tr("settings.wallets.detail.title"))),
      body: ProviderWidget<WalletDetailViewModel>(
        model: viewModel,
        onModelReady: viewModel.getRouteWallet(context),
        builder: (_, viewModel, __) {
          return viewModel.wallet == null
              ? Container()
              : ListView(
                  children: <Widget>[
                    Container(
                      color: Theme.of(context).cardColor,
                      child: ListTile(
                        title: Text(tr("settings.wallets.detail.change_wallet_name")),
                        onTap: () {
                          viewModel.tappedChangeWalletName();
                        },
                        trailing: Text(viewModel.wallet.capoMeta.name),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      color: Theme.of(context).cardColor,
                      child: ListTile(
                        title: Text(tr("settings.wallets.detail.export_private_key")),
                        onTap: () {
                          viewModel.tappedExportPrivateKey(context);
                        },
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                        ),
                      ),
                    ),
                    viewModel.showExportMnemonic
                        ? Column(
                            children: <Widget>[
                              Container(
                                color: Theme.of(context).cardColor,
                                child: Divider(
                                  indent: 16,
                                  endIndent: 0,
                                  height: 1,
                                ),
                              ),
                              Container(
                                color: Theme.of(context).cardColor,
                                child: ListTile(
                                  title: Text(tr(
                                      "settings.wallets.detail.export_mnemonic_phrase")),
                                  onTap: () {
                                    viewModel.tappedExportMnemonic(context);
                                  },
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16.0,
                                  ),
                                ),
                              )
                            ],
                          )
                        : Container(),
                    viewModel.showSwitchWallet
                        ? GestureDetector(
                            onTap: () {
                              viewModel.tappedSwitchWallet();
                            },
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                    height: 46,
                                    color: Theme.of(context).cardColor,
                                    child: Center(
                                      child: Text(tr(
                                          "settings.wallets.detail.switch_wallet")),
                                    )),
                              ],
                            ))
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    GestureDetector(
                        onTap: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                CupertinoAlertDialog(
                              title: Column(
                                children: <Widget>[
                                  Text(tr(
                                      "settings.wallets.detail.delete_alert.title")),
                                  Text(
                                    tr(
                                        "settings.wallets.detail.delete_alert.content"),
                                    style: TextStyle(fontSize: 15),
                                  )
                                ],
                              ),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: Text(tr(
                                      "settings.wallets.detail.delete_alert.delete_btn_title")),
                                  isDestructiveAction: true,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    viewModel.deleteWallet();
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text(tr(
                                      "settings.wallets.detail.delete_alert.cancel_btn_title")),
                                  isDefaultAction: true,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                            height: 46,
                            color: Theme.of(context).cardColor,
                            child: Center(
                              child: Text(
                                tr(
                                    "settings.wallets.detail.delete_wallet"),
                                style: TextStyle(color: Colors.red),
                              ),
                            ))),
                  ],
                );
        },
      ),
    );
  }
}
