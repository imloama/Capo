import 'package:capo/modules/balance/view/balance_card.dart';
import 'package:capo/utils/capo_utils.dart';
import 'package:easy_localization/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BalanceHomePage extends StatelessWidget {
  final _assetCard = AssetCard();
  Future _refresh() async {
    return _assetCard.viewModel.getBalance(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('bottomTabBar.balance')),
      ),
      body: Container(
        padding: EdgeInsets.all(2.0),
        child: RefreshIndicator(
          onRefresh: _refresh,
          backgroundColor: HexColor.mainColor,
          color: Colors.white,
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return _assetCard;
            },
          ),
        ),
      ),
    );
  }
}
