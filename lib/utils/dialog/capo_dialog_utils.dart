import 'package:capo/modules/common/dialog/password_dialog.dart';
import 'package:capo/modules/common/view/loading.dart';
import 'package:capo/utils/wallet_view_model.dart';
import 'package:capo_core_dart/capo_core_dart.dart';
import 'package:easy_localization/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../capo_utils.dart';

typedef PrivateKeyCallback = void Function(String);

class CapoDialogUtils {
  static void showCupertinoDialog(
      {@required BuildContext buildContext,
      @required String message,
      VoidCallback okTapped}) {
    var dialog = CupertinoAlertDialog(
      content: Text(
        message,
        style: TextStyle(fontSize: 20),
      ),
      actions: <Widget>[
        CupertinoButton(
          child: Text(
            tr("sendPage.dialogBtn"),
            style: TextStyle(color: HexColor.mainColor),
          ),
          onPressed: () {
            Navigator.pop(buildContext);
            if (okTapped != null) {
              okTapped();
            }
          },
        ),
      ],
    );

    showDialog(context: buildContext, builder: (_) => dialog);
  }

  static showPasswordDialog(
      {@required BuildContext buildContext,
      @required String tip,
      @required PrivateKeyCallback decryptSuccess}) {
    WalletViewModel walletViewModel =
        Provider.of<WalletViewModel>(buildContext);
    BasicWallet wallet = walletViewModel.currentWallet;
    showDialog(
        context: buildContext,
        builder: (_) {
          return PasswordDialog(
            wallet: wallet,
            okClick: (password) {
              showProcessIndicator(context: buildContext, tip: tip);
              wallet.exportPrivateKey(password).then((String privateKey) {
                Navigator.pop(buildContext);
                if (decryptSuccess != null) {
                  decryptSuccess(privateKey);
                }
              }).catchError((error) {
                Navigator.pop(buildContext);
                showErrorToast(error: error);
              });
            },
          );
        });
  }

  static showErrorToast({@required error}) {
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
        dismissOtherToast: true,
        handleTouch: true);
  }

  static showProcessIndicator({@required BuildContext context, String tip}) {
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
            text: tip,
          );
        });
  }
}
