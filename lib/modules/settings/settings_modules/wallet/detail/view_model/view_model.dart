import 'package:capo/modules/common/dialog/password_dialog.dart';
import 'package:capo/modules/common/view/loading.dart';
import 'package:capo/modules/settings/settings_modules/wallet/detail/dialog/view/textfield_dialog.dart';
import 'package:capo/utils/wallet_view_model.dart';
import 'package:capo_core_dart/capo_core_dart.dart';
import 'package:easy_localization/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

class WalletDetailViewModel extends ChangeNotifier {
  BasicWallet wallet;
  BuildContext context;
  bool showSwitchWallet;
  bool showExportMnemonic;
  WalletViewModel walletViewModel;
  getRouteWallet(BuildContext context) {
    walletViewModel = Provider.of<WalletViewModel>(context);
    this.wallet = ModalRoute.of(context).settings.arguments;
    this.context = context;
    if (wallet != null && walletViewModel.currentWallet != null) {
      showSwitchWallet =
          walletViewModel.currentWallet.address != wallet.address;
      showExportMnemonic = wallet.keystore is REVMnemonicKeystore;
    }
  }

  tappedChangeWalletName() {
    showDialog(
        context: context,
        builder: (_) {
          return TextFieldDialog(wallet);
        });
  }

  tappedSwitchWallet() {
    if (walletViewModel != null) {
      walletViewModel.switchWallet(wallet);
      Navigator.pop(context);
    }
  }

  tappedExportPrivateKey(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return PasswordDialog(
            wallet: wallet,
            okClick: (password) {
              showProcessIndicator(
                  context, "settings.wallets.detail.exporting");
              wallet.exportPrivateKey(password).then((String privateKey) {
                Navigator.pop(context);
                Navigator.pushNamed(context,
                    "capo://icapo.app/settings/wallets/detail/export_private_key?privateKey=$privateKey");
              }).catchError((error) {
                Navigator.pop(context);
                showErrorToast(error, context);
              });
            },
          );
        });
  }

  tappedExportMnemonic(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return PasswordDialog(
            wallet: wallet,
            okClick: (password) {
              showProcessIndicator(
                  context, "settings.wallets.detail.exporting");
              wallet.exportMnemonic(password).then((String mnemonic) {
                Navigator.pop(context);
                Navigator.pushNamed(context,
                    "capo://icapo.app/settings/wallets/detail/export_mnemonic?mnemonic=$mnemonic");
              }).catchError((error) {
                Navigator.pop(context);
                showErrorToast(error, context);
              });
            },
          );
        });
  }

  showErrorToast(error, context) {
    String errorText;
    if (error is AppError) {
      final type = error.type;
      if (type == AppErrorType.passwordIncorrect) {
        errorText = tr("settings.wallets.detail.password_invalid");
      } else {
        errorText = tr("appError.genericError");
      }
    } else {
      errorText = tr("appError.genericError");
    }

    showToastWidget(
        Loading(
          widget: Icon(
            Icons.close,
            size: 50,
          ),
          text: errorText,
        ),
        context: context,
        dismissOtherToast: true,
        handleTouch: true);
  }

  showProcessIndicator(context, String tip) {
    showDialog(
        context: context,
        builder: (_) {
          final indicator = CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).textTheme.caption.color),
          );
          return Loading(
            widget: indicator,
            text: tr(tip),
          );
        });
  }

  Future deleteWallet() async {
    showDialog(
        context: context,
        builder: (_) {
          return PasswordDialog(
            wallet: wallet,
            okClick: (password) {
              showProcessIndicator(context, "settings.wallets.detail.deleting");
              wallet.verifyPassword(password).then((correct) async {
                if (correct) {
                  WalletViewModel walletViewModel =
                      Provider.of<WalletViewModel>(context);
                  await walletViewModel.deleteWallet(context, wallet);
                  if (walletViewModel.currentWallet == null) {
                  } else {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                } else {
                  Navigator.pop(context);
                  final error = AppError(type: AppErrorType.passwordIncorrect);
                  showErrorToast(error, context);
                }
              }).catchError((error) {
                Navigator.pop(context);
                showErrorToast(error, context);
              });
            },
          );
        });
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
