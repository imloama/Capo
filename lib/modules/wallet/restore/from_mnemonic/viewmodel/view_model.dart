import 'dart:core';

import 'package:capo/modules/common/view/loading.dart';
import 'package:capo/utils/wallet_view_model.dart';
import 'package:capo_core_dart/capo_core_dart.dart';
import 'package:easy_localization/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class FromMnemonicViewModel with ChangeNotifier {
  PublishSubject<String> mnemonicSubject = PublishSubject<String>();
  PublishSubject<String> walletNameSubject = PublishSubject<String>();
  PublishSubject<String> walletPasswordSubject = PublishSubject<String>();
  PublishSubject<String> repeatPasswordSubject = PublishSubject<String>();

  String mnemonicString;
  String walletNameString;
  String walletPasswordString;
  String repeatPasswordString;

  bool isButtonAvailable = false;
  bool isPasswordAvailable = true;
  bool isRepeatPasswordMatch = true;
  bool _disposed = false;
  FromMnemonicViewModel() {
    isButtonAvailableObservable
        .distinct()
        .doOnEach((value) => isButtonAvailable = value.value)
        .doOnEach((_) => notifyListeners())
        .listen((_) {});

    mnemonicSubject
        .distinct()
        .doOnEach((observable) => mnemonicString = observable.value)
        .listen((_) {});

    walletNameSubject
        .distinct()
        .doOnEach((observable) => walletNameString = observable.value)
        .listen((_) {});

    walletPasswordSubject
        .distinct()
        .doOnEach((observable) => walletPasswordString = observable.value)
        .listen((_) {});

    repeatPasswordSubject
        .distinct()
        .doOnEach((observable) => repeatPasswordString = observable.value)
        .listen((_) {});
  }

  Stream<bool> get isButtonAvailableObservable => Rx.combineLatest4(
          mnemonicSubject,
          walletNameSubject,
          walletPasswordSubject,
          repeatPasswordSubject, (String mnemonic, String walletName,
              String walletPassword, String repeatPassword) {
        return mnemonic.isNotEmpty &&
            walletName.isNotEmpty &&
            walletPassword.isNotEmpty &&
            repeatPassword.isNotEmpty;
      });

  Future btnTapped(context) async {
    if (!checkInput()) return;
    showProcessIndicator(context);
    final meta = WalletMeta(
        name: walletNameString,
        source: Source.importFromMnemonic,
        timestamp: DateTime.now().millisecondsSinceEpoch);

    var viewModel = Provider.of<WalletViewModel>(context);
    viewModel.walletManager
        .importFromMnemonic(
      password: walletPasswordString,
      mnemonic: mnemonicString,
      metadata: meta,
    )
        .then((keystore) {
      Navigator.of(context).pop();
      showToastWidget(
        Loading(
          widget: Icon(
            Icons.check,
            size: 50,
          ),
          text: tr("wallet.restore.from_mnemonic.success"),
        ),
        context: context,
        dismissOtherToast: true,
      );
      Navigator.pushNamedAndRemoveUntil(
          context, "capo://icapo.app/tabbar", (Route<dynamic> route) => false);
    }).catchError((error) {
      Navigator.of(context).pop();
      showErrorToast(error, context);
    });
  }

  bool checkInput() {
    if (walletPasswordString.length < 8) {
      isPasswordAvailable = false;
      notifyListeners();
      return false;
    } else {
      isPasswordAvailable = true;
    }

    if (walletPasswordString != repeatPasswordString) {
      isRepeatPasswordMatch = false;
      notifyListeners();
      return false;
    } else {
      isRepeatPasswordMatch = true;
    }

    notifyListeners();
    return true;
  }

  showProcessIndicator(context) {
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
            text: tr("wallet.restore.from_mnemonic.importing"),
          );
        });
  }

  showErrorToast(error, context) {
    String errorText;
    if (error is AppError) {
      final type = error.type;
      if (type == AppErrorType.addressAlreadyExist) {
        errorText = tr("appError.addressError.address_already_exist");
      } else if (type == AppErrorType.mnemonicInvalid) {
        errorText = tr("wallet.restore.from_mnemonic.mnemonic_not_validate");
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

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void dispose() {
    _disposed = true;
    mnemonicSubject.close();
    walletNameSubject.close();
    walletPasswordSubject.close();
    repeatPasswordSubject.close();
    super.dispose();
  }
}
